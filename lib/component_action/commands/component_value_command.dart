import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class ComponentValue extends ComponentActionCommand {
  ComponentValue(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "ComponentValue", "cv", success, failure,
            usePrevResult, value);

  @override
  void run(dynamic result) {
    super.run(result);

    try {
      List results = [];
      for (String id in value) {
        results.add(componentAction.viewControllerState.getComponentValue(id));
      }

      this.result = results;
      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("ComponentValue error: $e");
      runFailure();
    }
  }
}
