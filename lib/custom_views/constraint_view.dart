import 'dart:convert';
import 'dart:io';

import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/custom_views/draggable_sheet.dart';
import 'package:constraint_view/custom_views/task_view.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/config_entry.dart';
import 'package:constraint_view/models/configuration_model.dart';
import 'package:constraint_view/models/section_data.dart';
import 'package:constraint_view/task_detail_page.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:constraint_view/view_controller.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String customViewName = "";
  bool admin = false;
  bool alreadyActive = false;
  bool preview = false;

  ConstraintView(this.constraintName, this.stageName, this.stageGroupID,
      this.taskID, this.userID, this.admin, this.preview,
      {this.customViewName, this.alreadyActive}) {
    state = _ConstraintViewState(
        constraintName, stageName, stageGroupID, taskID, userID, admin, preview,
        customViewName: customViewName, alreadyActive: alreadyActive);
  }

  @override
  _ConstraintViewState createState() => state;
}

class _ConstraintViewState extends State<ConstraintView>
    with WidgetsBindingObserver {
  SectionData sectionData;
  bool sectionDataBuilt = false;
  bool isConstraintComplete = false;
  bool canSkip = false;
  bool alreadyActive = false;
  bool constraintStarted = false;
  bool preview = false;
  Future<dynamic> constraintData;
  String constraintName;
  String nextConstraintName;
  String stageName;
  String nextStageName;
  String stageGroupID;
  String taskID;
  String userID;
  Map<String, dynamic> configurationInputs = {};
  String customViewName;
  bool admin;

  _ConstraintViewState(this.constraintName, this.stageName, this.stageGroupID,
      this.taskID, this.userID, this.admin, this.preview,
      {this.customViewName, this.alreadyActive = false});

  Future getConstraintConfigurationInputs() async {
    IOWebSocketChannel channel1 = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/get_constraint_config_inputs");
    channel1.sink.add(jsonEncode({
      "constraint_name": constraintName,
      "stage_name": stageName,
      "task_id": taskID,
      "user_id": userID
    }));

    channel1.stream.first.then((value) {
      Map<String, dynamic> data = jsonDecode(value);
      print("data $data");
      setState(() {
        configurationInputs = data;
        constraintStarted = true;
      });
    });

    // Map<String, dynamic> parsedData = jsonDecode(await data);
    // for (Map constraint in parsedData["constraints"]) {
    //   if (constraint["constraint_name"] == constraintName) {
    //     setState(() {
    //       configurationInputs = constraint["config_inputs"];
    //     });
    //     print(configurationInputs);
    //   }
    // }
  }

  void listenForExternalAction() {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/listen_external_action");
    channel.sink.add(jsonEncode({
      "constraint_name": constraintName,
      "stage_name": stageName,
      "task_id": taskID,
      "user_id": userID
    }));
    channel.stream.listen((event) {
      Map<String, dynamic> recvData = jsonDecode(event);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print(admin);
    print(preview);
    print(alreadyActive);

    if (!preview) {
      if (!admin) {
        registerUserAsActive();
        getNextConstraintDetails();
        WidgetsBinding.instance.addPostFrameCallback((_) {});
      }
      listenOnConstraintComplete();
      listenForExternalAction();
    } else {
      loadTopSectionsState();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    //App has been moved to the background
    if (state == AppLifecycleState.paused) {
      unRegisterUserAsActive();
      saveSectionState();
    }

    //App is in the foreground
    if (state == AppLifecycleState.resumed) {
      registerUserAsActive();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    unRegisterUserAsActive();
  }

  void listenOnConstraintComplete() {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/on_constraint_complete");

    channel.sink.add(jsonEncode({
      "constraint_name": constraintName,
      "stage_name": stageName,
      "task_id": taskID,
      "user_id": userID
    }));

    if (!alreadyActive) {
      startCurrentConstraint();
    }

    channel.stream.listen((event) {
      Map<String, dynamic> recvData = jsonDecode(event);
      setState(() {
        isConstraintComplete = true;
        canSkip = true;
      });
      unRegisterUserAsActive();
      if (admin) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating, content: Text("Complete!")));
      } else {
        showConstraintCompleteDialog("");
      }
    });
  }

  void getNextConstraintDetails() {
    IOWebSocketChannel channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/get_next_constraint_or_stage");
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
    });
  }

  void startCurrentConstraint() {
    final channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/start_constraint1");

    channel.sink.add(jsonEncode({
      "user_id": userID,
      "task_id": taskID,
      "constraint_name": constraintName,
      "stage_name": stageName
    }));

    channel.stream.first.then((event) {
      Map<String, dynamic> recvData = jsonDecode(event);
      print(recvData);
      if (recvData["event"] == "CONSTRAINT_ACTIVE") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Resuming')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$constraintName has started.')));
      }
    }).then((value) {
      getConstraintConfigurationInputs();
    });
  }

  void startNextConstraint() {
    final channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/start_constraint1");

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
          nextConstraintName,
          nextStageName,
          stageGroupID,
          taskID,
          userID,
          admin,
          false,
          alreadyActive: false,
        );
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

  void registerUserAsActive() {
    final channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/register_active_user");

    channel.sink.add(jsonEncode({
      "user_id": userID,
      "task_id": taskID,
      "constraint_name": constraintName,
      "stage_name": stageName
    }));

    channel.stream.first.then((value) {
      Map<String, dynamic> recvData = jsonDecode(value);
      if (recvData["msg"] == "done") {
        print("Live session active");
      } else if (recvData["msg"] == "error") {
        print("Live session error");
      }
    });
  }

  void unRegisterUserAsActive() {
    final channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/unregister_active_user");

    channel.sink.add(jsonEncode({
      "user_id": userID,
      "task_id": taskID,
      "constraint_name": constraintName,
      "stage_name": stageName
    }));

    channel.stream.first.then((value) {
      Map<String, dynamic> recvData = jsonDecode(value);
      if (recvData["msg"] == "done") {
        print("Live session active");
      } else if (recvData["msg"] == "error") {
        print("Live session error");
      }
    });
  }

  void saveSectionState() async {
    Map topViewData = sectionData.state.topViewController.state.saveState();
    Map bottomViewData =
        sectionData.state.bottomViewController.state.saveState();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        "$userID-$constraintName-$stageName-top", jsonEncode(topViewData));
    prefs.setString("$userID-$constraintName-$stageName-bottom",
        jsonEncode(bottomViewData));

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('State saved')));
  }

  void removeSectionStateData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("$userID-$constraintName-$stageName-top");
    prefs.remove("$userID-$constraintName-$stageName-bottom");
  }

  Future<Map> loadTopSectionsState() async {
    final prefs = await SharedPreferences.getInstance();
    Map topSectionStateData =
        jsonDecode(prefs.getString("$userID-$constraintName-$stageName-top"));

    return topSectionStateData;
  }

  Future<Map> loadBottomSectionsState() async {
    final prefs = await SharedPreferences.getInstance();
    Map bottomSectionStateData = jsonDecode(
        prefs.getString("$userID-$constraintName-$stageName-bottom"));

    return bottomSectionStateData;
  }

  @override
  Widget build(BuildContext context) {
    constraintData = SectionData.forStatic(
            stageName, constraintName, taskID, userID, configurationInputs)
        .fromConstraint(
            customViewName == null ? constraintName : customViewName);
    return WillPopScope(
      onWillPop: () {
        if (admin) {
          return Navigator.push(context, MaterialPageRoute(builder: (context) {
            return TaskDetailPage(taskID);
          }));
        } else {
          return Navigator.push(context, MaterialPageRoute(builder: (context) {
            return TaskView(
              taskID,
              userID,
              currentStage: stageName,
            );
          }));
        }
      },
      child: SafeArea(
        child: Scaffold(
            body: admin || constraintStarted || alreadyActive
                ? FutureBuilder(
                    future: constraintData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        sectionData = snapshot.data;
                        sectionData.setInitialState("1");
                        loadTopSectionsState().then((topSectionData) {
                          loadBottomSectionsState().then((bottomSectionData) {
                            if (topSectionData != null &&
                                bottomSectionData != null)
                              sectionData.loadState(
                                  topSectionData, bottomSectionData);
                          });
                        });

                        return Container(
                          color: Colors.white,
                          child: Stack(
                            children: [
                              ///Top section
                              Container(
                                  color: HexColor(sectionData.state.bgColor),
                                  // height: MediaQuery.of(context).size.height,
                                  key: UniqueKey(),
                                  child: sectionData.state.buildTopView()),

                              ///Draggable bottom section
                              Container(
                                  key: UniqueKey(),
                                  child: ConstraintDraggableSheet(sectionData)),

                              ///This section displays options to skip, continue, or view all the constraints
                              Visibility(
                                visible: !admin,
                                child: Container(
                                  padding: EdgeInsets.only(top: 20, bottom: 20),
                                  color: Colors.grey.withOpacity(0.025),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      //Current stage
                                      Visibility(
                                        visible: isConstraintComplete,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 20),
                                          child: Text(
                                            stageName,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                              color: stageName == "Pending"
                                                  ? Colors.red[600]
                                                      .withOpacity(0.9)
                                                  : stageName == "Active"
                                                      ? Colors.green[600]
                                                          .withOpacity(0.9)
                                                      : stageName == "Complete"
                                                          ? Colors.blue[600]
                                                              .withOpacity(0.9)
                                                          : Colors.grey[600]
                                                              .withOpacity(0.9),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey[100])),
                                          padding: EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                              top: 5,
                                              bottom: 5),
                                        ),
                                      ),

                                      //Menu, Skip, Continue/Finish
                                      Container(
                                        margin: EdgeInsets.only(
                                          right: 20,
                                        ),
                                        child: Row(
                                          children: [
                                            //Menu button
                                            GestureDetector(
                                              onTap: () {
                                                unRegisterUserAsActive();
                                                saveSectionState();

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
                                                    EdgeInsets.only(right: 10),
                                                padding: EdgeInsets.only(
                                                    top: 5,
                                                    bottom: 5,
                                                    left: 5,
                                                    right: 5),
                                                decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300])),
                                                child: Icon(Icons.grid_view,
                                                    size: 12,
                                                    color: Colors.black),
                                              ),
                                            ),

                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: 5,
                                                  bottom: 5,
                                                  left: 10,
                                                  right: 10),
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Colors.grey[300])),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  //Skip button
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        left: 0),
                                                    child: sectionData
                                                            .isRequired
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
                                                                  fontFamily:
                                                                      "JetBrainMono",
                                                                  color: canSkip
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .grey),
                                                            )),
                                                          )
                                                        : Container(
                                                            child: Text(
                                                            "",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          )),
                                                  ),

                                                  //Continue button
                                                  Visibility(
                                                    visible:
                                                        isConstraintComplete,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      child:
                                                          nextStageName == null
                                                              ? GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(MaterialPageRoute(
                                                                            builder: (context) => TaskView(
                                                                                  taskID,
                                                                                  userID,
                                                                                  currentStage: stageName,
                                                                                )));
                                                                  },
                                                                  child: Container(
                                                                      child: Text(
                                                                          "FINISH",
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              fontFamily: "JetBrainMono",
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.green))),
                                                                )
                                                              : GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(builder:
                                                                            (context) {
                                                                      return ConstraintView(
                                                                        nextConstraintName,
                                                                        nextStageName,
                                                                        stageGroupID,
                                                                        taskID,
                                                                        userID,
                                                                        admin,
                                                                        false,
                                                                        alreadyActive:
                                                                            false,
                                                                      );
                                                                    }));
                                                                  },
                                                                  child: Container(
                                                                      child: Text(
                                                                          "CONTINUE",
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              fontFamily: "JetBrainMono",
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.green))),
                                                                ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                  )
                : Container(
                    child: Center(
                      child: Text("Loading..."),
                    ),
                  )),
      ),
    );
  }
}
