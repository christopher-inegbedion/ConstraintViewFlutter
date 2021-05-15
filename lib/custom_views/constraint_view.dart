import 'dart:convert';

import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/custom_views/draggable_sheet.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/config_entry.dart';
import 'package:constraint_view/models/configuration_model.dart';
import 'package:constraint_view/models/section_data.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:web_socket_channel/io.dart';

import '../enums/component_align.dart';
import '../models/margin_model.dart';

class ConstraintView extends StatefulWidget {
  SectionData sectionData;
  _ConstraintViewState state;

  ConstraintView(this.sectionData) {
    state = _ConstraintViewState(sectionData);
  }

  @override
  _ConstraintViewState createState() => state;
}

class _ConstraintViewState extends State<ConstraintView> {
  bool isConnected = false;
  bool isConstraintComplete = false;
  SectionData sectionData;
  IOWebSocketChannel channel;

  _ConstraintViewState(this.sectionData);

  void changeCurrentState(String state) {
    setState(() {
      sectionData.setCurrentConfig(state);
    });
  }

  void addConfigEntryWithComponent(int configEntryIndex, String section,
      Margin margin, ComponentType componentType, List componentParams) {
    sectionData.state.addConfigEntryWithComponent(
        configEntryIndex, section, margin, componentType, componentParams);

    setState(() {});
  }

  void addComponentToConfigEntry(int configEntryIndex, int componentIndex,
      String section, ComponentType componentType, List componentParams) {
    sectionData.state.addComponentToConfigEntry(configEntryIndex,
        componentIndex, section, componentType, componentParams);

    setState(() {});
  }

  void modifyComponent(
      String componentID, dynamic valueToChange, String section) {
    sectionData.state.modifyComponent(componentID, valueToChange, section);
    setState(() {});
  }

  void removeComponentFromConfigEntry(
      int componentIndex, int configEntryIndex, String section) {
    sectionData.state.removeComponentFromConfigEntry(
        componentIndex, configEntryIndex, section);
    setState(() {});
  }

  void removeConfigEntry(int configIndex, String section) {
    sectionData.state.removeConfigEntry(configIndex, section);
    setState(() {});
  }

  void initConnection() {
    channel = IOWebSocketChannel.connect("ws://echo.websocket.org");
    Stream messageStream = channel.stream;
    channel.sink.add(jsonEncode({"complete_constraint": "value"}));
  }

  void listenForMessages() {
    Stream messageStream = channel.stream;

    messageStream.listen(
        (data) {
          setState(() {
            isConnected = true;
          });
          Map<String, dynamic> jsonData = jsonDecode(data);

          switch (jsonData["command"]) {
            case "complete_constraint":
              handleConstraintCompleteCommand(jsonData);
              break;
            default:
              print(data);
          }
        },
        cancelOnError: true,
        onError: (e) {
          isConnected = false;
          errorHandler();
        });
  }

  void handleConstraintCompleteCommand(Map<String, dynamic> data) {
    isConstraintComplete = true;

    //check if a state change is required
    if (data["state_change"]) {
      String state = data["state"];
      changeCurrentState(state);
    }

    //check if any components need changing
    if (data["component_change"]) {
      List componentChanges = data["components"];
      for (Map<String, dynamic> changeCommandJSON in componentChanges) {
        //perform a command depending on the type specified in [change_type]
        //param
        switch (changeCommandJSON["change_type"]) {
          //add command
          case "add_w_entry":
            String section = changeCommandJSON["section"];
            List componentParams = changeCommandJSON["component_params"];
            Margin margin = Margin(
                int.parse(changeCommandJSON["margin"][0].toString()).toDouble(),
                int.parse(changeCommandJSON["margin"][1].toString()).toDouble(),
                int.parse(changeCommandJSON["margin"][2].toString()).toDouble(),
                int.parse(changeCommandJSON["margin"][3].toString())
                    .toDouble());
            ComponentType componentType =
                componentTypeFromString(changeCommandJSON["component_type"]);
            int configEntryIndex = changeCommandJSON["config_entry_index"];

            addConfigEntryWithComponent(configEntryIndex, section, margin,
                componentType, componentParams);
            break;
          case "add_no_entry":
            String section = changeCommandJSON["section"];
            List componentParams = changeCommandJSON["component_params"];
            ComponentType componentType =
                componentTypeFromString(changeCommandJSON["component_type"]);
            int componentIndex = changeCommandJSON["component_index"];
            int configEntryIndex = changeCommandJSON["config_entry_index"];

            addComponentToConfigEntry(configEntryIndex, componentIndex, section,
                componentType, componentParams);
            break;

          //modify command
          case "modify":
            String section = changeCommandJSON["section"];
            String componentID = changeCommandJSON["component_id"];
            dynamic value = changeCommandJSON["value"];

            modifyComponent(componentID, value, section);
            break;

          //delete command
          case "delete_w_entry":
            String section = changeCommandJSON["section"];
            int configEntryIndex = changeCommandJSON["configEntryIndex"];

            sectionData.state.removeConfigEntry(configEntryIndex, section);
            break;
          case "delete_no_entry":
            int componentIndex = changeCommandJSON["componentIndex"];
            String section = changeCommandJSON["section"];
            int configEntryIndex = changeCommandJSON["configEntryIndex"];

            sectionData.state.removeComponentFromConfigEntry(
                componentIndex, configEntryIndex, section);
            break;
          default:
        }
      }
    }
  }

