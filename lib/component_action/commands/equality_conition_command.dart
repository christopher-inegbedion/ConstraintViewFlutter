import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class EqualityConditionCommand extends ComponentActionCommand {
  EqualityConditionCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "EqualityCondition", "eq", success, failure,
            usePrevResult, value);

  run(dynamic result) {
    super.run(result);

    try {
      dynamic value1 = value[0];
      dynamic value2 = value[1];

      if (value1 == value2) {
        this.result = [true];
        runSuccess();
      } else {
        this.result = [false];
        runFailure();
      }
    } catch (e) {
      this.result = [false];
      print("EqualityCondition error: $e");
      runFailure();
    }
  }
}
