import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class AddDataToListComponentCommand extends ComponentActionCommand {
  AddDataToListComponentCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "AddDataToListComponent", "adtlc", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String componentID = getValue()[0];
      List data = jsonDecode(jsonEncode(getValue()[1]));

      componentAction.viewControllerState
          .addValueToListComponent(componentID, data);

      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("AddDataToListComponent error: $e");
      runFailure();
    }
  }
}
