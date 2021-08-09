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
    super.run(result);
    try {
      String title = getValue()[0];
      String msg = getValue()[1];
      componentAction.viewControllerState.showDialogWithMsg(title, msg);
      print(result);
      runSuccess();
    } catch (e) {
      runFailure();
    }
  }
}
