import 'dart:convert';

import 'package:constraint_view/component_action/commands/add_data_to_list_component_command.dart';
import 'package:constraint_view/component_action/commands/component_value_command.dart';
import 'package:constraint_view/component_action/commands/get_component_from_list_command.dart';
import 'package:constraint_view/component_action/commands/get_component_list_details_command.dart';
import 'package:constraint_view/component_action/commands/greater_than_comperator_command.dart';
import 'package:constraint_view/component_action/commands/save_existing_value_command.dart';
import 'package:constraint_view/component_action/commands/set_component_value_command.dart';
import 'package:constraint_view/component_action/commands/show_dialog_command.dart';
import 'package:constraint_view/component_action/commands/terminal_print_command.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/view_controller.dart';

class ComponentAction {
  ComponentActionCommand command;
  Map jsonCommand;
  ViewControllerState viewControllerState;
  Component commandInitiator;

  ComponentAction(
      this.viewControllerState, this.commandInitiator, this.command);

  ComponentAction.fromJson(ViewControllerState viewControllerState,
      Component commandInitiator, Map jsonCommand) {
    this.viewControllerState = viewControllerState;
    this.commandInitiator = commandInitiator;
    this.command = buildCommandFromJSON(jsonCommand);
  }

  ComponentActionCommand buildCommandFromJSON(Map data) {
    Map newData = data;
    String name = newData["commandName"];
    Map successData = newData["success"];
    Map failureData = newData["failure"];
    bool usePrevResult = newData["usePrevResult"];
    List value = newData["value"];

    if (successData == null) {
      if (failureData == null) {
        return _getActionCommandFromName(
            this, name, "id", null, null, usePrevResult, value);
      } else {
        return _getActionCommandFromName(this, name, "id", null,
            buildCommandFromJSON(failureData), usePrevResult, value);
      }
    } else {
      if (failureData == null) {
        return _getActionCommandFromName(this, name, "id",
            buildCommandFromJSON(successData), null, usePrevResult, value);
      } else {
        return _getActionCommandFromName(
            this,
            name,
            "id",
            buildCommandFromJSON(successData),
            buildCommandFromJSON(failureData),
            usePrevResult,
            value);
      }
    }
  }

  ComponentActionCommand _getActionCommandFromName(
      ComponentAction componentAction,
      String commandName,
      String id,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value) {
    switch (commandName) {
      case "gtc":
        return GreaterThanComperatorCommand(
            componentAction, id, success, failure, usePrevResult, value);
        break;
      case "tp":
        return TerminalPrintCommand(
            componentAction, id, success, failure, usePrevResult, value);
      case "cv":
        return ComponentValue(
            componentAction, id, success, failure, usePrevResult, value);
        break;
      case "sdc":
        return ShowDialogCommand(
            componentAction, id, success, failure, usePrevResult, value);
        break;
      case "sev":
        return SaveExistingValueCommand(
            componentAction, id, success, failure, usePrevResult, value);
        break;
      case "scv":
        return SetComponentValueCommand(
            componentAction, id, success, failure, usePrevResult, value);
        break;
      case "adtlc":
        return AddDataToListComponentCommand(
            componentAction, id, success, failure, usePrevResult, value);
        break;
      case "gcld":
        return GetComponentListDetails(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "gcfl":
        return GetComponentFromListCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;

      default:
        return null;
    }
  }

  Map data = {
    "commandName": "gtc",
    "success": {
      "commandName": "tp",
      "success": null,
      "failure": null,
      "value": ["success"]
    },
    "failure": {
      "commandName": "tp",
      "success": null,
      "failure": null,
      "value": ["failure"]
    },
    "value": [2, 3]
  };

  void start() {
    if (command != null) {
      command.run(null);
    }
  }
}
