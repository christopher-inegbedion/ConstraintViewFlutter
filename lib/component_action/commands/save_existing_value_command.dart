import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class SaveExistingValueCommand extends ComponentActionCommand {
  SaveExistingValueCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "SaveExistingValue", "sev", success, failure,
            usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String key = getValue()[0];
      dynamic valueToSave = getValue()[1];
      bool temp = getValue()[2];

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
