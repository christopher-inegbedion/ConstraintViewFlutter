import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class GetExistingValueFromListCommand extends ComponentActionCommand {
  GetExistingValueFromListCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "GetExistingValueFromList", "gevfl", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String key = getValue()[0];
      int index = int.parse(getValue()[1].toString());
      bool temp = getValue()[2];

      var storageUsing = temp
          ? componentAction.viewControllerState.tempValues
          : componentAction.viewControllerState.savedValues;

      dynamic data = storageUsing[key][index];
      this.result = [data];
      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("GetExistingValueFromList error: $e");
      runFailure();
    }
  }
}
