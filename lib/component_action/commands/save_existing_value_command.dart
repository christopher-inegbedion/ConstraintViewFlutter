import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class SaveExistingValueCommand extends ComponentActionCommand {
  SaveExistingValueCommand(
      ComponentAction componentAction,
      String id,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(componentAction, id, "SaveExistingValue", "sev", success, failure,
            usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String key = value[0];
      String valueToSave = value[1].toString();
      bool temp = value[2];

      var storageUsing = temp
          ? componentAction.viewControllerState.tempValues
          : componentAction.viewControllerState.savedValues;

      storageUsing[key] = valueToSave;

      this.result = [valueToSave];
      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("SaveExistingValue error: $e");
      runFailure();
    }
  }
}
