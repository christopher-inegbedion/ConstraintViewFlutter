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
      bool temp = value[2];

      var storageUsing = temp
          ? componentAction.viewControllerState.tempValues
          : componentAction.viewControllerState.savedValues;

      if (storageUsing.containsKey(key)) {
        if (data != null) {
          storageUsing[key].add(data);
        }
      } else {
        storageUsing[key] = [];
        if (data != null) {
          storageUsing[key].add(data);
        }
      }
      print(storageUsing);
      this.result = [data];
      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      runFailure();
    }
  }
}
