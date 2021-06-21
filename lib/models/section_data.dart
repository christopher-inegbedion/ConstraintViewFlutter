import 'dart:convert';

import 'package:constraint_view/components/button_component.dart';
import 'package:constraint_view/components/input_field_component.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/custom_views/constraint_view.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/configuration_model.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:constraint_view/view_controller.dart';
import 'package:web_socket_channel/io.dart';

import 'config_entry.dart';
import 'margin_model.dart';

///This model defines the view for the Top/Bottom section
class SectionData {
  List<ConfigurationModel> allStates;
  ConfigurationModel state;
  String initialStateID;
  bool isComplete;
  bool isRequired;
  String stage;
  String constraintName;
  String taskID;
  String userID;
  Map<String, dynamic> configurationInputs;

  ConfigurationModel defaultState = ConfigurationModel(
      "constraint_not_connected",
      true,
      [
        ConfigEntry([
          TextComponent(
              "no_connection_text",
              ViewMargin(0, 0, 0, 0),
              "Awaiting connection to constraint",
              ComponentAlign.center,
              30.0,
              "#ffffff")
        ], ViewMargin(0, 0, 0, 0))
      ],
      [],
      false,
      false,
      draggableSheetMaxHeight: 0.1,
      bgColor: "#000000",
      bottomSheetColor: "#000000");

  SectionData(this.allStates, this.isRequired, this.stage, this.constraintName,
      this.taskID, this.userID, this.configurationInputs) {
    this.setCurrentConfig("", model: defaultState);
  }

  SectionData.forStatic(this.stage, this.constraintName, this.taskID,
      this.userID, this.configurationInputs);

  Future<SectionData> fromConstraint(String constraintName) async {
    Future<dynamic> data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum,
        "/constraint_view/$constraintName",
        "get");

    Map<String, dynamic> parsedData = jsonDecode(await data);
    List<ConfigurationModel> configModel = [];
    for (Map configModelMap in parsedData["view"]["view"]) {
      String id = "${configModelMap["id"]}";
      String bgColor = configModelMap["bg_color"];
      String bottomSheetColor = configModelMap["bottom_sheet_color"];
      bool bottomSectionCanOpen =
          configModelMap["bottom_section_can_open"] == "1" ? true : false;
      bool bottomSectionCanExpand =
          configModelMap["bottom_section_can_expand"] == "1" ? true : false;
      bool centerTopSectionData =
          configModelMap["center_top_section_data"] == "1" ? true : false;
      double draggableSheetMaxHeight =
          double.parse("${configModelMap["draggable_sheet_max_height"]}");

      List<ConfigEntry> topSection = [];
      for (Map topSectionEntry in configModelMap["top_section"]) {
        List entryMarginArray = topSectionEntry["margin"].split(",");
        ViewMargin margin = ViewMargin(
          double.parse("${entryMarginArray[0]}"),
          double.parse("${entryMarginArray[1]}"),
          double.parse("${entryMarginArray[2]}"),
          double.parse("${entryMarginArray[3]}"),
        );
        List<Component> components = [];
        for (Map component in topSectionEntry["components"]) {
          switch (component["type"]) {
            case "text":
              components.add(TextComponent.forStatic()
                  .buildComponent(component["component_properties"], true));
              break;
            case "input":
              components.add(InputFieldComponent.forStatic()
                  .buildComponent(component["component_properties"], true));
              break;
            case "button":
              components.add(ButtonComponent.forStatic()
                  .buildComponent(component["component_properties"], true));
              break;
            default:
          }
        }
        ConfigEntry entry = ConfigEntry(components, margin);
        topSection.add(entry);
      }

      List<ConfigEntry> bottomSection = [];
      for (Map bottomSectionEntry in configModelMap["bottom_section"]) {
        List entryMarginArray = bottomSectionEntry["margin"].split(",");
        // print(entryMarginArray[0]);
        ViewMargin margin = ViewMargin(
          double.parse("${entryMarginArray[0]}"),
          double.parse("${entryMarginArray[1]}"),
          double.parse("${entryMarginArray[2]}"),
          double.parse("${entryMarginArray[3]}"),
        );
        List<Component> components = [];
        for (Map component in bottomSectionEntry["components"]) {
          switch (component["type"]) {
            case "text":
              components.add(TextComponent.forStatic()
                  .buildComponent(component["component_properties"], true));
              break;
            case "input":
              components.add(InputFieldComponent.forStatic()
                  .buildComponent(component["component_properties"], true));
              break;
            case "button":
              components.add(ButtonComponent.forStatic()
                  .buildComponent(component["component_properties"], true));
              break;
            default:
          }
        }
        ConfigEntry entry = ConfigEntry(components, margin);
        bottomSection.add(entry);
      }

      ConfigurationModel configurationModel = ConfigurationModel(
          id,
          centerTopSectionData,
          topSection,
          bottomSection,
          bottomSectionCanOpen,
          bottomSectionCanExpand,
          draggableSheetMaxHeight: draggableSheetMaxHeight,
          bgColor: bgColor,
          bottomSheetColor: bottomSheetColor,
          stageName: stage,
          constraintName: constraintName,
          taskID: taskID,
          userID: userID,
          configurationInputs: configurationInputs);
      configModel.add(configurationModel);
    }

    return SectionData(configModel, true, stage, constraintName, taskID, userID,
        configurationInputs);
  }

  void setCurrentConfig(String configID, {ConfigurationModel model}) {
    if (configID == "") {
      // model.setSectionData(this);
      this.state = model;
      return;
    } else {
      for (ConfigurationModel configurationModel in allStates) {
        if (configurationModel.ID == configID) {
          // configurationModel.setSectionData(this);
          this.state = configurationModel;
          return;
        }
      }
    }

    throw Exception("config ID $configID not found");
  }

  void setNoConnectionState() {
    setCurrentConfig("", model: defaultState);
  }

  void setInitialState(String configID) {
    setCurrentConfig(configID);
  }
}
