import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class GetComponentListDetailCommand extends ComponentActionCommand {
  GetComponentListDetailCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "GetComponentListDetail", "gcld", success,
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
    } catch (e, stracktrace) {
      print(stracktrace);
      print("GetComponentListDetail error: $e");
      runFailure();
    }
  }
}
