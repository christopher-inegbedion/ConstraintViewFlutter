import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

class TerminalPrintCommand extends ComponentActionCommand {
  ComponentAction componentAction;
  String id;
  ComponentActionCommand success;
  ComponentActionCommand failure;
  bool usePrevResult;
  List value;

  TerminalPrintCommand(this.componentAction, this.id, this.success,
      this.failure, this.usePrevResult, this.value)
      : super(componentAction, id, "TerminalPrint", "tp", success, failure,
            usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      this.result = null;
      value.forEach((element) {
        print(element);
      });
      runSuccess();
    } catch (e) {
      print("TerminalPrint error: $e");
      runFailure();
    }
  }
}
