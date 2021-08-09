import 'dart:convert';

import 'package:constraint_view/component_action/commands/add_data_to_list_component_command.dart';
import 'package:constraint_view/component_action/commands/change_text_color_command.dart';
import 'package:constraint_view/component_action/commands/close_dialog_command.dart';
import 'package:constraint_view/component_action/commands/component_value_command.dart';
import 'package:constraint_view/component_action/commands/equality_conition_command.dart';
import 'package:constraint_view/component_action/commands/get_component_from_list_command.dart';
import 'package:constraint_view/component_action/commands/get_component_list_details.dart';
import 'package:constraint_view/component_action/commands/get_existing_value_from_list_command.dart';
import 'package:constraint_view/component_action/commands/get_existing_values_command.dart';
import 'package:constraint_view/component_action/commands/launch_url_command.dart';
import 'package:constraint_view/component_action/commands/listen_to_constraint_config_action_command.dart';
import 'package:constraint_view/component_action/commands/parse_map_command.dart';
import 'package:constraint_view/component_action/commands/propeitry/is_constraint_required_command.dart';
import 'package:constraint_view/component_action/commands/propeitry/remove_constraint_from_selection_command.dart';
import 'package:constraint_view/component_action/commands/propeitry/submit_registration_data_command.dart';
import 'package:constraint_view/component_action/commands/propeitry/submit_task_registration_data_command.dart';
import 'package:constraint_view/component_action/commands/replace_component_with_text_component_command.dart';
import 'package:constraint_view/component_action/commands/save_existing_value_command.dart';
import 'package:constraint_view/component_action/commands/save_existing_value_to_list_command.dart';
import 'package:constraint_view/component_action/commands/save_multiple_key_value_command.dart';
import 'package:constraint_view/component_action/commands/save_multiple_key_values_to_key_command.dart';
import 'package:constraint_view/component_action/commands/send_data_to_ws_server_command.dart';
import 'package:constraint_view/component_action/commands/send_listen_data_command.dart';
import 'package:constraint_view/component_action/commands/set_component_value_command.dart';
import 'package:constraint_view/component_action/commands/set_text_component_value_command.dart';
import 'package:constraint_view/component_action/commands/show_constraint_dialog_command.dart';
import 'package:constraint_view/component_action/commands/show_dialog_command.dart';
import 'package:constraint_view/component_action/commands/show_dialog_for_single_choice_command.dart';
import 'package:constraint_view/component_action/commands/show_dialog_with_inputs_command.dart';
import 'package:constraint_view/component_action/commands/show_time_picker_dialog_command.dart';
import 'package:constraint_view/component_action/commands/terminal_print_command.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/view_controller.dart';

import 'commands/inequaliy_condition_command.dart';

class ComponentAction {
  ComponentActionCommand initialCommand;
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
    this.initialCommand = command;
    this.command = buildCommandFromJSON(jsonCommand);
  }

  ComponentActionCommand buildCommandFromJSON(Map data) {
    String name = data["commandName"];
    final Map successData = jsonDecode(jsonEncode(data["success"]));
    final Map failureData = jsonDecode(jsonEncode(data["failure"]));
    bool usePrevResult = data["usePrevResult"];
    final List value = jsonDecode(jsonEncode(data["value"]));

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
      case "tp":
        return TerminalPrintCommand(
            id, componentAction, success, failure, usePrevResult, value);
      case "cv":
        return ComponentValue(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "sdc":
        return ShowDialogCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "sev":
        return SaveExistingValueCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "scv":
        return SetComponentValueCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "adtlc":
        return AddDataToListComponentCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "gcld":
        return GetComponentListDetailCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "gcfl":
        return GetComponentFromListCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "eq":
        return EqualityConditionCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "iec":
        return InEqualityConditionCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "rcwtc":
        return ReplaceComponentWithTextComponentCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "gev":
        return GetExistingValuesCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "sdwi":
        return ShowDialogWithInputsCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "cd":
        return CloseDialogCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "sevtl":
        return SaveExistingValueToListCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "gevfl":
        return GetExistingValueFromListCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "sdtwss":
        return SendDataToWebSocketServerCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "scd":
        return ShowConstraintDialogCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "icr":
        return IsConstraintRequiredCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "smv":
        return SaveMultipleKeyValueCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "smkvtk":
        return SaveMultipleKeyValuesToKeyCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "srd":
        return SubmitRegistrationDataCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "rcfs":
        return RemoveConstraintFromSelectionCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "strd":
        return SubmitTaskRegistrationDataCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "lu":
        return LaunchUrlCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "stpd":
        return ShowTimePickerDialogCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "stcv":
        return SetTextComponentValueCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "sdfsc":
        return ShowDialogForSingleChoiceCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "ltcca":
        return ListenToConstraintConfigActionCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "pmc":
        return ParseMapCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "sld":
        return SendListenDataCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;
      case "ctc":
        return ChangeTextColorCommand(
            id, componentAction, success, failure, usePrevResult, value);
        break;

      default:
        return null;
    }
  }

  void start() {
    if (command != null) {
      command.run(null);
    }
  }

  void reset() {
    this.command = null;
    print(this.command);
  }
}
