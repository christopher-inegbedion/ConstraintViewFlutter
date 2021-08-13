import 'dart:convert';

import 'package:constraint_view/utils/network_functions.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:web_socket_channel/io.dart';

import 'custom_views/constraint_view.dart';

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

  Future getActiveConstraints(String constraintName, String stageName) async {
    final channel = IOWebSocketChannel.connect(
        "ws://192.168.1.129:4321/pipeline_constraint_details");
    channel.sink.add(jsonEncode({"task_id": taskID, "stage_name": stageName}));
    dynamic value = await channel.stream.first;
    Map<String, dynamic> recvData = jsonDecode(value);
    List users = recvData[stageName][constraintName];
    return users;
  }

  void showUserSessionsDialogForConstraint(
      String constraintName, String stageName) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text("$constraintName sessions"),
              content: FutureBuilder(
                future: getActiveConstraints(constraintName, stageName),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List data = snapshot.data;
                    List<Widget> widgets = [];
                    for (String i in data) {
                      widgets.add(TextButton(
                        onPressed: (() {
                          loadAdminConstraintViews(
                              constraintName, stageName, i);
                        }),
                        child: Text(i),
                      ));
                    }
                    return Column(
                        mainAxisSize: MainAxisSize.min, children: widgets);
                  } else if (snapshot.hasError) {
                    return Container(
                      height: 40,
                      child: Center(
                        child: Text("An error occured",
                            style: TextStyle(fontFamily: "JetBrainMono")),
                      ),
                    );
                  } else {
                    return Container(
                        height: 40,
                        child: Center(
                            child: Text("No data",
                                style: TextStyle(fontFamily: "JetBrainMono"))));
                  }
                },
              ));
        });
  }

  void showConstraintCompleteDialog(Map msg, String userID) {
    // for (Map data in msg["value"]) {
    //   print(data);
    // }

    List<Widget> pendingWidgets = [];
    pendingWidgets.add(
      Text("Pending",
          style: TextStyle(
              fontFamily: "JetBrainMono",
              fontWeight: FontWeight.bold,
              fontSize: 18)),
    );
    if (msg["value"].length > 0) {
      List pendingConstraints = msg["value"][0]["constraint_data"];

      if (pendingConstraints.length > 0) {
        for (Map constraint in pendingConstraints) {
          pendingWidgets.add(Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              child: Text("${constraint['constraint_name']}")));
          pendingWidgets.add(Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text("Result: ${constraint['data']}",
                  style: TextStyle(color: HexColor("#455A64")))));
        }
      } else {
        pendingWidgets.add(Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              "No pending constraints",
              style: TextStyle(color: HexColor("#455A64")),
            )));
      }
    } else {
      pendingWidgets.add(Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Text(
            "No pending constraints",
            style: TextStyle(color: HexColor("#455A64")),
          )));
    }

    List<Widget> activeWidgets = [];
    activeWidgets.add(
      Container(
        margin: EdgeInsets.only(top: 20),
        child: Text("Active",
            style: TextStyle(
                fontFamily: "JetBrainMono",
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
    if (msg["value"].length > 1) {
      List activeConstraints = msg["value"][1]["constraint_data"];
      if (activeConstraints.length > 0) {
        for (Map constraint in activeConstraints) {
          activeWidgets.add(Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              child: Text("${constraint['constraint_name']}")));
          activeWidgets.add(Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text("Result: ${constraint['data']}",
                  style: TextStyle(color: HexColor("#455A64")))));
        }
      } else {
        activeWidgets.add(Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              "No active constraints",
              style: TextStyle(color: HexColor("#455A64")),
            )));
      }
    } else {
      activeWidgets.add(Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Text(
            "No active constraints",
            style: TextStyle(color: HexColor("#455A64")),
          )));
    }

    List<Widget> completeWidgets = [];
    completeWidgets.add(
      Container(
        margin: EdgeInsets.only(top: 20),
        child: Text("Complete",
            style: TextStyle(
                fontFamily: "JetBrainMono",
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
    if (msg["value"].length > 2) {
      List completeConstraints = msg["value"][2]["constraint_data"];
      if (completeConstraints.length > 0) {
        for (Map constraint in completeConstraints) {
          completeWidgets.add(Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              child: Text("${constraint['constraint_name']}")));
          completeWidgets.add(Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text("Result: ${constraint['data']}",
                  style: TextStyle(color: HexColor("#455A64")))));
        }
      } else {
        completeWidgets.add(Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              "No complete constraints",
              style: TextStyle(color: HexColor("#455A64")),
            )));
      }
    } else {
      completeWidgets.add(Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          child: Text(
            "No complete constraints",
            style: TextStyle(color: HexColor("#455A64")),
          )));
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Constraint complete",
                style: TextStyle(
                    fontFamily: "JetBrainMono",
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  "User ID: $userID",
                  style: TextStyle(
                      fontFamily: "JetBrainMono",
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ],
          ),
          content: Container(
              // height: 300,
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: pendingWidgets),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: activeWidgets),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: completeWidgets),
                  ],
                ),
              )),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget showConstraintsForStage(String stageName) {
    return FutureBuilder(
      future: getStageGroupData(stageName),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> data = jsonDecode(snapshot.data);
          if (data != null) {
            String stageName = data["stage_name"];
            List constraints = data["constraints"];
            List<Widget> widgets = [];
            for (Map constraint in constraints) {
              String constraintName = constraint["constraint_name"];
              widgets.add(Container(
                margin: EdgeInsets.only(top: 5, bottom: 10),
                child: GestureDetector(
                    onTap: () {
                      showUserSessionsDialogForConstraint(
                          constraintName, stageName);
                    },
                    child: Text(constraint["constraint_name"],
                        style: TextStyle(
                            color: Colors.blue,
                            fontFamily: "JetBrainMono",
                            fontSize: 12))),
              ));
            }
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widgets);
          } else {
            return Expanded(
              child: Center(
                child: Text("There are no constraints for this stage",
                    style: TextStyle(
                        color: Colors.white, fontFamily: "JetBrainMono")),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Container(
            child: Text("An error occured",
                style: TextStyle(
                    color: Colors.red,
                    fontFamily: "JetBrainMono",
                    fontSize: 12)),
          );
        } else {
          return Center(
            child: Text("Loading", style: TextStyle(color: Colors.black)),
          );
        }
      },
    );
  }

  void loadAdminConstraintViews(
      String constraintName, String stageName, String userID) async {
    String stageGroupID = await getStageGroupID();

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ConstraintView(
        constraintName,
        stageName,
        stageGroupID,
        taskID,
        userID,
        true,
        customViewName: constraintName + "_admin",
      );
    }));
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

  Future getStageGroupID() async {
    Map data = jsonDecode(await NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/task/" + taskID,
        "get"));
    return data["stage_group_id"];
  }

  Future getStageGroupData(String stage) async {
    String stageGroupID = await getStageGroupID();
    return NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/stage_group/" + stageGroupID + "/" + stage,
        "get");
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

      //New user completed a stage
      if (data["event"] == "count") {
        setState(() {
          liveSessionCount = data["data"];
        });

        //New user completed pending stage
      } else if (data["event"] == "new_pending_user") {
        setState(() {
          pendingUsers.add(data["data"]);
        });

        //New user completed active stage
      } else if (data["event"] == "new_active_user") {
        setState(() {
          activeUsers.add(data["data"]);
        });

        //New user completed complete stage
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                child: Text(
              "Task ID:",
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
              margin: EdgeInsets.only(top: 20, bottom: 5),
              child: Text("Constraint sessions",
                  style: TextStyle(
                      fontFamily: "JetBrainMono",
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              child: Text("Pending Constraints",
                  style: TextStyle(
                      fontFamily: "JetBrainMono",
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
            Container(
              child: showConstraintsForStage("Pending"),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 5),
              child: Text("Active Constraints",
                  style: TextStyle(
                      fontFamily: "JetBrainMono",
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
            Container(
              child: showConstraintsForStage("Active"),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 5),
              child: Text("Complete Constraints",
                  style: TextStyle(
                      fontFamily: "JetBrainMono",
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
            Container(
              child: showConstraintsForStage("Complete"),
            ),
            Container(
              margin: EdgeInsets.only(top: 40, bottom: 5),
              child: Text("Completed users",
                  style: TextStyle(
                      fontFamily: "JetBrainMono",
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                "Completed sessions: $liveSessionCount",
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
                    child: Text("No user in pending stage",
                        style: TextStyle(
                            fontFamily: "JetBrainMono",
                            color: Colors.red,
                            fontSize: 12)))
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
                                          data, pendingUsers[index]);
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
                    child: Text("No user in active stage",
                        style: TextStyle(
                            fontFamily: "JetBrainMono",
                            color: Colors.red,
                            fontSize: 12)))
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
                                      "user_id": activeUsers[index]
                                    }));

                                    channel.stream.first.then((event) {
                                      Map<String, dynamic> data =
                                          jsonDecode(event);

                                      showConstraintCompleteDialog(
                                          data, activeUsers[index]);
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
                    margin: EdgeInsets.only(top: 5, bottom: 20),
                    child: Text("No user in complete stage",
                        style: TextStyle(
                            fontFamily: "JetBrainMono",
                            color: Colors.red,
                            fontSize: 12)))
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
                                    Map<String, dynamic> data =
                                        jsonDecode(event);
                                    showConstraintCompleteDialog(
                                        data, completeUsers[index]);
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
      ),
    )));
  }
}
