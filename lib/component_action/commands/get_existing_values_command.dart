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
      : super(componentAction, id, "GetExistingValues", "gev", success, failure,
            usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      if (value != null) {
        List data = value[0];
        bool temp = value[1];
        print(this.result);

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
        print(this.result);
      }

      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("GetExistingValues erorr: $e");
      runFailure();
    }
  }
}
