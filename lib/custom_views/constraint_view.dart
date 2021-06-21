import 'dart:convert';

import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/custom_views/draggable_sheet.dart';
import 'package:constraint_view/custom_views/task_view.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/config_entry.dart';
import 'package:constraint_view/models/configuration_model.dart';
import 'package:constraint_view/models/section_data.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:web_socket_channel/io.dart';

import '../enums/component_align.dart';
import '../models/margin_model.dart';

class ConstraintView extends StatefulWidget {
  _ConstraintViewState state;
  String constraintName;
  String stageName;
  String stageGroupID;
  String taskID;
  String userID;
  static const routeName = '/constraint_detail';

  ConstraintView(this.constraintName, this.stageName, this.stageGroupID,
      this.taskID, this.userID) {
    state = _ConstraintViewState(
        constraintName, stageName, stageGroupID, taskID, userID);
  }

  @override
  _ConstraintViewState createState() => state;
}

class _ConstraintViewState extends State<ConstraintView> {
  bool isConstraintComplete = false;
  bool canSkip = false;
  Future<dynamic> constraintData;
  String constraintName;
  String nextConstraintName;
  String stageName;
  String nextStageName;
  String stageGroupID;
  String taskID;
  String userID;
  Map<String, dynamic> configurationInputs = {"data": "data", "data2": "data4"};

  IOWebSocketChannel channel = IOWebSocketChannel.connect(
      "ws://192.168.1.129:4321/on_constraint_complete");

  _ConstraintViewState(this.constraintName, this.stageName, this.stageGroupID,
      this.taskID, this.userID);

  // void changeCurrentState(String state) {
  //   setState(() {
  //     sectionData.setCurrentConfig(state);
  //   });
  // }

  // void addConfigEntryWithComponent(int configEntryIndex, String section,
  //     ViewMargin margin, ComponentType componentType, List componentParams) {
  //   sectionData.state.addConfigEntryWithComponent(
  //       configEntryIndex, section, margin, componentType, componentParams);

  //   setState(() {});
  // }

  // void addComponentToConfigEntry(int configEntryIndex, int componentIndex,
  //     String section, ComponentType componentType, List componentParams) {
  //   sectionData.state.addComponentToConfigEntry(configEntryIndex,
  //       componentIndex, section, componentType, componentParams);

  //   setState(() {});
  // }

  // void modifyComponent(
  //     String componentID, dynamic valueToChange, String section) {
  //   sectionData.state.modifyComponent(componentID, valueToChange, section);
  //   setState(() {});
  // }

  // void removeComponentFromConfigEntry(
  //     int componentIndex, int configEntryIndex, String section) {
  //   sectionData.state.removeComponentFromConfigEntry(
  //       componentIndex, configEntryIndex, section);
  //   setState(() {});
  // }

  // void removeConfigEntry(int configIndex, String section) {
  //   sectionData.state.removeConfigEntry(configIndex, section);
  //   setState(() {});
  // }

  Future getConstraintConfigurationInputs() async {
    Future<dynamic> data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/stage_group/" + stageGroupID + "/" + stageName,
        "get");

