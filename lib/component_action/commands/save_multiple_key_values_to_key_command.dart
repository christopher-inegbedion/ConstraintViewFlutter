import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class SaveMultipleKeyValuesToKeyCommand extends ComponentActionCommand {
  SaveMultipleKeyValuesToKeyCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "SaveMultipleKeyValuesToKey", "smkvtk",
            success, failure, usePrevResult, value);

  @override
  run(result) {
    super.run(result);

    try {
      String parentKey = value[0];
      bool temp = value[2];
      Map<String, dynamic> storageUsing = temp
          ? componentAction.viewControllerState.tempValues
          : componentAction.viewControllerState.savedValues;

      for (List i in value[1]) {
        String key = i[0];
        dynamic data = i[1];

        if (storageUsing[parentKey] == null) {
          storageUsing[parentKey] = {};
        }
        storageUsing[parentKey][key] = data;
        print(componentAction.viewControllerState.savedValues);
      }

      // componentAction.viewControllerState.notifyChange();
      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("SaveMultipleKeyValuesToKey error: $e");
      runFailure();
    }
  }
}
