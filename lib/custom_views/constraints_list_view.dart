import 'dart:convert';

import 'package:constraint_view/utils/network_functions.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:web_socket_channel/io.dart';

import 'constraint_view.dart';

class ConstraintsListView extends StatefulWidget {
  String viewMode;
  String stageGroupID;
  String taskID;
  String userID;
  String currentStage;
  bool stageStarted;
  _ConstraintsListState state;

  ConstraintsListView(this.viewMode, this.taskID, this.userID,
      this.stageGroupID, this.currentStage, this.stageStarted) {
    state = _ConstraintsListState(
        viewMode, taskID, userID, stageGroupID, currentStage, stageStarted);
  }

  void setStageStarted(bool val) {
    state.setStageStarted(val);
  }

  void setCurrentStage(String stageName) {
    state.setCurrentStage(stageName);
  }

  void setTaskId(String id) {
    state.setTaskId(id);
  }

  void setStageGroupId(String id) {
    state.setStageGroupId(id);
  }

  @override
  _ConstraintsListState createState() => state;
}

class _ConstraintsListState extends State<ConstraintsListView> {
  String viewMode;
  String currentStage;
  String taskID;
  String userID;
  String stageGroupID;
  bool stageStarted;

  _ConstraintsListState(this.viewMode, this.taskID, this.userID,
      this.stageGroupID, this.currentStage, this.stageStarted);

  Future getStageGroupData(String stageGroupId) {
    return NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/stage_group/" + stageGroupId + "/" + currentStage,
        "get");
  }

  void setStageStarted(bool val) {
    stageStarted = val;
  }

  void setCurrentStage(String stageName) {
    setState(() {
      currentStage = stageName;
    });
  }

  void setTaskId(String id) {
    taskID = id;
  }

  void setStageGroupId(String id) {
    stageGroupID = id;
  }

  void startConstraint(String constraintName) {
    if (stageStarted) {
      final channel = IOWebSocketChannel.connect(
          "ws://192.168.1.129:4321/start_constraint1");

      channel.sink.add(jsonEncode({
        "user_id": userID,
        "task_id": taskID,
        "constraint_name": constraintName,
        "stage_name": currentStage
      }));

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$constraintName has started. Loading')));

      channel.stream.first.then((event) {
        // the first response from the websocket server is an input request
        Map<String, dynamic> recvData = jsonDecode(event);
        String eventData = recvData["event"];

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ConstraintView(
              constraintName, currentStage, stageGroupID, taskID, userID);
        }));
        // else if (eventData == "STAGE_CONSTRAINT_COMPLETED") {
        //   String constraintMsg = recvData["msg"];
        //   showConstraintCompleteDialog(constraintMsg);
        // }
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('stage has not started')));
    }
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
    Widget buildConstraintThumbnailView(String constraintName) {
      return Container(
        width: MediaQuery.of(context).size.width / 2,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 3,
              height: MediaQuery.of(context).size.width / 3,
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              margin: EdgeInsets.only(top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(right: 20),
                      child: Text(
                        constraintName,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "R",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        )),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    Widget buildConstraintNormalView(
        String constraintName, String constraintDesc, bool isRequired) {
      return InkWell(
        onTap: () {
          startConstraint(constraintName);
        },
        splashColor: Colors.black,
        child: Container(
          width: 300,
          margin: EdgeInsets.only(left: 20, right: 10),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                end: Alignment(
                    0.8, 0.0), // 10% of the width, so there are ten blinds.
                colors: <Color>[HexColor("#FF512F"), HexColor("#DD2476")],
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(7)),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      child: Text(
                        constraintName,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "JetBrainMono",
                            fontSize: 20),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5, right: 20),
                      child: Text(
                        constraintDesc,
                        style: TextStyle(fontSize: 13, color: Colors.grey[200]),
                      ),
                    )
                  ],
                ),
              ),
              isRequired ? Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400], width: 1),
                    color: Colors.white,
                  ),
                  height: 23,
                  width: 78,
                  margin: EdgeInsets.only(right: 10, bottom: 10),
                  child: Align(
                      child: Text(
                    "REQUIRED",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                    textAlign: TextAlign.center,
                  )),
                ),
              ) : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400], width: 1),
                    color: Colors.white,
                  ),
                  height: 23,
                  width: 78,
                  margin: EdgeInsets.only(right: 10, bottom: 10),
                  child: Align(
                      child: Text(
                    "VIEW ONLY",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                    textAlign: TextAlign.center,
                  )),
                ),
              )
            ],
          ),
        ),
      );
    }

    return FutureBuilder(
      future: getStageGroupData(stageGroupID),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> data = jsonDecode(snapshot.data);
          if (data != null) {
            String stageName = data["stage_name"];
            List constraints = data["constraints"];
            if (viewMode == "mini") {
              return Expanded(
                child: SingleChildScrollView(
                  child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: constraints.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisExtent: 250),
                      // Generate 100 widgets that display their index in the List.
                      itemBuilder: (context, index) {
                        return buildConstraintThumbnailView(stageName);
                      }),
                ),
              );
            } else if (viewMode == "normal") {
              return Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ListView.builder(
                        itemCount: constraints.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> constraint = constraints[index];
                          return buildConstraintNormalView(
                              constraint["constraint_name"],
                              constraint["constraint_desc"],
                              constraint["required"]);
                        })),
              );
            } else {
              return Center(
                  child: Text(
                "No data",
                style:
                    TextStyle(color: Colors.white, fontFamily: "JetBrainMono"),
              ));
            }
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
          return Center(
            child:
                Text("An error occured", style: TextStyle(color: Colors.white)),
          );
        } else {
          return Center(
            child: Text("Loading", style: TextStyle(color: Colors.white)),
          );
        }
      },
    );
  }
}
