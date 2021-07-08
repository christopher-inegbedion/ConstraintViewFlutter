import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class ShowDialogWithInputsCommand extends ComponentActionCommand {
  ShowDialogWithInputsCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "ShowDialogWithInputs", "sdwi", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String title = value[0];
      List inputFields = value[1];
      componentAction.viewControllerState
          .showDialogWithButtons(title, inputFields)
          .then((value) {
        this.result = value;

        runSuccess();
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("ShowDialogWithInputs error: $e");
      runFailure();
    }
  }
}
