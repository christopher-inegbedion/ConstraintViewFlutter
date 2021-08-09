import 'dart:convert';

import 'package:constraint_view/components/button_component.dart';
import 'package:constraint_view/components/dropdown_component.dart';
import 'package:constraint_view/components/image_component.dart';
import 'package:constraint_view/components/input_field_component.dart';
import 'package:constraint_view/components/list_component.dart';
import 'package:constraint_view/components/list_tile_component.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/configuration_model.dart';
import 'package:constraint_view/utils/network_functions.dart';

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
        ViewMargin margin = ViewMargin.fromString(topSectionEntry["margin"]);

        List<Component> components = [];
        for (Map component in topSectionEntry["components"]) {
          components.add(parseComponentFromList(component));
        }
        ConfigEntry entry = ConfigEntry(components, margin);
        topSection.add(entry);
      }

      List<ConfigEntry> bottomSection = [];
      for (Map bottomSectionEntry in configModelMap["bottom_section"]) {
        // List entryMarginArray = bottomSectionEntry["margin"].split(",");
        // print(entryMarginArray[0]);
        ViewMargin margin = ViewMargin.fromString(bottomSectionEntry["margin"]);
        List<Component> components = [];
        for (Map component in bottomSectionEntry["components"]) {
          components.add(parseComponentFromList(component));
        }
        ConfigEntry entry = ConfigEntry(components, margin);
        bottomSection.add(entry);
      }

      List<Map> topViewCommand = [];
      if (configModelMap["top_view_command"] != null) {
        for (Map function in configModelMap["top_view_command"]) {
          topViewCommand.add(function);
        }
      } else {
        topViewCommand = null;
      }

      List<Map> bottomViewCommand = [];
      if (configModelMap["bottom_view_command"] != null) {
        for (Map function in configModelMap["bottom_view_command"]) {
          bottomViewCommand.add(function);
        }
      } else {
        bottomViewCommand = null;
      }

      // List bottomViewCommand = configModelMap["bottom_view_command"];
      print("topViewCommand $topViewCommand");

      ConfigurationModel configurationModel = ConfigurationModel(
          id,
          centerTopSectionData,
          topSection,
          bottomSection,
          bottomSectionCanOpen,
          bottomSectionCanExpand,
          topViewCommand: topViewCommand,
          bottomViewCommand: bottomViewCommand,
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

  static Component parseComponentFromList(Map component) {
    switch (component["type"]) {
      case "text":
        return TextComponent.forStatic()
            .buildComponent(component["component_properties"], true);
        break;
      case "input":
        return InputFieldComponent.forStatic()
            .buildComponent(component["component_properties"], true);
        break;
      case "image":
        return ImageComponent.forStatic()
            .buildComponent(component["component_properties"], true);
        break;

      case "button":
        return ButtonComponent.forStatic()
            .buildComponent(component["component_properties"], true);
        break;
      case "list":
        return ListComponent.forStatic()
            .buildComponent(component["component_properties"], true);
        break;
      case "list_tile":
        return ListTileComponent.forStatic()
            .buildComponent(component["component_properties"], true);
        break;
      case "dropdown":
        return DropdownComponent.forStatic()
            .buildComponent(component["component_properties"], true);
        break;

      default:
        throw Exception(
            "Component with ID: [${component['component_properties'][0]}] of type: [${component["type"]}] has not been built from SectionData");
    }
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
    // print(this.configurationInputs);
  }

  Map<String, dynamic> toJson() {
    List view = [];
    for (ConfigurationModel configurationModel in allStates) {
      view.add(configurationModel.toJson());
    }
    return {"constraint_name": constraintName, "view": view};
  }
}
