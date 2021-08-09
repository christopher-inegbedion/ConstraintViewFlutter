import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class RemoveConstraintFromSelectionCommand extends ComponentActionCommand {
  RemoveConstraintFromSelectionCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "RemoveConstraintFromSelection", "rcfs",
            success, failure, usePrevResult, value);

  @override
  run(result) {
    super.run(result);

    try {
      String constraintName = getValue()[0];
      String stageName = getValue()[1];

      var storageUsing = componentAction.viewControllerState.savedValues;

      if (storageUsing.containsKey(stageName)) {
        List stageConstraints = storageUsing[stageName];
        if (stageConstraints.length > 0) {
          stageConstraints.removeWhere((i) {
            Map constraint = i;
            if (constraint["constraint_name"] == constraintName) {
              return true;
            }
            return false;
          });
          runSuccess();
        }
      } else {
        runFailure();
      }
    } catch (e, stacktrace) {
      print(stacktrace);
      print("RemoveConstraintFromSelection error: $e");
      runFailure();
    }
  }
}
