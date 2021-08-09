import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class ShowDialogForSingleChoiceCommand extends ComponentActionCommand {
  ShowDialogForSingleChoiceCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "ShowDialogForSingleChoice", "sdfsc",
            success, failure, usePrevResult, value);

  @override
  run(result) {
    super.run(result);
    try {
      String title = getValue()[0];
      List<String> options = getValue()[1];

      componentAction.viewControllerState
          .showDialogForSingleChoice(title, options)
          .then((value) {
        this.result = [value];
        runSuccess();
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("ShowDialogForSingleChoice error: $e");
      runFailure();
    }
  }
}
