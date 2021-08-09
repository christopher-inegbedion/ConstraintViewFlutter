import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/models/component_model.dart';

class ChangeTextColorCommand extends ComponentActionCommand {
  ChangeTextColorCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "ChangeTextColor", "ctc", success, failure,
            usePrevResult, value);

  @override
  run(result) {
    super.run(result);
    try {
      String id = getValue()[0];
      String color = getValue()[1];

      TextComponent component =
          componentAction.viewControllerState.getComponentFromID(id);
      componentAction.viewControllerState.setTextColor(component, color);
      runSuccess();
    } catch (error, stacktrace) {
      print(stacktrace);
      print("ChangeTextColor error: $error");
      runFailure();
    }
  }
}
