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
      : super(id, componentAction, "SaveExistingValueToList", "sevtl", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String key = getValue()[0];
      dynamic data = getValue()[1];
      bool temp = getValue()[2];
      print(data);

      var storageUsing = temp
          ? componentAction.viewControllerState.tempValues
          : componentAction.viewControllerState.savedValues;

      if (storageUsing.containsKey(key)) {
        if (data != null) {
          if (data is List) {
            for (dynamic i in data) {
              storageUsing[key].add(i);
            }
          } else {
            storageUsing[key].add(data);
          }
        }
      } else {
        storageUsing[key] = [];
        if (data != null) {
          if (data is List) {
            for (dynamic i in data) {
              storageUsing[key].add(i);
            }
          } else {
            storageUsing[key].add(data);
          }
        }
      }

      this.result = [data];

      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("SaveExistingValueToList error: $e");
      runFailure();
    }
  }
}
