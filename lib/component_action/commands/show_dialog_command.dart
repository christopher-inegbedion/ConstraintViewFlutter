import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class ShowDialogCommand extends ComponentActionCommand {
  ShowDialogCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "ShowDialogCommand", "sdc", success, failure,
            usePrevResult, value);

  @override
  run(dynamic result) {
    String title = value[0];
    String msg = value[1];
    try {
      componentAction.viewControllerState.showDialogWithMsg(title, msg);
      runSuccess();
    } catch (e) {
      runFailure();
    }
  }
}
