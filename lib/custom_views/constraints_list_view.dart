import 'dart:convert';

import 'package:constraint_view/constraint_view_page.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:web_socket_channel/io.dart';

class ConstraintsListView extends StatefulWidget {
  String viewMode;
  String stageGroupID;
  String taskID;
  String currentStage;

  ConstraintsListView(
      this.viewMode, this.taskID, this.stageGroupID, this.currentStage);
  @override
  _ConstraintsListState createState() =>
      _ConstraintsListState(viewMode, taskID, stageGroupID, currentStage);
}

class _ConstraintsListState extends State<ConstraintsListView> {
  String viewMode;
  String currentStage;
  String taskID;
  String stageGroupID;

  _ConstraintsListState(
      this.viewMode, this.taskID, this.stageGroupID, this.currentStage);

  Future getStageGroupData(String stageGroupId) {
    return NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/stage_group/" + stageGroupId + "/" + currentStage,
        "get");
  }

  void startConstraint(String constraintName) {
    final channel = IOWebSocketChannel.connect("ws://192.168.1.129:4321");
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConstraintViewPage(constraintName)));

    // channel.sink.add(jsonEncode({
    //   "task_id": taskID,
    //   "constraint_name": constraintName,
    //   "stage_name": "PENDIGN"
    // }));

    // channel.stream.listen((event) {
    //   // the first response from the websocket server is an input request
    //   Map<String, dynamic> recvData = jsonDecode(event);
    //   String eventData = recvData["event"];

    //   // the required inputs are sent to the constraint if required
    //   if (eventData == "INPUT_REQUIRED") {
    //     int inputCount = recvData["value"]["input_count"];
    //     showRequiredInputsDialog(constraintName, inputCount, channel);
    //   } else if (eventData == "INPUT_NOT_REQUIRED") {
    //     Map<String, dynamic> returnVal = {"response": "INPUT_NOT_REQUIRED"};
    //     channel.sink.add(jsonEncode(returnVal));

    //     // listen for other events
    //   } else if (eventData == "STAGE_CONSTRAINT_COMPLETED") {
    //     String constraintMsg = recvData["msg"];
    //     showConstraintCompleteDialog(constraintMsg);
    //   }
    // });
  }

  void showRequiredInputsDialog(
      String constraintName, int inputCount, IOWebSocketChannel channel) {
    List<TextEditingController> inputControllers = [];
    List<GlobalKey<FormState>> formKeys = [];
    for (int i = 0; i < inputCount; i++) {
      inputControllers.add(TextEditingController());
      formKeys.add(GlobalKey<FormState>());
    }
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter inputs"),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: inputCount,
              itemBuilder: (context, index) {
                return Form(
                  key: formKeys.elementAt(index),
                  child: TextFormField(
                    controller: inputControllers.elementAt(index),
                    decoration: InputDecoration(hintText: "Input ${index + 1}"),
                    validator: (String value) {
                      return (value != null && value.isEmpty)
                          ? 'Constraint input required.'
                          : null;
                    },
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                bool allInputsComplete = true;
                List values = [];

                for (int i = 0; i < inputCount; i++) {
                  GlobalKey<FormState> key = formKeys.elementAt(i);
                  if (key.currentState.validate()) {
                    dynamic value = inputControllers.elementAt(i).text;
                    values.add({"type": "string", "data": value});
                  } else {
                    allInputsComplete = false;
                  }
                }

                if (allInputsComplete) {
                  Map<String, dynamic> returnVal = {
                    "response": "INPUT_REQUIRED",
                    "data": values
                  };
                  channel.sink.add(jsonEncode(returnVal));

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          '$constraintName is now running. Wait for completion')));

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
        String constraintName, String constraintDesc) {
      return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('$constraintName has started. Wait for input dialog')));
          startConstraint(constraintName);
          // showRequiredInputsDialog(2);
        },
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
                        style: TextStyle(color: Colors.white, fontSize: 20),
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
              Align(
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
                            constraint["constraint_desc"]);
                      })),
            );
          } else {
            return Center(child: Text("No data"));
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
