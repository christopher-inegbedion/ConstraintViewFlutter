import 'dart:convert';

import 'package:constraint_view/components/live_model_component.dart';
import 'package:constraint_view/custom_views/task_view.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/section_data.dart';
import 'package:constraint_view/task_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'components_test_page.dart';
import 'utils/network_functions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ConstraintViewDemo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ComponentsTestPage());
  }
}

class MainApp extends StatelessWidget {
  GlobalKey<FormState> formKey = GlobalKey();
  String userID = Uuid().v4();
  String taskID = "015bcd8f-11ff-4b21-9201-5186b0e3b3a5";

  Future<dynamic> getAllConstraints() async {
    Future<dynamic> data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum, "/constraints", "get");

    Map<String, dynamic> parsedData = jsonDecode(await data);
    return parsedData;
  }

  Widget showConstraints(String constraintName, List selectedConstraints) {
    return FutureBuilder(
        future: getAllConstraints(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data;
            List allConstraints = data["constraints"];
          }
        });
  }

  void createStageGroupDialog(BuildContext context) {
    List pendingConstraints = [];
    List activeConstraints = [];
    List completeConstraints = [];
    List stageSelecting = pendingConstraints;
    String constraintViewing = "Pending";
    bool isFormCompleted = false;
    Future<dynamic> data;
    String stageID;

    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setstate) {
            return AlertDialog(
              title: Text(
                "Select stage constraints",
                style: TextStyle(
                    fontFamily: "JetBrainMono", fontWeight: FontWeight.bold),
              ),
              content: !isFormCompleted
                  ? Container(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: constraintViewing,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            underline: Container(
                              height: 2,
                              color: Colors.blueAccent,
                            ),
                            onChanged: (String newValue) {
                              if (newValue == "Pending") {
                                stageSelecting = pendingConstraints;
                              } else if (newValue == "Active") {
                                stageSelecting = activeConstraints;
                              } else if (newValue == "Complete") {
                                stageSelecting = completeConstraints;
                              }
                              setstate(() {
                                constraintViewing = newValue;
                              });
                            },
                            items: <String>['Pending', 'Active', 'Complete']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          FutureBuilder(
                            future: getAllConstraints(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                Map<String, dynamic> data = snapshot.data;
                                List allConstraints = data["constraints"];

                                return Container(
                                  height: 200,
                                  margin: EdgeInsets.only(top: 30),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: allConstraints.length,
                                    itemBuilder: (context, index) {
                                      String constraintName =
                                          allConstraints[index]
                                              ["constraint_name"];
                                      List configParams = allConstraints[index]
                                          ["configuration_params"];
                                      bool isConstraintConfigRequired =
                                          allConstraints[index][
                                              "is_configuration_input_required"];
                                      int constraintConfigInputsCount =
                                          allConstraints[index]
                                              ["configuration_input_amount"];
                                      bool selected = false;

                                      GlobalKey<FormState> key = GlobalKey();
                                      List dataInputControllers = [];

                                      for (int i = 0;
                                          i < constraintConfigInputsCount;
                                          i++) {
                                        dataInputControllers
                                            .add(TextEditingController());
                                      }

                                      for (Map m in stageSelecting) {
                                        if (m["constraint_name"] ==
                                            constraintName) {
                                          selected = true;
                                        }
                                      }
                                      return Column(
                                        children: [
                                          ListTile(
                                            onTap: () {
                                              Map<String, dynamic>
                                                  configInputs = {};
                                              if (key.currentState != null) {
                                                if (key.currentState
                                                    .validate()) {
                                                  if (isConstraintConfigRequired) {
                                                    for (int i = 0;
                                                        i < constraintConfigInputsCount;
                                                        i++) {
                                                      configInputs[
                                                              configParams[i]] =
                                                          dataInputControllers[
                                                                  i]
                                                              .text;
                                                    }
                                                  }
                                                }
                                              }
                                              setstate(() {
                                                int index = 0;
                                                bool found = false;
                                                if (stageSelecting.length > 0) {
                                                  for (Map constraintMap
                                                      in stageSelecting) {
                                                    if (constraintMap[
                                                            "constraint_name"] ==
                                                        constraintName) {
                                                      found = true;
                                                      break;
                                                    }
                                                    index++;
                                                  }

                                                  if (found) {
                                                    stageSelecting
                                                        .removeAt(index);
                                                  } else {
                                                    stageSelecting.add({
                                                      "constraint_name":
                                                          constraintName,
                                                      "config_inputs":
                                                          configInputs
                                                    });
                                                  }
                                                } else {
                                                  stageSelecting.add({
                                                    "constraint_name":
                                                        constraintName,
                                                    "config_inputs":
                                                        configInputs
                                                  });
                                                }
                                              });
                                              print(stageSelecting);
                                            },
                                            selected: selected,
                                            title: Text(
                                              constraintName,
                                              style: TextStyle(
                                                  fontFamily: "JetBrainMono"),
                                            ),
                                            subtitle: Text(
                                              allConstraints[index]
                                                  ["constraint_desc"],
                                              style: TextStyle(
                                                  fontFamily: "JetBrainMono"),
                                            ),
                                          ),
                                          isConstraintConfigRequired
                                              ? Container(
                                                  width: double.maxFinite,
                                                  child: Form(
                                                    key: key,
                                                    child: ListView.builder(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          constraintConfigInputsCount,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            20),
                                                                child: Text(
                                                                  configParams[
                                                                      index],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            20),
                                                                child:
                                                                    TextFormField(
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                            null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Please enter some text';
                                                                    }
                                                                    return null;
                                                                  },
                                                                  controller:
                                                                      dataInputControllers[
                                                                          index],
                                                                  decoration:
                                                                      InputDecoration(
                                                                          hintText:
                                                                              "Data"),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          )
                        ],
                      ))
                  : FutureBuilder(
                      future: data,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Map<String, dynamic> decodedData =
                              jsonDecode(snapshot.data);

                          if (decodedData != null) {
                            stageID = decodedData["msg"];
                            return Container(
                              height: 100,
                              child: Center(
                                child: SelectableText(
                                    "Stage with ID: $stageID created",
                                    style:
                                        TextStyle(fontFamily: "JetBrainMono")),
                              ),
                            );
                          } else {
                            return Container(
                              height: 100,
                              child: Center(
                                child: Text("An error occured",
                                    style:
                                        TextStyle(fontFamily: "JetBrainMono")),
                              ),
                            );
                          }
                        } else {
                          return SizedBox(
                              height: 10, child: LinearProgressIndicator());
                        }
                      },
                    ),
              actions: <Widget>[
                TextButton(
                    child: const Text('Approve'),
                    onPressed: () {
                      var dataToSend = {
                        "stages": [
                          {
                            "stage_name": "Pending",
                            "constraints": pendingConstraints
                          },
                          {
                            "stage_name": "Active",
                            "constraints": activeConstraints
                          },
                          {
                            "stage_name": "Complete",
                            "constraints": completeConstraints
                          },
                        ]
                      };

                      data = NetworkUtils.performNetworkAction(
                          NetworkUtils.serverAddr + NetworkUtils.portNum,
                          "/stage_group",
                          "post",
                          data: jsonEncode(dataToSend));

                      setstate(() {
                        isFormCompleted = true;
                      });
                    }),
              ],
            );
          },
        );
      },
    );
  }

  void createTaskDialog(BuildContext context) {
    List selectedConstraints = [];
    bool formSubmitted = false;
    String formSubmittedMsg = "";
    TextEditingController taskNameController = TextEditingController();
    TextEditingController taskDescController = TextEditingController();
    TextEditingController stageGroupIDController = TextEditingController();
    Future<dynamic> data;
    String taskID = "";

    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setstate) {
            return AlertDialog(
              title: Text(
                "Create new task",
                style: TextStyle(
                    fontFamily: "JetBrainMono", fontWeight: FontWeight.bold),
              ),
              content: !formSubmitted
                  ? Container(
                      width: double.maxFinite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  TextField(
                                    controller: taskNameController,
                                    style:
                                        TextStyle(fontFamily: "JetBrainMono"),
                                    decoration:
                                        InputDecoration(hintText: "Task name"),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: TextField(
                                      controller: taskDescController,
                                      style:
                                          TextStyle(fontFamily: "JetBrainMono"),
                                      decoration: InputDecoration(
                                          hintText: "Task description"),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: TextField(
                                      controller: stageGroupIDController,
                                      style:
                                          TextStyle(fontFamily: "JetBrainMono"),
                                      decoration: InputDecoration(
                                          hintText: "Stage group Id"),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ))
                  : FutureBuilder(
                      future: data,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Map<String, dynamic> decodedData =
                              jsonDecode(snapshot.data);

                          if (decodedData != null) {
                            taskID = decodedData["task_id"];
                            return Container(
                              height: 100,
                              child: Center(
                                child: SelectableText(
                                    "Task with ID: $taskID created",
                                    style:
                                        TextStyle(fontFamily: "JetBrainMono")),
                              ),
                            );
                          } else {
                            return Container(
                              height: 100,
                              child: Center(
                                child: Text("An error occured",
                                    style:
                                        TextStyle(fontFamily: "JetBrainMono")),
                              ),
                            );
                          }
                        } else {
                          return SizedBox(
                              height: 10, child: LinearProgressIndicator());
                        }
                      },
                    ),
              actions: <Widget>[
                TextButton(
                  child: Text("New stage group"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    createStageGroupDialog(context);
                  },
                ),
                TextButton(
                    child: const Text('Next'),
                    onPressed: () {
                      if (!formSubmitted) {
                        var dataToSend = {
                          "task_name": taskNameController.text,
                          "task_desc": taskDescController.text,
                          "stage_group_id": stageGroupIDController.text
                        };

                        data = NetworkUtils.performNetworkAction(
                            NetworkUtils.serverAddr + NetworkUtils.portNum,
                            "/create_task",
                            "post",
                            data: dataToSend);

                        setstate(() {
                          formSubmitted = true;
                        });
                      } else {
                        if (taskID != "") {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return TaskView(taskID, userID);
                          }));
                        }
                      }
                    }),
              ],
            );
          },
        );
      },
    );
  }

  void loadTaskDialog(BuildContext context) {
    TaskView taskView = TaskView(taskID, userID);

    GlobalKey<FormState> formKey = GlobalKey();
    TextEditingController controller = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Load a task",
              style: TextStyle(
                  fontFamily: "JetBrainMono", fontWeight: FontWeight.bold),
            ),
            content: Form(
              child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: "Task ID")),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return TaskView(controller.text, userID);
                    }));
                  },
                  child: Text("Load")),
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return TaskView(taskID, userID);
                    }));
                  },
                  child: Text("Load predefined")),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 20),
              child: SelectableText(
                "ID: $userID",
                style: TextStyle(fontFamily: "JetBrainMono"),
              )),
          InkWell(
            onTap: () {
              createTaskDialog(context);
            },
            child: Container(
                padding:
                    EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: Text(
                  "🆕 CREATE TASK",
                  style: TextStyle(
                    fontFamily: "JetBrainMono",
                  ),
                )),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: InkWell(
              onTap: () {
                loadTaskDialog(context);
              },
              child: Container(
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Text(
                    "🔓 LOAD TASK",
                    style: TextStyle(
                      fontFamily: "JetBrainMono",
                    ),
                  )),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TaskDeailPage(taskID)));
              },
              child: Container(
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Text(
                    "💻 TASK DETAILS",
                    style: TextStyle(
                      fontFamily: "JetBrainMono",
                    ),
                  )),
            ),
          ),
        ],
      ),
    )));
  }
}
