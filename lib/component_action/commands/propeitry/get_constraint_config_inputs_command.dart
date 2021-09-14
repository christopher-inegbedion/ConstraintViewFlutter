import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:web_socket_channel/io.dart';

class GetConstraintConfigInputsCommand extends ComponentActionCommand {
  GetConstraintConfigInputsCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "GetConstraintConfigInputs", "gcci", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      final channel = IOWebSocketChannel.connect(
          "ws://192.168.1.129:4321/get_constraint_config_inputs");

      channel.sink.add(jsonEncode({
        "response": "INPUT_REQUIRED",
        "constraint_name": componentAction
            .viewControllerState.configurationModel.constraintName,
        "stage_name":
            componentAction.viewControllerState.configurationModel.stageName,
        "user_id":
            componentAction.viewControllerState.configurationModel.userID,
        "task_id":
            componentAction.viewControllerState.configurationModel.taskID,
        "data": value
      }));

      channel.stream.first.then((value) {
        Map<String, dynamic> data = jsonDecode(value);
        this.result = [data];
        print(this.result);
        runSuccess();
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("SendDataToWebSocketServer error: $e");
      runFailure();
    }
  }
}
