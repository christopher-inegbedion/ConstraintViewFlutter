import 'dart:convert';

import 'package:constraint_view/utils/network_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:web_socket_channel/io.dart';

import 'custom_views/constraint_view.dart';

class TaskDeailPage extends StatefulWidget {
  String taskID;

  TaskDeailPage(this.taskID);

  @override
  _TaskDeailPageState createState() => _TaskDeailPageState(taskID);
}

class _TaskDeailPageState extends State<TaskDeailPage>
    with WidgetsBindingObserver {
  String taskID;
  int liveSessionCount = 0;
  List pendingUsers = [];
  List activeUsers = [];
  List completeUsers = [];

  Map pendingConstraintDataLabels = {};
  Map pendingConstraintsData = {};
  Map activeConstraintDataLabels = {};
  Map activeConstraintsData = {};
  Map completeConstraintDataLabels = {};
  Map completeConstraintsData = {};
  Map liveStagesAndConstraints = {};

  _TaskDeailPageState(this.taskID);


  Stream getActiveUsersForConstraint(String stageName, String constraintName) {
    final channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/get_constraint_active_users");

    channel.sink.add(jsonEncode({
      "task_id": taskID,
      "stage_name": stageName,
      "constraint_name": constraintName
    }));

    return channel.stream;
  }

  Widget showConstraintsForStage(String stageName) {
    return FutureBuilder(
      future: getStageGroupData(stageName, taskID),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> data = jsonDecode(snapshot.data);
          if (data != null) {
            String stageName = data["stage_name"];
            List constraints = data["constraints"];
            List<Widget> widgets = [];
            liveStagesAndConstraints[stageName] = [];
            for (Map constraint in constraints) {
              List constraintsForStage = liveStagesAndConstraints[stageName];

              String constraintName = constraint["constraint_name"];
              constraintsForStage.add(constraintName);

              widgets.add(Container(
                // color: Colors.black,
                // padding: EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
                margin: EdgeInsets.only(
                  top: 5,
                ),
                child: Text(constraint["constraint_name"],
                    style: TextStyle(
                      fontSize: 13,
                    )),
              ));

              widgets.add(StreamBuilder(
                stream: getActiveUsersForConstraint(stageName, constraintName),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List activeUsers =
                        jsonDecode(snapshot.data)["active_users"];
                    if (activeUsers.length > 0) {
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: activeUsers.length,
                          itemBuilder: (context, i) {
                            return Row(
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                      onPressed: () {
                                        loadAdminConstraintViews(constraintName,
                                            stageName, activeUsers[i]);
                                      },
                                      child: Text(
                                        activeUsers[i],
                                        style: TextStyle(
                                          fontSize: 13,
                                        ),
                                      )),
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 2, bottom: 2),
                                  color: Colors.red,
                                  child: Text("LIVE",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      )),
                                )
                              ],
                            );
                          });
                    } else {
                      return Container(
                        margin: EdgeInsets.only(top: 7, bottom: 15),
                        child: Text(
                          "No active users",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[200],
                          ),
                        ),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Container(
                      margin: EdgeInsets.only(top: 5, bottom: 15),
                      child: Text(
                        "An error occured",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
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
                      color: Colors.white,
                    )),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Container(
            child: Text("An error occured",
                style: TextStyle(color: Colors.red, fontSize: 12)),
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
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/pipeline_session_admin_details");

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

  Future getStageGroupData(String stage, String taskID) async {
    String stageGroupID = await getStageGroupID();
    return NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/task/" + taskID + "/stage_group/" + stageGroupID + "/" + stage,
        "get");
  }

  Future getConstraintsInStage(String stage) async {
    String stageGroupId = await getStageGroupID();
    Future data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/stage_group/" + stageGroupId,
        "get");
    Map val = jsonDecode(await data);
    if (stage == "Pending") {
      return val["stages"][0]["constraints"];
    } else if (stage == "Active") {
      return val["stages"][1]["constraints"];
    } else if (stage == "Complete") {
      return val["stages"][2]["constraints"];
    }
  }

  Future getConstraintCompletionInputLabels(String constraintName) async {
    Future data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/constraint/" + constraintName + "/data_labels",
        "get");
    return jsonDecode(await data)["labels"];
  }

  void disconnectTaskDetails() {
    final channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/disconnect_task_details");

    channel.sink.add(jsonEncode({"task_id": taskID}));
  }

  void disconnectConstraintActiveUserNotifier() {
    liveStagesAndConstraints.forEach((sName, value) {
      List constraints = value;
      constraints.forEach((cName) {
        final channel = IOWebSocketChannel.connect(
            "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/disconnect_from_constraint_active_users");

        channel.sink.add(jsonEncode({
          "task_id": taskID,
          "constraint_name": cName,
          "stage_name": sName
        }));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    initTaskDetails();
    final channel = IOWebSocketChannel.connect(
        "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/connect_task_details");

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

    Future.delayed(Duration.zero, () {
      getConstraintsInStage("Pending").then((value) {
        List constraints = value;
        constraints.forEach((constraintName) {
          pendingConstraintsData[constraintName] = <DataRow>[];
          getConstraintCompletionInputLabels(constraintName).then((labels) {
            int numberOfLabels = labels.length;

            pendingUsers.forEach((userId) {
              final channel = IOWebSocketChannel.connect(
                  "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/pipeline_details");

              channel.sink
                  .add(jsonEncode({"task_id": taskID, "user_id": userId}));

              channel.stream.first.then((value) {
                List stageConstraints =
                    jsonDecode(value)["value"][0]["constraint_data"];

                Map userConstraintData = stageConstraints.firstWhere(
                    (element) =>
                        element["constraint_name"] == constraintName)["data"];
                if (userConstraintData.isNotEmpty) {
                  List<DataCell> dataCells = [];
                  dataCells.add(DataCell(Text(
                    userId,
                  )));
                  for (int i = 0; i < numberOfLabels; i++) {
                    dataCells.add(DataCell(Text(
                      userConstraintData.entries.elementAt(i).value.toString(),
                    )));
                  }
                  setState(() {
                    pendingConstraintsData[constraintName].add(
                      DataRow(
                        cells: dataCells,
                      ),
                    );
                  });
                }
              });
            });
          });
        });
      });
      getConstraintsInStage("Complete").then((value) {
        List constraints = value;
        constraints.forEach((constraintName) {
          completeConstraintsData[constraintName] = <DataRow>[];
          getConstraintCompletionInputLabels(constraintName).then((labels) {
            int numberOfLabels = labels.length;

            completeUsers.forEach((userId) {
              final channel = IOWebSocketChannel.connect(
                  "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/pipeline_details");

              channel.sink
                  .add(jsonEncode({"task_id": taskID, "user_id": userId}));

              channel.stream.first.then((value) {
                List stageConstraints =
                    jsonDecode(value)["value"][2]["constraint_data"];
                print("stageConstraints $stageConstraints");

                Map userConstraintData = stageConstraints.firstWhere(
                    (element) =>
                        element["constraint_name"] == constraintName)["data"];
                if (userConstraintData.isNotEmpty) {
                  List<DataCell> dataCells = [];
                  dataCells.add(DataCell(Text(
                    userId,
                  )));
                  for (int i = 0; i < numberOfLabels; i++) {
                    dataCells.add(DataCell(Text(
                      userConstraintData.entries.elementAt(i).value.toString(),
                    )));
                  }
                  setState(() {
                    completeConstraintsData[constraintName].add(
                      DataRow(
                        cells: dataCells,
                      ),
                    );
                  });
                  print(completeConstraintDataLabels);
                }
              });
            });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    disconnectTaskDetails();
    disconnectConstraintActiveUserNotifier();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      disconnectTaskDetails();
      disconnectConstraintActiveUserNotifier();
    }
    if (state == AppLifecycleState.resumed) {
      // setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                child: Text(
              "Task ID:",
              style:
                  GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            Container(
                child: Text(
              "$taskID",
              style: TextStyle(fontSize: 20),
            )),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Text("Constraint interactions",
                  style: GoogleFonts.sora(
                      fontWeight: FontWeight.bold, fontSize: 22)),
            ),
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 20),
              child: Text(
                  "Some constraints allow for you to interact with your customers. You can start the admin version of the constraint started by the customer",
                  style: TextStyle(fontSize: 15, color: Colors.grey[600])),
            ),
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              child: Text("Pending Constraints",
                  style: GoogleFonts.sora(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            Container(
              child: showConstraintsForStage("Pending"),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 5),
              child: Text("Active Constraints",
                  style: GoogleFonts.sora(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            Container(
              child: showConstraintsForStage("Active"),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 5),
              child: Text("Complete Constraints",
                  style: GoogleFonts.sora(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            Container(
              child: showConstraintsForStage("Complete"),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400], width: 0.125)),
            ),

            Container(
              margin: EdgeInsets.only(
                top: 40,
              ),
              child: Text("Constraint data",
                  style: GoogleFonts.sora(
                      fontWeight: FontWeight.bold, fontSize: 22)),
            ),
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 20),
              child: Text("View the data for each user for each constraint",
                  style: TextStyle(fontSize: 15, color: Colors.grey[600])),
            ),

            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                "Completed sessions: $liveSessionCount",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 15),
              child: Text("Pending Constraints",
                  style: GoogleFonts.sora(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder(
              future: getConstraintsInStage("Pending"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List constraints = snapshot.data;
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: constraints.length,
                      itemBuilder: (context, i) {
                        return FutureBuilder(
                          future: getConstraintCompletionInputLabels(
                              constraints[i]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DataColumn> columns = [];
                              List labels = snapshot.data;

                              labels.forEach((element) {
                                columns.add(DataColumn(
                                  label: Text(
                                    element,
                                  ),
                                ));
                              });
                              columns.insert(
                                  0,
                                  DataColumn(
                                    label: Text(
                                      "ID",
                                    ),
                                  ));

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      child: Text(
                                    constraints[i],
                                    style: TextStyle(fontSize: 13),
                                  )),
                                  labels.isNotEmpty
                                      ? SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            showBottomBorder: true,
                                            columns: columns,
                                            rows: pendingConstraintsData[
                                                        constraints[i]] ==
                                                    null
                                                ? []
                                                : pendingConstraintsData[
                                                    constraints[i]],
                                          ),
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(
                                              bottom: 30, top: 5),
                                          child: Text("No data",
                                              style: TextStyle(
                                                  color: Colors.red[200],
                                                  fontSize: 12))),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        );
                      });
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 15),
              child: Text("Active Constraints",
                  style: GoogleFonts.sora(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder(
              future: getConstraintsInStage("Active"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List constraints = snapshot.data;
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: constraints.length,
                      itemBuilder: (context, i) {
                        return FutureBuilder(
                          future: getConstraintCompletionInputLabels(
                              constraints[i]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DataColumn> columns = [];
                              List labels = snapshot.data;

                              labels.forEach((element) {
                                columns.add(DataColumn(
                                  label: Text(
                                    element,
                                  ),
                                ));
                              });
                              columns.insert(
                                  0,
                                  DataColumn(
                                    label: Text(
                                      "ID",
                                    ),
                                  ));

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      child: Text(
                                    constraints[i],
                                    style: TextStyle(fontSize: 13),
                                  )),
                                  labels.isNotEmpty
                                      ? SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            showBottomBorder: true,
                                            columns: columns,
                                            rows: activeConstraintsData[
                                                        constraints[i]] ==
                                                    null
                                                ? []
                                                : activeConstraintsData[
                                                    constraints[i]],
                                          ),
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(
                                              bottom: 30, top: 5),
                                          child: Text("No data",
                                              style: TextStyle(
                                                  color: Colors.red[200],
                                                  fontSize: 12))),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        );
                      });
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 5, bottom: 15),
              child: Text("Complete Constraints",
                  style: GoogleFonts.sora(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            FutureBuilder(
              future: getConstraintsInStage("Complete"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List constraints = snapshot.data;
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: constraints.length,
                      itemBuilder: (context, i) {
                        return FutureBuilder(
                          future: getConstraintCompletionInputLabels(
                              constraints[i]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DataColumn> columns = [];
                              List labels = snapshot.data;

                              labels.forEach((element) {
                                columns.add(DataColumn(
                                  label: Text(
                                    element,
                                  ),
                                ));
                              });
                              columns.insert(
                                  0,
                                  DataColumn(
                                    label: Text(
                                      "ID",
                                    ),
                                  ));

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      child: Text(
                                    constraints[i],
                                    style: TextStyle(fontSize: 13),
                                  )),
                                  labels.isNotEmpty
                                      ? SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            showBottomBorder: true,
                                            columns: columns,
                                            rows: completeConstraintsData[
                                                        constraints[i]] ==
                                                    null
                                                ? []
                                                : completeConstraintsData[
                                                    constraints[i]],
                                          ),
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(
                                              bottom: 30, top: 5),
                                          child: Text("No data",
                                              style: TextStyle(
                                                  color: Colors.red[200],
                                                  fontSize: 12))),
                                ],
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        );
                      });
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            // Container(
            //   margin: EdgeInsets.only(top: 5, bottom: 5),
            //   child: Text("Active Constraints",
            //       style: TextStyle(
            //
            //           fontWeight: FontWeight.bold,
            //           fontSize: 18)),
            // ),
            // FutureBuilder(
            //   future: getConstraintsInStage("Active"),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       List constraints = snapshot.data;
            //       return ListView.builder(
            //           shrinkWrap: true,
            //           itemCount: constraints.length,
            //           itemBuilder: (context, i) {
            //             return Text(constraints[i],
            //                 style: TextStyle(
            //                      fontSize: 15));
            //           });
            //     } else {
            //       return CircularProgressIndicator();
            //     }
            //   },
            // ),
            // Container(
            //   margin: EdgeInsets.only(top: 5, bottom: 5),
            //   child: Text("Complete Constraints",
            //       style: TextStyle(
            //
            //           fontWeight: FontWeight.bold,
            //           fontSize: 18)),
            // ),
            // FutureBuilder(
            //   future: getConstraintsInStage("Complete"),
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       List constraints = snapshot.data;
            //       return ListView.builder(
            //           shrinkWrap: true,
            //           itemCount: constraints.length,
            //           itemBuilder: (context, i) {
            //             return Text(constraints[i],
            //                 style: TextStyle(
            //                      fontSize: 15));
            //           });
            //     } else {
            //       return CircularProgressIndicator();
            //     }
            //   },
            // ),
          ],
        ),
      ),
    )));
  }
}
