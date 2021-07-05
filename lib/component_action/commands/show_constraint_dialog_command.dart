import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class ShowConstraintDialogCommand extends ComponentActionCommand {
  ShowConstraintDialogCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(componentAction, id, "ShowConstraintDialog", "scd", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String constraintName = value[0];
      String stageName = value[1];
      componentAction.viewControllerState
          .showConstraintInDialog(constraintName, stageName)
          .then((value) {
        this.result = value;

        runSuccess();
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("ShowConstraintDialog error: $e");
      runFailure();
    }
  }
}
