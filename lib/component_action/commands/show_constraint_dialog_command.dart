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
      : super(id, componentAction, "ShowConstraintDialog", "scd", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String constraintName = getValue()[0] + "_config";
      String stageName = getValue()[1];
      bool showDoneBtn = getValue().length < 3 ? true : getValue()[2];
      componentAction.viewControllerState
          .showConstraintInDialog(constraintName, stageName, showDoneBtn)
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
