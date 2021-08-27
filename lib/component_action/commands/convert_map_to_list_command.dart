import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class ConvertMapToListCommand extends ComponentActionCommand {
  ConvertMapToListCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "ConvertMapToList", "cmtl", success, failure,
            usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      List val = [];
      print(getValue());
      Map map = getValue()[0];
      map.forEach((key, value) {
        val.add([key, value]);
      });
      this.result = [val];
      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("ConvertMapToList erorr: $e");
      runFailure();
    }
  }
}
