import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class ParseMapCommand extends ComponentActionCommand {
  ParseMapCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "ParseMap", "pmc", success, failure,
            usePrevResult, value);

  @override
  run(result) {
    super.run(result);
    try {
      List<String> keys = getValue()[0];
      Map data = getValue()[1];
      print(data);

      dynamic tempData = data;
      for (String key in keys) {
        if (key != "" || key != null) {
          tempData = tempData[key];
        }
      }

      this.result = [tempData];
      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("ParseMap error: $e");
      runFailure();
    }
  }
}