  ComponentType componentTypeFromString(String componentType) {
    switch (componentType) {
      case "text":
        return ComponentType.Text;
      case "input":
        return ComponentType.Input;
      case "image":
        return ComponentType.Image;
      case "button":
        return ComponentType.Button;
      case "color_block":
        return ComponentType.ColorBlock;
      case "live_model":
        return ComponentType.LiveModel;
      default:
        return null;
    }
  }

  void errorHandler() {
    print("error");
  }

  void sendMessage(dynamic value) {
    Map<String, dynamic> msg = {
      "command": "complete_constraint",
      "state_change": false,
      "state": "3",
      "component_change": false,
      "components": [
        // {
        //   "change_type": "delete_w_entry",
        //   "componentIndex": 0,
        //   "section": "top",
        //   "configEntryIndex": 0
        // },
        {
          "change_type": "add_no_entry",
          "component_params": [
            "text",
            [0.0, 0.0, 0.0, 0.0],
            "Policing",
            "center",
            20.0,
            "#000000"
          ],
          "section": "top",
          "margin": [0, 0, 0, 0],
          "component_type": "text",
          "config_entry_index": 0,
          "component_index": 0
        },
        {
          "change_type": "modify",
          "component_id": "view_chair",
          "value": "early",
          "section": "top"
        }
      ],
      "data": "hello"
    };
    if (isConnected) {
      channel.sink.add(jsonEncode(msg));
      print("sent ${jsonEncode(msg)}");
    } else {
      throw Exception("A connection has not been opened");
    }
  }

  void isViewConnectedToConstraint() {
    if (isConnected) {
      sectionData.setCurrentConfig(sectionData.initialStateID);
    } else {
      sectionData.setNoConnectionState();
    }
  }

  @override
  void initState() {
    super.initState();
    initConnection();
    listenForMessages();
  }

  @override
  Widget build(BuildContext context) {
    isViewConnectedToConstraint();

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Container(
              color: HexColor(sectionData.state.bgColor),
              height: MediaQuery.of(context).size.height,
              key: UniqueKey(),
              child: sectionData.state.buildTopView()),
          TextButton(
              onPressed: () {
                addComponentToConfigEntry(0, 0, "top", ComponentType.Text, [
                  "text",
                  Margin(0, 0, 0, 0),
                  "placeholder" + DateTime.now().toString(),
                  ComponentAlign.center,
                  20.0,
                  "#000000"
                ]);
              },
              child: Text("add")),
          Container(
            margin: EdgeInsets.only(left: 50),
            child: TextButton(
                onPressed: () {
                  removeConfigEntry(0, "top");
                },
                child: Text("remove")),
          ),
          Container(
            margin: EdgeInsets.only(left: 110),
            child: TextButton(
                onPressed: () {
                  sendMessage("3");
                },
                child: Text("send")),
          ),
          Container(
              key: UniqueKey(), child: ConstraintDraggableSheet(sectionData)),
          Visibility(
            visible: isConstraintComplete,
            child: Container(
              width: double.maxFinite,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[100],
                      width: 1.0,
                    ),
                  )),
              child: Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.spaceAround,
                children: [
                  sectionData.isRequired
                      ? Container(
                          margin: EdgeInsets.only(right: 20),
                          child: TextButton(
                              child: Text(
                                "SKIP",
                                style: TextStyle(color: Colors.grey),
                              ),
                              onPressed: () {}))
                      : Container(
                          margin: EdgeInsets.only(right: 20),
                          child: TextButton(
                              child: Text(
                                "",
                                style: TextStyle(color: Colors.grey),
                              ),
                              onPressed: () {})),
                  Container(
                      margin: EdgeInsets.only(left: 20),
                      child: TextButton(
                          child: Text("CONTINUE",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                          onPressed: () {}))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
