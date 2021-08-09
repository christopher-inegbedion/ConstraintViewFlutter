import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class SaveValueCommand extends ComponentActionCommand {
  SaveValueCommand(
      ComponentAction componentAction,
      String id,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "SaveValueCommand", "svc", success, failure,
            usePrevResult, value);

  run(dynamic result) {
    super.run(result);
    dynamic valueToSave = getValue()[0];
    componentAction.viewControllerState.savedValues["value"] = valueToSave;
    print(componentAction.viewControllerState.savedValues);
    runSuccess();
  }
}
