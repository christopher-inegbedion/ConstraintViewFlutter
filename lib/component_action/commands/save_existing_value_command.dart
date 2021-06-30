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
    String key = value[0];
    String valueToSave = result[0];

    componentAction.viewControllerState.savedValues[key] = valueToSave;
    print(componentAction.viewControllerState.savedValues);
    runSuccess();
  }
}
