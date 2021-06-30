import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class GetComponentListDetails extends ComponentActionCommand {
  GetComponentListDetails(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(componentAction, id, "GetComponentListIndex", "gcli", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      this.result = [
        componentAction.commandInitiator.dataIndex,
        componentAction.commandInitiator.componentIndex,
        componentAction.commandInitiator.parentListIndex
      ];
      runSuccess();
    } catch (e) {
      print(e);
      runFailure();
    }
  }
}
