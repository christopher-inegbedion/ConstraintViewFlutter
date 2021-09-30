import 'dart:convert';

import 'package:constraint_view/components_test_page.dart';
import 'package:constraint_view/custom_views/task_view.dart';
import 'package:constraint_view/models/section_data.dart';
import 'package:constraint_view/register_account.dart';
import 'package:constraint_view/task_detail_page.dart';
import 'package:constraint_view/user_search.dart';
import 'package:constraint_view/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'utils/network_functions.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

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
          textTheme: GoogleFonts.jetBrainsMonoTextTheme(),
          primarySwatch: Colors.blue,
        ),
        home: ComponentsTestPage());
  }
}

class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  GlobalKey<FormState> formKey = GlobalKey();

  String userID;

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
                    child: Text("Create"))
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

  Future createStageGroupDialog(BuildContext context, String priceConstraint,
      String priceConstraintStage) {
    List pendingConstraints = [];
    List activeConstraints = [];
    List completeConstraints = [];
    List stageSelecting = pendingConstraints;
    String constraintViewing = "Pending";
    bool isFormCompleted = false;
    Future<dynamic> data;
    String stageID;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setstate) {
            return AlertDialog(
              title: Container(
                margin: EdgeInsets.only(left: 20, top: 20),
                child: Text(
                  "Stage constraints",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Text("Select constraints for each stage"),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        alignment: Alignment.centerLeft,
                        child: DropdownButton<String>(
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
                      ),
                      FutureBuilder(
                        future: getAllConstraints(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Map<String, dynamic> data = snapshot.data;
                            List allConstraints = data["constraints"];

                            //constraints for payment should not be among the constraints the user
                            //can select
                            allConstraints.removeWhere((constraint) {
                              bool isPaymentConstraint =
                                  constraint["for_payment"];
                              return isPaymentConstraint;
                            });

                            return Container(
                              height: 300,
                              margin: EdgeInsets.only(top: 30),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: allConstraints.length,
                                itemBuilder: (context, index) {
                                  String constraintName =
                                      allConstraints[index]["constraint_name"];
                                  bool isConstraintConfigRequired =
                                      allConstraints[index]
                                          ["is_configuration_input_required"];
                                  bool selected = false;

                                  //highlight a constraint if selected
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
                                          Map<String, dynamic> configInputs =
                                              {};
                                          if (isConstraintConfigRequired) {
                                            showConstraintInDialog(
                                                    context,
                                                    constraintName + "_config",
                                                    "")
                                                .then((value) {
                                              print(value);
                                            });
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
                                                stageSelecting.removeAt(index);
                                              } else {
                                                stageSelecting.add({
                                                  "constraint_name":
                                                      constraintName,
                                                  "config_inputs": configInputs
                                                });
                                              }
                                            } else {
                                              stageSelecting.add({
                                                "constraint_name":
                                                    constraintName,
                                                "config_inputs": configInputs
                                              });
                                            }
                                          });
                                        },
                                        selected: selected,
                                        title: Text(
                                          constraintName,
                                          style: TextStyle(),
                                        ),
                                        subtitle: Text(
                                          allConstraints[index]
                                              ["constraint_desc"],
                                          style: TextStyle(),
                                        ),
                                      ),
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
                  )),
              actions: <Widget>[
                TextButton(
                    child: const Text('Approve'),
                    onPressed: () async {
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

                      //Add payment constraint to stage
                      if (priceConstraintStage == "Pending") {
                        pendingConstraints.add({
                          "constraint_name": priceConstraint,
                          "config_inputs": {}
                        });
                      } else if (priceConstraintStage == "Active") {
                        activeConstraints.add({
                          "constraint_name": priceConstraint,
                          "config_inputs": {}
                        });
                      } else if (priceConstraintStage == "Complete") {
                        completeConstraints.add({
                          "constraint_name": priceConstraint,
                          "config_inputs": {}
                        });
                      }

                      data = NetworkUtils.performNetworkAction(
                          NetworkUtils.serverAddr + NetworkUtils.portNum,
                          "/stage_group",
                          "post",
                          data: jsonEncode(dataToSend));
                      stageID = jsonDecode(await data)["msg"];

                      print(stageID);

                      Navigator.pop(context, stageID);
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

    Map<String, dynamic> parsedData = jsonDecode(await data);
    return parsedData;
  }

  void loadTaskDialog(BuildContext context, bool admin) {
    GlobalKey<FormState> formKey = GlobalKey();
    TextEditingController controller = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Load a task",
              style: TextStyle(fontWeight: FontWeight.bold),
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
                              style: TextStyle()),
                        );
                      } else {
                        return Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(top: 20, bottom: 10),
                              child: Text("Available tasks",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: tasks.length,
                              itemBuilder: (context, i) {
                                return Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        if (admin) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TaskDetailPage(
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

  Future<List> getTaskCurrencies() async {
    Future<dynamic> data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/task/currency/",
        "get");

    List recvData = jsonDecode(await data)["currencies"];
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
                    style: TextStyle(fontSize: 16),
                  )),
              Container(
                  margin: EdgeInsets.only(left: 25, right: 30, bottom: 10),
                  child: SelectableText(
                    taskID,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  )),
            ],
          );
        });
  }

  Future getAllPaymentConstraints() async {
    Future data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum, "/constraints", "get");

    List allConstraints = jsonDecode(await data)["constraints"];
    List result = [];
    for (Map i in allConstraints) {
      if (i["for_payment"]) {
        result.add(i);
      }
    }

    return result;
  }

  Future<void> createTaskDialog(BuildContext context) async {
    String currencySelection;
    String priceConstraintValue;
    String priceConstraintStage = "Pending";
    String stageGroupID;
    List<bool> pricingStageSelections = [true, false, false];

    dynamic dataToSend = {
      "task_name": "",
      "task_desc": "",
      "properties": jsonEncode({}),
      "stage_group_id": "",
      "user_id": userID
    };

    GlobalKey<FormState> taskDetailsKey = GlobalKey();
    TextEditingController taskNameController = TextEditingController();
    TextEditingController taskDescController = TextEditingController();

    GlobalKey<FormState> stageGroupKey = GlobalKey();
    TextEditingController stageGroupIdController = TextEditingController();

    GlobalKey<FormState> paymentConstraintKey = GlobalKey();
    GlobalKey<FormState> priceConstraintKey = GlobalKey();
    TextEditingController amountController = TextEditingController();

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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, left: 40),
                  child: Text(
                    "Complete the form to create a task",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                //Basic information
                Container(
                  margin: EdgeInsets.only(top: 30, left: 40),
                  child: Text(
                    "Basic Information",
                    style: TextStyle(fontSize: 16),
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

                //Properties details
                Container(
                  margin: EdgeInsets.only(top: 30, left: 40),
                  child: Text(
                    "Properties",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, left: 40, right: 30),
                  child: Text(
                    "Select as many properties apply to your task",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
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
                                },
                              ),
                            ],
                          );
                        })),

                //Pricing details
                Container(
                  margin: EdgeInsets.only(top: 30, left: 40),
                  child: Text(
                    "Pricing",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, left: 40, right: 30),
                  child: Text(
                    "Enter your task's price details",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 40, right: 30, top: 10),
                  child: Form(
                      key: paymentConstraintKey,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 20),
                              child: TextFormField(
                                  validator: (String val) {
                                    if (val == "") {
                                      return "";
                                    }

                                    return null;
                                  },
                                  controller: amountController,
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      InputDecoration(hintText: "Amount")),
                            ),
                          ),
                          Expanded(
                            child: FutureBuilder(
                              future: getTaskCurrencies(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<String> data = [];

                                  snapshot.data.forEach((element) {
                                    data.add(element.toString());
                                  });

                                  return DropdownButtonFormField<String>(
                                    validator: (String val) {
                                      if (val == null) {
                                        return "";
                                      }

                                      return null;
                                    },
                                    value: currencySelection,
                                    elevation: 16,
                                    onChanged: (String newValue) {
                                      setstate(() {
                                        currencySelection = newValue;
                                      });
                                    },
                                    items: data.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                          )
                        ],
                      )),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30, left: 40, right: 30),
                  child: Text(
                    "Select the price constraint",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 40, right: 30),
                  child: FutureBuilder(
                    future: getAllPaymentConstraints(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<String> data = [];
                        for (Map i in snapshot.data) {
                          data.add(i["constraint_name"]);
                        }

                        return Form(
                          key: priceConstraintKey,
                          child: DropdownButtonFormField<String>(
                            validator: (String value) {
                              if (value == null) {
                                return "";
                              }

                              return null;
                            },
                            value: priceConstraintValue,
                            elevation: 16,
                            onChanged: (String newValue) {
                              setstate(() {
                                priceConstraintValue = newValue;
                              });
                            },
                            items: data
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        return Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, left: 40, right: 30),
                  child: Text(
                    "Select the stage for the price constraint",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 40, top: 20),
                  child: ToggleButtons(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Pending")),
                      Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Active")),
                      Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Text("Complete")),
                    ],
                    onPressed: (int index) {
                      setstate(() {
                        pricingStageSelections[0] = false;
                        pricingStageSelections[1] = false;
                        pricingStageSelections[2] = false;

                        pricingStageSelections[index] =
                            !pricingStageSelections[index];

                        if (index == 0) {
                          priceConstraintStage = "Pending";
                        } else if (index == 1) {
                          priceConstraintStage = "Active";
                        } else if (index == 2) {
                          priceConstraintStage = "Complete";
                        }
                      });
                    },
                    isSelected: pricingStageSelections,
                  ),
                ),

                //Stage group details
                Container(
                  margin: EdgeInsets.only(top: 40, left: 40),
                  child: Text("Stage group", style: TextStyle(fontSize: 16)),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, left: 40, right: 30),
                  child: Text(
                    "Click the button below, complete the form, copy the code and paste it below",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 40),
                  alignment: Alignment.center,
                  child: TextButton(
                    child: Text("Create stage group"),
                    onPressed: () {
                      if (priceConstraintKey.currentState.validate()) {
                        setState(() {
                          createStageGroupDialog(context, priceConstraintValue,
                                  priceConstraintStage)
                              .then((value) {
                            stageGroupIdController.text = value;
                          });
                        });
                      }
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
                      bool allFieldsValid = true;
                      //Verify that task name and desc are correct
                      if (taskDetailsKey.currentState.validate()) {
                        dataToSend["task_name"] = taskNameController.text;
                        dataToSend["task_desc"] = taskDescController.text;
                      } else {
                        allFieldsValid = false;
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
                        } else {
                          allFieldsValid = false;
                        }
                      });

                      //Verify pricing details are correct
                      if (priceConstraintKey.currentState.validate()) {
                        String amount = amountController.text;
                        String currency = currencySelection;
                        String priceConstraint = priceConstraintValue;
                        String priceStage = priceConstraintStage;

                        dataToSend["price"] = amount;
                        dataToSend["currency"] = currency;
                        dataToSend["price_constraint_name"] = priceConstraint;
                        dataToSend["price_constraint_stage"] = priceStage;
                      } else {
                        allFieldsValid = false;
                      }

                      if (paymentConstraintKey.currentState.validate()) {}

                      //Verify that a stage group id value is set correctly
                      if (stageGroupKey.currentState.validate()) {
                        dataToSend["stage_group_id"] =
                            stageGroupIdController.text;
                      } else {
                        allFieldsValid = false;
                      }

                      //Send the data to the server
                      if (allFieldsValid) {
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
                      }
                    },
                  ),
                ),
              ],
            );
          });
        });
  }

  @override
  void initState() {
    super.initState();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'constraint_admin_messages', // id
      'Constraint admin messages', // title
      'This channel is used for displaying admin messages.', // description
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        .createNotificationChannel(channel);

    Utils.initializeFlutterFire().then((value) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      FirebaseMessaging.instance.getToken().then((value) {
        print("reg token: $value");
      });

      

      FirebaseMessaging.onMessage.listen((RemoteMessage event) {
        Map data = event.data;
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        Map data = message.data;

        if (data["type"] == "constraint_complete") {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TaskDetailPage(data["task_id"])));
        }
      });
    });

    //If the user is not registered, redirect them to the registration page
    SharedPreferences.getInstance().then((prefs) {
      String id = prefs.getString(Utils.sharedPrefsIdKey);
      if (id == null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return RegisterAccountPage();
        }));
      } else {
        setState(() {
          userID = id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
    });

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
                style: TextStyle(),
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
                  style: TextStyle(),
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
                    style: TextStyle(),
                  )),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return UserModePage();
                }));
              },
              child: Container(
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Text(
                    "🔍 SEARCH",
                    style: TextStyle(),
                  )),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return RegisterAccountPage();
                }));
              },
              child: Container(
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: Text(
                    "📲 REGISTER",
                    style: TextStyle(),
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
                    style: TextStyle(),
                  )),
            ),
          ),
        ],
      ),
    )));
  }
}