    Map<String, dynamic> parsedData = jsonDecode(await data);
    for (Map constraint in parsedData["constraints"]) {
      if (constraint["constraint_name"] == constraintName) {
        setState(() {
          configurationInputs = constraint["config_inputs"];
        });
      }
    }
  }

  void getConstraintDetails() {
    IOWebSocketChannel channel1 =
        IOWebSocketChannel.connect("ws://192.168.1.129:4321/constraint_detail");
    channel1.sink.add(jsonEncode({
      "constraint_name": constraintName,
      "stage_name": stageName,
      "task_id": taskID,
      "user_id": userID
    }));
    channel1.stream.first.then((value) {
      Map<String, dynamic> data = jsonDecode(value);
      setState(() {
        canSkip = !data["required"];
      });
      print(data);
    });
  }

  @override
  void initState() {
    super.initState();
    getNextConstraintDetails();
    getConstraintConfigurationInputs();
    getConstraintDetails();

    channel.sink.add(jsonEncode({
      "constraint_name": constraintName,
      "stage_name": stageName,
      "task_id": taskID,
      "user_id": userID
    }));

    channel.stream.listen((event) {
      Map<String, dynamic> recvData = jsonDecode(event);
      String eventData = recvData["event"];

      if (eventData == "STAGE_CONSTRAINT_COMPLETED") {
        setState(() {
          isConstraintComplete = true;
        });
        String constraintMsg = recvData["msg"];
        showConstraintCompleteDialog(constraintMsg);
      }
    });
  }

  void getNextConstraintDetails() {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(
        "ws://192.168.1.129:4321/next_constraint_or_stage");
    channel.sink.add(jsonEncode({
      "user_id": userID,
      "task_id": taskID,
      "stage_name": stageName,
      "constraint_name": constraintName
    }));

    channel.stream.first.then((value) {
      Map<String, dynamic> data = jsonDecode(value);

      nextStageName = data["stage_name"];
      nextConstraintName = data["constraint_name"];

      print(nextStageName);
      print(nextConstraintName);
    });
  }

  void startNextConstraint() {
    final channel =
        IOWebSocketChannel.connect("ws://192.168.1.129:4321/start_constraint1");

    channel.sink.add(jsonEncode({
      "user_id": userID,
      "task_id": taskID,
      "constraint_name": nextConstraintName,
      "stage_name": nextStageName
    }));

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$constraintName has started. Loading')));

    channel.stream.first.then((event) {
      // the first response from the websocket server is an input request
      Map<String, dynamic> recvData = jsonDecode(event);
      String eventData = recvData["event"];

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ConstraintView(
            nextConstraintName, nextStageName, stageGroupID, taskID, userID);
      }));
      // else if (eventData == "STAGE_CONSTRAINT_COMPLETED") {
      //   String constraintMsg = recvData["msg"];
      //   showConstraintCompleteDialog(constraintMsg);
      // }
    });
  }

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

  @override
  Widget build(BuildContext context) {
    constraintData = SectionData.forStatic(
            stageName, constraintName, taskID, userID, configurationInputs)
        .fromConstraint(constraintName);

    return WillPopScope(
      onWillPop: () {
        return Navigator.push(context, MaterialPageRoute(builder: (context) {
          return TaskView(
            taskID,
            userID,
            currentStage: stageName,
          );
        }));
      },
      child: SafeArea(
        child: Scaffold(
          body: FutureBuilder(
            future: constraintData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                SectionData sectionData = snapshot.data;
                sectionData.setInitialState("1");
                return Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      ///Top section
                      Container(
                          color: HexColor(sectionData.state.bgColor),
                          height: MediaQuery.of(context).size.height,
                          key: UniqueKey(),
                          child: sectionData.state.buildTopView()),

                      ///Draggable bottom section
                      Container(
                          key: UniqueKey(),
                          child: ConstraintDraggableSheet(sectionData)),

                      ///This section displays options to skip, continue, or view all the constraints
                      Container(
                        margin: EdgeInsets.only(top: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => TaskView(
                                          taskID,
                                          userID,
                                          currentStage: stageName,
                                        )));
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 10),
                                padding: EdgeInsets.only(
                                    top: 5, bottom: 5, left: 5, right: 5),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.grey[300])),
                                child: Icon(Icons.grid_view,
                                    size: 12, color: Colors.black),
                              ),
                            ),
                            Visibility(
                              visible: true,
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 5, bottom: 5, left: 10, right: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.grey[300])),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    sectionData.isRequired
                                        ? GestureDetector(
                                            onTap: canSkip
                                                ? () {
                                                    startNextConstraint();
                                                  }
                                                : () {},
                                            child: Container(
                                                child: Text(
                                              "SKIP",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: "JetBrainMono",
                                                  color: canSkip
                                                      ? Colors.blue
                                                      : Colors.grey),
                                            )),
                                          )
                                        : Container(
                                            child: Text(
                                            "",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )),
                                    Visibility(
                                      visible: isConstraintComplete,
                                      child: nextStageName == null
                                          ? GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TaskView(
                                                              taskID,
                                                              userID,
                                                              currentStage:
                                                                  stageName,
                                                            )));
                                              },
                                              child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  child: Text("FINISH",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              "JetBrainMono",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.green))),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                startNextConstraint();
                                              },
                                              child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 20),
                                                  child: Text("CONTINUE",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily:
                                                              "JetBrainMono",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.green))),
                                            ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          child: Text(
                            stageName,
                            style: TextStyle(
                              fontSize: 13,
                              color: stageName == "Pending"
                                  ? Colors.red[600].withOpacity(0.9)
                                  : stageName == "Active"
                                      ? Colors.green[600].withOpacity(0.9)
                                      : stageName == "Complete"
                                          ? Colors.blue[600].withOpacity(0.9)
                                          : Colors.grey[600].withOpacity(0.9),
                              fontFamily: "JetBrainMono",
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[300])),
                          margin: EdgeInsets.only(bottom: 20, right: 20),
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 5, bottom: 5),
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text("Loading $constraintName's view"),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
