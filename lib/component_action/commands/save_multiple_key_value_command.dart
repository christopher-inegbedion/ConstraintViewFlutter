import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class SaveMultipleKeyValueCommand extends ComponentActionCommand {
  SaveMultipleKeyValueCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "SaveMultipleKeyValue", "smv", success,
            failure, usePrevResult, value);

  @override
  run(result) {
    super.run(result);

    try {
      bool temp = getValue()[1];

      var storageUsing = temp
          ? componentAction.viewControllerState.tempValues
          : componentAction.viewControllerState.savedValues;

      for (List pair in getValue()[0]) {
        String key = pair[0];
        dynamic data = pair[1];

        storageUsing[key] = data;
      }

      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("SaveMultipleKeyValue error: $e");
      runFailure();
    }
  }
}
