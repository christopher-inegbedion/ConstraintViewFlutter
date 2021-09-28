import 'dart:convert';

import 'package:constraint_view/main.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:constraint_view/utils/utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'custom_views/task_view.dart';
import 'task_detail_page.dart';

class UserModePage extends StatefulWidget {
  const UserModePage({Key key}) : super(key: key);

  @override
  _UserModePageState createState() => _UserModePageState();
}

class _UserModePageState extends State<UserModePage> {
  GlobalKey<FormState> searchFormKey = GlobalKey();
  TextEditingController searchInputController = TextEditingController();
  bool autoCompleteVisible = false;
  bool loadingData = false;
  bool searchResultVisible = false;
  Map suggestions = {};
  List relatedTasks = [];
  String userID;

  Future getTasksForUser() async {
    Future<dynamic> data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/task/user/$userID",
        "get");

    Map<String, dynamic> parsedData = jsonDecode(await data);
    List taskIds = [];
    for (String i in parsedData.keys) {
      taskIds.add(i);
    }
    return taskIds;
  }

  void loadTaskDialog() {
    GlobalKey<FormState> formKey = GlobalKey();
    TextEditingController controller = TextEditingController();

    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Your tasks",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Container(
                width: double.maxFinite,
                margin: EdgeInsets.only(left: 30, right: 30),
                child: FutureBuilder(
                  future: getTasksForUser(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List tasks = snapshot.data;
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
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TaskDetailPage(
                                                        tasks.elementAt(i))));
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

  @override
  void initState() {
    super.initState();
    
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        userID = prefs.getString(Utils.sharedPrefsIdKey);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              margin: EdgeInsets.only(bottom: 15, left: 20),
                              child: IconButton(
                                tooltip: "View analytics",
                                onPressed: () {
                                  loadTaskDialog();
                                },
                                icon: Icon(
                                  Icons.analytics,
                                  size: 20,
                                ),
                              )),
                          Container(
                              margin: EdgeInsets.only(bottom: 15),
                              child: IconButton(
                                // onPressed: () {},
                                tooltip: "Create product",
                                icon: Icon(
                                  Icons.note_add,
                                  size: 20,
                                ),
                              )),
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: IconButton(
                            tooltip: "Shopping bag",
                            // onPressed: () {},
                            icon: Icon(
                              Icons.shopping_bag,
                              size: 20,
                            ),
                          )),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[200])),
                  height: 50,
                  child: Row(
                    children: [
                      Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Icon(Icons.search)),
                      Expanded(
                        child: Form(
                          key: searchFormKey,
                          child: TextField(
                            onSubmitted: (String val) async {
                              setState(() {
                                loadingData = true;
                              });

                              Map<String, dynamic> result = jsonDecode(
                                  await NetworkUtils.performNetworkAction(
                                      NetworkUtils.serverAddr +
                                          NetworkUtils.portNum,
                                      "/related_tasks/$val",
                                      "get"));

                              setState(() {
                                relatedTasks = result["related"];
                                autoCompleteVisible = false;
                                searchResultVisible = true;
                                loadingData = false;
                              });
                            },
                            onChanged: (String val) async {
                              if (val == "") {
                                setState(() {
                                  searchResultVisible = false;
                                  loadingData = false;
                                  autoCompleteVisible = false;
                                });
                              } else {
                                setState(() {
                                  searchResultVisible = false;
                                  loadingData = true;
                                  autoCompleteVisible = true;
                                });

                                Map<String, dynamic> result = jsonDecode(
                                    await NetworkUtils.performNetworkAction(
                                        NetworkUtils.serverAddr +
                                            NetworkUtils.portNum,
                                        "/autocomplete/$val",
                                        "get"));
                                setState(() {
                                  loadingData = false;
                                  suggestions = result["suggestions"];
                                });
                              }
                            },
                            decoration: InputDecoration(
                                hintText: "Search", border: InputBorder.none),
                            controller: searchInputController,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: loadingData,
                  child: Container(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    child: LinearProgressIndicator(),
                  ),
                ),
                Visibility(
                  visible: autoCompleteVisible,
                  child: Container(
                      // height: 150,
                      margin: EdgeInsets.only(left: 30, right: 30, top: 5),
                      decoration: BoxDecoration(
                          color: Colors.yellow[50],
                          border: Border.all(color: Colors.grey[200])),
                      child: suggestions.length > 0
                          ? ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: suggestions.length,
                              itemBuilder: (context, i) {
                                return InkWell(
                                  onTap: () async {
                                    setState(() {
                                      loadingData = true;
                                    });

                                    Map<String, dynamic> result = jsonDecode(
                                        await NetworkUtils.performNetworkAction(
                                            NetworkUtils.serverAddr +
                                                NetworkUtils.portNum,
                                            "/related_tasks/${suggestions.keys.toList()[i]}",
                                            "get"));

                                    setState(() {
                                      relatedTasks = result["related"];
                                      autoCompleteVisible = false;
                                      searchResultVisible = true;
                                      loadingData = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey[100],
                                            width: 0.5)),
                                    padding: EdgeInsets.only(
                                        left: 20, top: 10, bottom: 10),
                                    child: Wrap(
                                      direction: Axis.vertical,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          child: Text(
                                            suggestions.keys.toList()[i],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              margin: EdgeInsets.only(top: 30, bottom: 30),
                              child: Center(
                                child: Text("╯(╬▔皿▔)╯"),
                              ),
                            )),
                ),
                Visibility(
                  visible: searchResultVisible,
                  child: Container(
                      // height: 250,
                      margin: EdgeInsets.only(left: 30, right: 30, top: 5),
                      decoration: BoxDecoration(
                          color: Colors.yellow[50],
                          border: Border.all(color: Colors.grey[200])),
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: relatedTasks.length,
                        itemBuilder: (context, i) {
                          Map taskData = relatedTasks[i];
                          return InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return TaskView(
                                    taskData.values.elementAt(0)["id"], userID);
                              }));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey[100], width: 0.5)),
                              padding: EdgeInsets.only(
                                  left: 20, top: 10, bottom: 10),
                              child: Wrap(
                                direction: Axis.vertical,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 1),
                                    child: Text(
                                      taskData.values.elementAt(0)["name"],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      taskData.values.elementAt(0)["desc"],
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700]),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                          '${taskData.values.elementAt(0)["currency"]} ${taskData.values.elementAt(0)["price"]}'),
                                    ),
                                  ),
                                  Text(
                                    "ID: " + taskData.values.elementAt(0)["id"],
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )),
                ),
                Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(top: 10, right: 20),
                    child: IconButton(
                      tooltip: "Dev mode",
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MainApp();
                        }));
                      },
                      icon: Icon(
                        Icons.developer_mode,
                        size: 20,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
