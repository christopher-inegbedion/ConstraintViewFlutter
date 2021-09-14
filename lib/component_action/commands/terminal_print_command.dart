import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/models/component_model.dart';

class TerminalPrintCommand extends ComponentActionCommand {
  String id;
  ComponentAction componentAction;
  ComponentActionCommand success;
  ComponentActionCommand failure;
  bool usePrevResult;
  List value;

  TerminalPrintCommand(this.id, this.componentAction, this.success,
      this.failure, this.usePrevResult, this.value)
      : super(id, componentAction, "TerminalPrint", "tp", success, failure,
            usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      // componentAction.viewControllerState.builtComponents.forEach((key, value) {
      //   Component val = value;
      //   print(val.getValue());
      // });

      runSuccess();
    } catch (e, stacktrace) {
      print(stacktrace);
      print("TerminalPrint error: $e");
      runFailure();
    }
  }
}
