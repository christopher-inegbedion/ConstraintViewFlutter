import 'dart:convert';

import 'package:constraint_view/custom_views/constraints_list_view.dart';
import 'package:constraint_view/main.dart';
import 'package:constraint_view/user_search.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:web_socket_channel/io.dart';

class TaskView extends StatefulWidget {
  String taskID;
  String userID;
  String currentStage;

  TaskView(this.taskID, this.userID, {this.currentStage});

  @override
  _TaskViewState createState() =>
      _TaskViewState(taskID, userID, currentStage: currentStage);
}

class _TaskViewState extends State<TaskView> {
  String taskID = "";
  String userID = "";
  String currentStage = "";
  String currentConstraint = "";
  bool constraintRunning = false;
  bool pipelineRunning = false;
  bool stageComplete = false;
  bool stageRunning = false;
  bool startingStage = false;
  bool initialStageStarted = false;
  ConstraintsListView constraintsListView;
  Container mainView;

  GlobalKey<FormState> key = GlobalKey();
  TextEditingController controller = TextEditingController();

  _TaskViewState(this.taskID, this.userID, {this.currentStage = ""});

  Future getTaskData() {
    return NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "task/" + taskID,
        "get");
  }

  Future getStageGroupData(String stageGroupId) {
    return NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/stage_group/" + stageGroupId,
        "get");
  }

  void listenToPipelineChanges() {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/get_stage_status");
    channel.sink.add(jsonEncode({
      "stage_name": currentStage,
      "user_id": userID,
      "task_id": taskID,
      "constraint_name": "_"
    }));

    channel.stream.first.then((event) {
      Map<String, dynamic> recvData = jsonDecode(event);
      dynamic value = recvData["value"];

      if (value == "complete") {
        setState(() {
          currentConstraint = "";
          stageRunning = false;
          stageComplete = true;
          constraintRunning = false;
        });
      } else if (value == "not_started") {
        setState(() {
          currentConstraint = "";
          stageRunning = false;
          stageComplete = false;
          constraintRunning = false;
        });
      } else if (value == "running") {
        setState(() {
          currentConstraint = "";
          stageComplete = false;
          stageRunning = true;
          constraintRunning = false;
        });
      } else if (value == "constraint_active") {
        setState(() {
          currentConstraint = recvData["constraint"];
          stageComplete = false;
          stageRunning = true;
          constraintRunning = true;
        });
      }

      constraintsListView.setActiveConstraint(currentConstraint);
      constraintsListView.setStageStarted(stageRunning);

      channel.sink.close();
    });
  }

  void isPipeRunning() {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/is_pipe_running");
    channel.sink.add(jsonEncode({"user_id": userID, "task_id": taskID}));
    channel.stream.first.then((event) {
      Map<String, dynamic> recvData = jsonDecode(event);
      if (recvData["value"] == "running") {
        setState(() {
          pipelineRunning = true;
        });
      } else if (recvData["value"] == "not_running") {
        setState(() {
          pipelineRunning = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getTaskData().then((value) {
      Map<String, dynamic> data = jsonDecode(value);
      String stageGroupID = data["stage_group_id"];

      getStageGroupData(stageGroupID).then((value) {
        Map<String, dynamic> data = jsonDecode(value);

        if (data["result"] == "success") {
          Map<String, dynamic> data = jsonDecode(value);

          setState(() {
            if (currentStage == "" || currentStage == null) {
              currentStage = data["stages"][0]["stage_name"];
            }

            constraintsListView = ConstraintsListView("normal", taskID, userID,
                stageGroupID, currentStage, stageRunning, currentConstraint);
          });
        }
      }).whenComplete(() {
        listenToPipelineChanges();
        isPipeRunning();
      });
    });
  }

  void startPipeline() {
    setState(() {
      startingStage = true;
    });
    IOWebSocketChannel channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/start_pipeline");
    channel.sink.add(jsonEncode(
        {"user_id": userID, "task_id": taskID, "stage_name": currentStage}));

    channel.stream.first.then((event) {
      Map<String, dynamic> recvData = jsonDecode(event);
      String response = recvData["result"];
      if (response == "success") {
        setState(() {
          pipelineRunning = true;
          startingStage = false;
          constraintsListView.setStageStarted(stageRunning);
        });
        listenToPipelineChanges();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('An error occured.')));
        setState(() {
          pipelineRunning = false;
          startingStage = false;
          constraintsListView.setStageStarted(stageRunning);
        });
      }
    });
  }

  void showStagesDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                "Select a stage",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(
                  title: Text(
                    "Pending",
                    style: TextStyle(),
                  ),
                  onTap: () {
                    setState(() {
                      currentStage = "Pending";
                      constraintsListView.setCurrentStage(currentStage);
                    });
                    listenToPipelineChanges();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text(
                    "Active",
                    style: TextStyle(),
                  ),
                  onTap: () {
                    setState(() {
                      currentStage = "Active";
                      constraintsListView.setCurrentStage(currentStage);
                    });
                    listenToPipelineChanges();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text(
                    "Complete",
                    style: TextStyle(),
                  ),
                  onTap: () {
                    setState(() {
                      currentStage = "Complete";
                      constraintsListView.setCurrentStage(currentStage);
                    });
                    listenToPipelineChanges();
                    Navigator.of(context).pop();
                  },
                ),
              ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget newTaskIdInput = Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 40, right: 40),
          child: Form(
            key: key,
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  hintText: "Task ID",
                  hintStyle: TextStyle(color: Colors.white)),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter task ID';
                }
                return null;
              },
            ),
          ),
        ),
        Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(right: 40),
            child: TextButton(
                onPressed: () {
                  if (key.currentState.validate()) {
                    taskID = controller.text;
                    setState(() {});
                  }
                },
                child: Text(
                  "SUMBIT",
                  style: TextStyle(color: Colors.green),
                )))
      ],
    );

    Widget bottomBar() {
      return Container(
        height: 70,
        width: double.maxFinite,
        // color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  GestureDetector(
                    child: Icon(
                      Icons.grid_view,
                      size: 20,
                    ),
                    onTap: () {
                      showStagesDialog(context);
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: currentStage == "Pending"
                          ? Colors.red
                          : currentStage == "Active"
                              ? Colors.green
                              : currentStage == "Complete"
                                  ? Colors.blue
                                  : Colors.grey,
                    ),
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Text(
                      currentStage == null ? "Loading" : currentStage,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.only(right: 20),
                child: pipelineRunning
                    ? stageRunning
                        ? constraintRunning
                            ? Container(
                                // color: Colors.red,
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(),
                                      child: Text(
                                        "CONSTRAINT ACTIVE",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(),
                                      child: Text(
                                        currentConstraint,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.toggle_on,
                                      size: 13,
                                      color: Colors.redAccent,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Text(
                                        "LIVE",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                        : stageComplete
                            ? Container(
                                child: Row(
                                  children: [
                                    Icon(Icons.done,
                                        size: 13, color: Colors.greenAccent),
                                    Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Text(
                                        "STAGE COMPLETE",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                child: Row(
                                  children: [
                                    Icon(Icons.cancel,
                                        size: 13, color: Colors.grey),
                                    Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Text(
                                        "STAGE INACTIVE",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                    : TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.white)),
                        onPressed: () {
                          startPipeline();
                        },
                        child: startingStage
                            ? SizedBox(
                                height: 12,
                                width: 12,
                                child: CircularProgressIndicator())
                            : Row(
                                children: [
                                  Text("START",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12)),
                                  Icon(Icons.play_arrow_outlined,
                                      color: Colors.green)
                                ],
                              ),
                      ))
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: FutureBuilder(
          future: getTaskData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> data = jsonDecode(snapshot.data);
              String stageGroupID = data["stage_group_id"];

              if (data["msg"] == "success") {
                return Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 40, left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    data["name"],
                                    style: GoogleFonts.sora(
                                        fontSize: 30,
                                        // color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5, bottom: 30),
                                  child: Text(
                                    data["desc"],
                                    style: GoogleFonts.sora(
                                      fontSize: 20,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 30),
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => MainApp()));
                                    },
                                    child: Icon(Icons.developer_mode)),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 30),
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UserModePage()));
                                    },
                                    child: Icon(Icons.search)),
                              ),
                            ],
                          )
                        ],
                      ),
                      constraintsListView == null
                          ? CircularProgressIndicator()
                          : constraintsListView,
                      bottomBar()
                    ],
                  ),
                );
              } else if (data["msg"] == "not_found") {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          margin:
                              EdgeInsets.only(left: 40, right: 40, bottom: 20),
                          child: Text(
                            "Task with ID: $taskID cannot be found",
                            // style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          )),
                      newTaskIdInput
                    ],
                  ),
                );
              } else {
                return Container();
              }
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    Center(
                        child: Text(
                      "An error occured. Try again",
                      // style: TextStyle(color: Colors.white),
                    ))
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
