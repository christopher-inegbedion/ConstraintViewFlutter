import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class GetExistingValuesCommand extends ComponentActionCommand {
  GetExistingValuesCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "GetExistingValues", "gev", success, failure,
            usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      if (value != null) {
        List data = getValue()[0];
        bool temp = getValue()[1];

        var storageUsing = temp
            ? componentAction.viewControllerState.tempValues
            : componentAction.viewControllerState.savedValues;
        List returnVal = [];
        for (String val in data) {
          returnVal.add(storageUsing[val]);
        }
        this.result = returnVal;
      } else {
        this.result = componentAction.viewControllerState.savedValues.isEmpty
            ? null
            : componentAction.viewControllerState.savedValues;
      }

      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("GetExistingValues erorr: $e");
      runFailure();
    }
  }
}
