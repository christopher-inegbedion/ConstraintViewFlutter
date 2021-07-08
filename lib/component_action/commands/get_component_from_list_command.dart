import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/models/component_model.dart';

class GetComponentFromListCommand extends ComponentActionCommand {
  GetComponentFromListCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "GetComponentFromList", "gcfl", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String componentID = value[0];
      int dataIndex = int.parse(value[1].toString());
      int componentIndex = value[2];

      Component component = componentAction.viewControllerState
          .getComponentFromListWithIndex(
              componentID, dataIndex, componentIndex);
      this.result = [component.ID];
      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("GetComponentFromList error: $e");
      runFailure();
    }
    // String data = "klsdnlksdnf";
    // // print(dataIndex);
    // print(component.ID);
    // componentAction.viewControllerState
    //     .addValueToListComponent(component.ID, ["data"]);
    // print(component);
  }
}
