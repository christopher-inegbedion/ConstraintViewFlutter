import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class CloseDialogCommand extends ComponentActionCommand {
  CloseDialogCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "CloseDialogCommand", "cd", success, failure,
            usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      componentAction.viewControllerState.closeDialog();
    } catch (e, stacktrace) {
      print(stacktrace);
      runFailure();
    }
  }
}
