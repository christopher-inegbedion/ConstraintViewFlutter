import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:web_socket_channel/io.dart';

class ListenToConstraintConfigActionCommand extends ComponentActionCommand {
  ListenToConstraintConfigActionCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "ListenToConstraintConfigAction", "ltcca",
            success, failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      IOWebSocketChannel channel = IOWebSocketChannel.connect(
          "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/on_config_change");

      channel.sink.add(jsonEncode({
        "user_id":
            value.length > 0 && getValue()[0] != null && getValue()[0] != ""
                ? getValue()[0]
                : componentAction.viewControllerState.configurationModel.userID,
        "constraint_name":
            value.length > 1 && getValue()[1] != null && getValue()[1] != ""
                ? getValue()[1]
                : componentAction
                    .viewControllerState.configurationModel.constraintName,
        "stage_name": value.length > 2 &&
                getValue()[2] != null &&
                getValue()[2] != ""
            ? getValue()[2]
            : componentAction.viewControllerState.configurationModel.stageName,
        "task_id":
            value.length > 3 && getValue()[3] != null && getValue()[3] != ""
                ? getValue()[3]
                : componentAction.viewControllerState.configurationModel.taskID
      }));

      channel.stream.listen((event) {
        Map<String, dynamic> recvData = jsonDecode(event);
        this.result = [recvData];
        runSuccess();
      }).onError((error) {
        runFailure();
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("ListenToConstraintConfigAction error: $e");
      runFailure();
    }
  }
}
