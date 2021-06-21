import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

class TaskDeailPage extends StatefulWidget {
  String taskID;

  TaskDeailPage(this.taskID);

  @override
  _TaskDeailPageState createState() => _TaskDeailPageState(taskID);
}

class _TaskDeailPageState extends State<TaskDeailPage> {
  String taskID;
  int liveSessionCount = 0;
  List pendingUsers = [];
  List activeUsers = [];
  List completeUsers = [];

  _TaskDeailPageState(this.taskID);

  void showConstraintCompleteDialog(String msg) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Constraint complete"),
          content: Container(width: double.maxFinite, child: Text(msg)),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void initTaskDetails() {
    final channel = IOWebSocketChannel.connect(
        "ws://192.168.1.129:4321/pipeline_session_admin_details");

    channel.sink.add(jsonEncode({"task_id": taskID}));

    channel.stream.first.then((event) {
      Map<String, dynamic> data = jsonDecode(event);
      setState(() {
        liveSessionCount = data["session_count"];
        pendingUsers = data["pending_users"];
        activeUsers = data["active_users"];
        completeUsers = data["complete_users"];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initTaskDetails();
  }

  @override
  void dispose() {
    super.dispose();
    final channel = IOWebSocketChannel.connect(
        "ws://192.168.1.129:4321/disconnect_task_details");

    channel.sink.add(jsonEncode({"task_id": taskID}));
  }

  @override
  Widget build(BuildContext context) {
    final channel = IOWebSocketChannel.connect(
        "ws://192.168.1.129:4321/connect_task_details");

    channel.sink.add(jsonEncode({"task_id": taskID}));

    channel.stream.listen((event) {
      Map<String, dynamic> data = jsonDecode(event);

      if (data["event"] == "count") {
        setState(() {
          liveSessionCount = data["data"];
        });
      } else if (data["event"] == "new_pending_user") {
        setState(() {
          pendingUsers.add(data["data"]);
        });
      } else if (data["event"] == "new_active_user") {
        setState(() {
          activeUsers.add(data["data"]);
        });
      } else if (data["event"] == "new_complete_user") {
        setState(() {
          completeUsers.add(data["data"]);
        });
      }
    });

    return SafeArea(
        child: Scaffold(
            body: Container(
      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              child: Text(
            "Task ID",
            style: TextStyle(
                fontFamily: "JetBrainMono",
                fontSize: 20,
                fontWeight: FontWeight.bold),
          )),
          Container(
              child: Text(
            "$taskID",
            style: TextStyle(fontSize: 20),
          )),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Text(
              "Live sessions: $liveSessionCount",
              style: TextStyle(
                  fontFamily: "JetBrainMono",
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 5),
            child: Text("Pending users",
                style: TextStyle(
                    fontFamily: "JetBrainMono",
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ),
          pendingUsers.length == 0
              ? Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text("No user in pending stage"))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: pendingUsers.length,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(pendingUsers[index]),
                            GestureDetector(
                                onTap: () {
                                  final channel = IOWebSocketChannel.connect(
                                      "ws://192.168.1.129:4321/pipeline_details");

                                  channel.sink.add(jsonEncode({
                                    "task_id": taskID,
                                    "user_id": pendingUsers[index]
                                  }));

                                  channel.stream.first.then((event) {
                                    Map<String, dynamic> data =
                                        jsonDecode(event);
                                    showConstraintCompleteDialog(
                                        data["value"].toString());
                                  });
                                },
                                child: Text(
                                  "view data",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontFamily: "JetBrainMono",
                                      fontSize: 14),
                                ))
                          ],
                        ));
                  }),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 5),
            child: Text("Active users",
                style: TextStyle(
                    fontFamily: "JetBrainMono",
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ),
          activeUsers.length == 0
              ? Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text("No user in active stage"))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: activeUsers.length,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(activeUsers[index]),
                            GestureDetector(
                                onTap: () {
                                  final channel = IOWebSocketChannel.connect(
                                      "ws://192.168.1.129:4321/pipeline_details");

                                  channel.sink.add(jsonEncode({
                                    "task_id": taskID,
                                    "user_id": completeUsers[index]
                                  }));

                                  channel.stream.first.then((event) {
                                    Map<String, dynamic> data =
                                        jsonDecode(event);
                                    showConstraintCompleteDialog(
                                        data["value"].toString());
                                  });
                                },
                                child: Text(
                                  "view data",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontFamily: "JetBrainMono",
                                      fontSize: 14),
                                ))
                          ],
                        ));
                  }),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 5),
            child: Text("Completed users",
                style: TextStyle(
                    fontFamily: "JetBrainMono",
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          ),
          completeUsers.length == 0
              ? Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text("No user in complete stage"))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: completeUsers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(completeUsers[index]),
                          GestureDetector(
                              onTap: () {
                                final channel = IOWebSocketChannel.connect(
                                    "ws://192.168.1.129:4321/pipeline_details");

                                channel.sink.add(jsonEncode({
                                  "task_id": taskID,
                                  "user_id": completeUsers[index]
                                }));

                                channel.stream.first.then((event) {
                                  Map<String, dynamic> data = jsonDecode(event);
                                  showConstraintCompleteDialog(
                                      data["value"].toString());
                                });
                              },
                              child: Text(
                                "view data",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontFamily: "JetBrainMono",
                                    fontSize: 14),
                              ))
                        ],
                      ),
                    );
                  }),
        ],
      ),
    )));
  }
}
