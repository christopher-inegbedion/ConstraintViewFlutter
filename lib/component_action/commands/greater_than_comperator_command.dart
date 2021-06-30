import 'package:constraint_view/component_action/component_action_command.dart';

import '../component_action.dart';

class GreaterThanComperatorCommand extends ComponentActionCommand {
  GreaterThanComperatorCommand(
      ComponentAction componentAction,
      String id,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(componentAction, id, "GreaterThanComperator", "gtc", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    int v1 = value[0];
    int v2 = value[1];

    if (v1 > v2) {
      this.result = [true];
      runSuccess();
    } else {
      this.result = [false];
      runFailure();
    }
  }
}
