import 'dart:convert';

import 'package:constraint_view/custom_views/constraints_list_view.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class TaskView extends StatefulWidget {
  String taskID;

  TaskView(this.taskID);

  @override
  _TaskViewState createState() => _TaskViewState(taskID);
}

class _TaskViewState extends State<TaskView> {
  String taskID;
  String currentStage = "Loading";

  GlobalKey<FormState> key = GlobalKey();
  TextEditingController controller = TextEditingController();
  _TaskViewState(this.taskID);

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

  @override
  Widget build(BuildContext context) {
    Widget bottomBar(String currentStage) {
      return Container(
        height: 70,
        width: double.maxFinite,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.grid_view,
                    size: 20,
                    color: Colors.white,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.green,
                    ),
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Text(
                      currentStage,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 20),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Colors.white)),
                onPressed: () {},
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text("Add constraint",
                          style: TextStyle(color: Colors.black)),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Icon(
                        Icons.add_box,
                        color: Colors.black,
                        size: 15,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }

    Widget newTaskIdInput = Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 40, right: 40),
          child: Form(
            key: key,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(hintText: "Task ID"),
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
                    print(taskID);
                  }
                },
                child: Text("SUMBIT")))
      ],
    );

    return FutureBuilder(
      future: getTaskData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> data = jsonDecode(snapshot.data);
          String stageGroupID = data["stage_group_id"];

          if (data["msg"] == "success") {
            return Container(
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 40, left: 20),
                    child: Text(
                      data["name"],
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, bottom: 10),
                    child: Text(
                      data["desc"],
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  ConstraintsListView(
                      "normal", taskID, stageGroupID, "PENDIGN"),
                  FutureBuilder(
                    future: getStageGroupData(stageGroupID),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map<String, dynamic> data = jsonDecode(snapshot.data);

                        if (data["result"] == "success") {
                          Map<String, dynamic> data = jsonDecode(snapshot.data);
                          // currentStage = data["stages"][0]["stage_name"];
                          return bottomBar(data["stages"][0]["stage_name"]);
                        } else {
                          return Center(
                            child: Text(
                              "An error occured",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Error"),
                        );
                      } else {
                        return Center(
                          child: Text("Error"),
                        );
                      }
                    },
                  )
                ],
              ),
            );
          } else if (data["msg"] == "not_found") {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 40, right: 40),
                      child: Text(
                        "Task with ID: $taskID cannot be found",
                        textAlign: TextAlign.center,
                      )),
                  newTaskIdInput
                ],
              ),
            );
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text("An error occured"),
                ),
                newTaskIdInput
              ],
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Center(
                  child: Text("An error occured"),
                ),
                newTaskIdInput
              ],
            ),
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text("An error occured"),
                ),
                newTaskIdInput
              ],
            ),
          );
        }
      },
    );
  }
}
