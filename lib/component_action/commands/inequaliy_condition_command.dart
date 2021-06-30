import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class InEqualityConditionCommand extends ComponentActionCommand {
  InEqualityConditionCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(componentAction, id, "InEqualityCondition", "iec", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);

    try {
      dynamic value1 = value[0];
      dynamic value2 = value[1];

      if (value1 != value2) {
        this.result = [true];
        runSuccess();
      } else {
        this.result = [false];
        runFailure();
      }
    } catch (e) {
      print("InequalityCondition error: $e");
      this.result = [false];
      runFailure();
    }
  }
}
