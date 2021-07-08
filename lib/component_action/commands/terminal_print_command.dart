import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';

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
