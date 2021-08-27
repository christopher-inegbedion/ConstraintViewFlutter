import 'dart:convert';

import 'package:constraint_view/component_action/commands/show_constraint_dialog_command.dart';
import 'package:constraint_view/components/live_model_component.dart';
import 'package:constraint_view/custom_views/task_view.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/section_data.dart';
import 'package:constraint_view/task_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'component_action/component_action.dart';
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
        home: MainApp());
  }
}

class MainApp extends StatelessWidget {
  GlobalKey<FormState> formKey = GlobalKey();
  String userID = Uuid().v4();
  String taskID = "e6f4527c-1cb3-4bfb-a53c-73eb40ae9e94";
  Map selectedProperties = {};
  Map finalSelectedProperties = {};

  double screenHeight;
  double screenWidth;

  Future showConstraintInDialog(
      BuildContext context, String constraintName, String stageName) async {
    Future<SectionData> sectionData = SectionData.forStatic(
            stageName, constraintName, "taskID", "userID", null)
        .fromConstraint(constraintName);
    SectionData sData;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              content: Container(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: screenWidth,
                      height: screenHeight / 2,
                      child: FutureBuilder(
                          future: sectionData,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              sData = snapshot.data;
                              sData.setInitialState("1");
                              return sData.state.buildTopView(isDialog: true);
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }))
                ]),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      if (sData.state.topViewController.state
                              .savedValues["config_inputs"] !=
                          null) {
                        Navigator.pop(context, [
                          sData.state.topViewController.state
                              .savedValues["config_inputs"]
                        ]);
                      }
                    },
                    child: Text("Done"))
              ],
            );
          });
        });
  }

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

  Future getAllTasks() async {
    Future<dynamic> data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum, "/task", "get");
    print("parsedData");

    Map<String, dynamic> parsedData = jsonDecode(await data);
    return parsedData;
  }

  void loadTaskDialog(BuildContext context, bool admin) {
    TaskView taskView = TaskView(taskID, userID);

    GlobalKey<FormState> formKey = GlobalKey();
    TextEditingController controller = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Load a task",
              style: TextStyle(
                  fontFamily: "JetBrainMono", fontWeight: FontWeight.bold),
            ),
            children: [
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                      validator: (String val) {
                        if (val == "") {
                          return "Please enter the task ID";
                        }
                        return null;
                      },
                      controller: controller,
                      decoration: InputDecoration(hintText: "Task ID")),
                ),
              ),
              Container(
                width: double.maxFinite,
                margin: EdgeInsets.only(left: 30, right: 30),
                child: FutureBuilder(
                  future: getAllTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List tasks = snapshot.data["tasks"];
                      if (tasks.length == 0) {
                        return Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 30, bottom: 30),
                          child: Text("There are no tasks available",
                              style: TextStyle(
                                fontFamily: "JetBrainMono",
                              )),
                        );
                      } else {
                        return Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(top: 20, bottom: 10),
                              child: Text("Available tasks",
                                  style: TextStyle(
                                      fontFamily: "JetBrainMono",
                                      fontWeight: FontWeight.bold)),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: tasks.length,
                              itemBuilder: (context, i) {
                                return Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        if (admin) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TaskDeailPage(
                                                          tasks.elementAt(i))));
                                        } else {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return TaskView(
                                                tasks.elementAt(i), userID);
                                          }));
                                        }
                                      },
                                      child: Text(tasks.elementAt(i)),
                                    ));
                              },
                            ),
                          ],
                        );
                      }
                    } else {
                      return Container(
                          margin: EdgeInsets.only(top: 20),
                          alignment: Alignment.center,
                          child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            if (admin) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TaskDeailPage(taskID)));
                            } else {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return TaskView(controller.text, userID);
                              }));
                            }
                          }
                        },
                        child: Text("Load")),
                    // TextButton(
                    //     onPressed: () {
                    //       Navigator.push(context,
                    //           MaterialPageRoute(builder: (context) {
                    //         return TaskView(taskID, userID);
                    //       }));
                    //     },
                    //     child: Text("Load predefined")),
                  ],
                ),
              )
            ],
          );
        });
  }

  Future getAllTaskProperties() async {
    Future<dynamic> data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/task/property/",
        "get");

    Map<String, dynamic> recvData = jsonDecode(await data);
    return recvData;
  }

  Future getPropertyDenominations(String propertyName) async {
    Future<dynamic> data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/task/property/" + propertyName + "/denomination",
        "get");

    List recvData = jsonDecode(await data)["denominations"];
    return recvData;
  }

  Future showTaskRegisteredDialog(BuildContext context, String taskID) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Registration complete"),
            children: [
              Container(
                  margin: EdgeInsets.only(left: 25, right: 30),
                  child: Text(
                    "Copy the code below",
                    style: TextStyle(fontFamily: "JetBrainMono", fontSize: 16),
                  )),
              Container(
                  margin: EdgeInsets.only(left: 25, right: 30, bottom: 10),
                  child: SelectableText(
                    taskID,
                    style: TextStyle(
                        fontFamily: "JetBrainMono",
                        color: Colors.red,
                        fontSize: 14),
                  )),
            ],
          );
        });
  }

  Future<void> createTaskDialog(BuildContext context) async {
    int _value = 1;
    List<Widget> views = [];
    List selections = [];

    dynamic dataToSend = {
      "task_name": "",
      "task_desc": "",
      "properties": jsonEncode({}),
      "stage_group_id": ""
    };

    GlobalKey<FormState> taskDetailsKey = GlobalKey();
    TextEditingController taskNameController = TextEditingController();
    TextEditingController taskDescController = TextEditingController();

    GlobalKey<FormState> stageGroupKey = GlobalKey();
    TextEditingController stageGroupIdController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setstate) {
            return SimpleDialog(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 50, left: 40),
                  child: Text(
                    "Create a task",
                    style: TextStyle(
                        fontFamily: "JetBrainMono",
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, left: 40),
                  child: Text(
                    "Complete the form to create a task",
                    style: TextStyle(fontFamily: "JetBrainMono", fontSize: 18),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30, left: 40),
                  child: Text(
                    "Basic Information",
                    style: TextStyle(fontFamily: "JetBrainMono", fontSize: 16),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 40, right: 30, top: 0),
                  child: Form(
                    key: taskDetailsKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: taskNameController,
                          decoration: InputDecoration(hintText: "Task name"),
                          validator: (String value) {
                            if (value == "") {
                              return "Please enter the task name";
                            }

                            return null;
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: TextFormField(
                            controller: taskDescController,
                            decoration:
                                InputDecoration(hintText: "Task description"),
                            validator: (String value) {
                              if (value == "") {
                                return "Please enter the task description";
                              }

                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30, left: 40),
                  child: Text(
                    "Properties",
                    style: TextStyle(fontFamily: "JetBrainMono", fontSize: 16),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, left: 40, right: 30),
                  child: Text(
                    "Select as many properties apply to your task",
                    style: TextStyle(
                        fontFamily: "JetBrainMono",
                        color: Colors.grey,
                        fontSize: 14),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 40),
                  width: double.maxFinite,
                  child: FutureBuilder(
                    future: getAllTaskProperties(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List data = snapshot.data["properties"];

                        return Container(
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            child: Wrap(
                              children: data
                                  .map((e) {
                                    return Container(
                                      margin: EdgeInsets.only(right: 10),
                                      child: FilterChip(
                                        label: Text(e),
                                        selected: selectedProperties[e] == null
                                            ? false
                                            : selectedProperties[e]["selected"],
                                        onSelected: (bool val) {
                                          if (val) {
                                            getPropertyDenominations(e)
                                                .then((value) {
                                              print(value);
                                              selectedProperties[e] = {
                                                "name": e,
                                                "value": null,
                                                "denominations": <String>[],
                                                "selected_denom": null,
                                                "selected": true,
                                                "formKey": null,
                                                "inputController": null
                                              };

                                              value.forEach((j) {
                                                selectedProperties[e]
                                                        ["denominations"]
                                                    .add(j);
                                              });
                                            }).whenComplete(() {
                                              setstate(() {});
                                            });
                                          } else {
                                            setstate(() {
                                              selectedProperties[e]
                                                  ["selected"] = false;
                                              selectedProperties.remove(e);
                                            });
                                          }
                                        },
                                      ),
                                    );
                                  })
                                  .toList()
                                  .cast<Widget>(),
                            ));
                      } else {
                        return Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 20, right: 20),
                          child: SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator()),
                        );
                      }
                    },
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(left: 40, right: 20),
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: selectedProperties.length,
                        itemBuilder: (context, i) {
                          Map<String, dynamic> data = selectedProperties[
                              selectedProperties.keys.elementAt(i)];
                          List denoms = [];
                          selectedProperties[data["name"]]["denominations"]
                              .forEach((val) {
                            denoms.add(val);
                          });

                          if (selectedProperties[data["name"]]["formKey"] ==
                              null) {
                            selectedProperties[data["name"]]["formKey"] =
                                GlobalKey<FormState>();
                          }

                          if (selectedProperties[data["name"]]
                                  ["inputController"] ==
                              null) {
                            selectedProperties[data["name"]]
                                ["inputController"] = TextEditingController();
                          }

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 20),
                                child: Text(data["name"]),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: 20),
                                  child: Form(
                                    key: selectedProperties[data["name"]]
                                        ["formKey"],
                                    child: TextFormField(
                                      controller:
                                          selectedProperties[data["name"]]
                                              ["inputController"],
                                      validator: (val) {
                                        if (val == "") {
                                          return "Please enter value";
                                        }

                                        return null;
                                      },
                                      decoration:
                                          InputDecoration(hintText: "Value"),
                                    ),
                                  ),
                                ),
                              ),
                              DropdownButton(
                                value: data["selected_denom"],
                                items: denoms.map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setstate(() {
                                    data["selected_denom"] = value;
                                  });
                                  print(denoms);
                                },
                              ),
                            ],
                          );
                        })),
                Container(
                  margin: EdgeInsets.only(top: 30, left: 40),
                  child: Text("Stage group",
                      style:
                          TextStyle(fontFamily: "JetBrainMono", fontSize: 16)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, left: 40, right: 30),
                  child: Text(
                    "Click the button below, complete the form, copy the code and paste it below",
                    style: TextStyle(
                        fontFamily: "JetBrainMono",
                        color: Colors.grey,
                        fontSize: 14),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 40),
                  alignment: Alignment.center,
                  child: TextButton(
                    child: Text("Create stage group"),
                    onPressed: () {
                      showConstraintInDialog(
                          context, "Select constraint_config", "");
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 40, right: 30, bottom: 30),
                  child: Form(
                      key: stageGroupKey,
                      child: TextFormField(
                        controller: stageGroupIdController,
                        decoration: InputDecoration(hintText: "Stage group ID"),
                        validator: (String value) {
                          if (value == "") {
                            return "Please enter the stage group ID";
                          }

                          return null;
                        },
                      )),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(top: 20, right: 30),
                  child: TextButton(
                    child: Text("Submit"),
                    onPressed: () {
                      //Verify that task name and desc are correct
                      if (taskDetailsKey.currentState.validate()) {
                        dataToSend["task_name"] = taskNameController.text;
                        dataToSend["task_desc"] = taskDescController.text;
                      }

                      //Verify any property that might have been selected is set correctly
                      selectedProperties.forEach((key, value) {
                        GlobalKey<FormState> propertiesKey = value["formKey"];

                        if (propertiesKey != null &&
                            propertiesKey.currentState.validate()) {
                          TextEditingController controller =
                              value["inputController"];
                          value["value"] = controller.text;

                          finalSelectedProperties[value["name"]] = {
                            "name": value["name"],
                            "selected_denom": value["selected_denom"],
                            "value": value["value"]
                          };

                          dataToSend["properties"] =
                              jsonEncode(finalSelectedProperties);
                        }
                      });

                      //Verify that a stage group id value is set correctly
                      if (stageGroupKey.currentState.validate()) {
                        dataToSend["stage_group_id"] =
                            stageGroupIdController.text;
                      }

                      print(dataToSend);

                      //Send the data to the server
                      Future response = NetworkUtils.performNetworkAction(
                          NetworkUtils.serverAddr + NetworkUtils.portNum,
                          "/create_task",
                          "post",
                          data: dataToSend);

                      response.then((value) {
                        Map data = jsonDecode(value);
                        Navigator.of(context).pop();
                        showTaskRegisteredDialog(context, data["task_id"]);
                      });
                    },
                  ),
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
    });

    Future<void> showConstraintInDialog(
        String constraintName, String stageName) async {
      Future<SectionData> sectionData = SectionData.forStatic(
              stageName, constraintName, "taskID", "userID", null)
          .fromConstraint(constraintName);
      SectionData sData;

      return showDialog<void>(
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                scrollable: true,
                content: Container(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: screenWidth,
                        height: screenHeight / 2,
                        child: FutureBuilder(
                            future: sectionData,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                sData = snapshot.data;
                                sData.setInitialState("1");
                                return sData.state.buildTopView();
                              } else {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            }))
                  ]),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        if (sData.state.topViewController.state
                                .savedValues["config_inputs"] !=
                            null) {
                          Navigator.pop(context, [
                            sData.state.topViewController.state
                                .savedValues["config_inputs"]
                          ]);
                        }
                      },
                      child: Text("Done"))
                ],
              );
            });
          },
          context: context);
    }

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
                loadTaskDialog(context, false);
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
                loadTaskDialog(context, true);
              },
              child: Container(
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Text(
                    "💻 TASK ADMIN",
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
