import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class SetComponentValueCommand extends ComponentActionCommand {
  SetComponentValueCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "SetComponentValue", "scv", success, failure,
            usePrevResult, value);

  @override
  run(dynamic result) {
    String id = getValue()[0];
    String valueToSet = getValue()[1];

    componentAction.viewControllerState.setComponentValue(id, valueToSet);
  }
}
