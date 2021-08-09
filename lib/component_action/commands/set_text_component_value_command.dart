import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class SetTextComponentValueCommand extends ComponentActionCommand {
  SetTextComponentValueCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "SetTextComponentValue", "stcv", success,
            failure, usePrevResult, value);

  @override
  run(result) {
    super.run(result);
    try {
      List strings = getValue()[0];
      String id = getValue()[1];

      String newString = "";
      for (String s in strings) {
        print(formatText(s, result).toString());
        newString = newString + formatText(s, result).toString();
      }
      componentAction.viewControllerState.setComponentValue(id, newString);
    } catch (e, stacktrace) {
      print(stacktrace);
      print("SetTextComponentValue error: $e");
      runFailure();
    }
  }
}
