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
      : super(componentAction, id, "GetComponentFromList", "gcfl", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String componentID = value[0];
      int dataIndex = value[1];
      int componentIndex = value[2];

      Component component = componentAction.viewControllerState
          .getComponentFromList(componentID, dataIndex, componentIndex);
      this.result = [component.ID];
      runSuccess();
    } catch (e) {
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