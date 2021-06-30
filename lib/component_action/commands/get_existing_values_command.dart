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
      List returnVal = [];
      for (String val in value) {
        returnVal.add(componentAction.viewControllerState.savedValues[val]);
      }
      this.result = returnVal;
      print(this.result);
      runSuccess();
    } catch (e) {
      print("GetExistingValues erorr: $e");
      runFailure();
    }
  }
}
