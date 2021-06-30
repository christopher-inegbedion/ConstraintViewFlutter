import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class AddDataToListComponentCommand extends ComponentActionCommand {
  AddDataToListComponentCommand(
      ComponentAction componentAction,
      String id,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(componentAction, id, "AddDataToListComponent", "adtlc", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String componentID = value[0];
      List data = jsonDecode(jsonEncode(value[1]));
      componentAction.viewControllerState
          .addValueToListComponent(componentID, data);
      runSuccess();
    } catch (e) {
      print("AddDataToListComponent error: $e");
      runFailure();
    }
  }
}
