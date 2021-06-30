import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class ComponentValue extends ComponentActionCommand {
  ComponentValue(
      ComponentAction componentAction,
      String id,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(componentAction, id, "ComponentValue", "cv", success, failure,
            usePrevResult, value);

  @override
  void run(dynamic result) {
    super.run(result);
    String componentID = value[0];
    try {
      this.result = [
        componentAction.viewControllerState.getComponentValue(componentID)
      ];
      runSuccess();
    } catch (e) {
      runFailure();
    }
  }
}
