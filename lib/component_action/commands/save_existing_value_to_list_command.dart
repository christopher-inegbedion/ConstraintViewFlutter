import 'package:constraint_view/component_action/component_action.dart';

import '../component_action_command.dart';

class SaveExistingValueToListCommand extends ComponentActionCommand {
  SaveExistingValueToListCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(componentAction, id, "SaveExistingValueToList", "sevtl", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String key = value[0];
      String data = value[1];

      if (componentAction.viewControllerState.savedValues.containsKey(key)) {
        componentAction.viewControllerState.savedValues[key].add(data);
      } else {
        componentAction.viewControllerState.savedValues[key] = [];
        componentAction.viewControllerState.savedValues[key].add(data);
      }
      this.result = [data];
      print(componentAction.viewControllerState.savedValues);
      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      runFailure();
    }
  }
}
