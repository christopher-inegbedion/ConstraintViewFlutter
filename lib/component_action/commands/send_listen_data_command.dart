import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:web_socket_channel/io.dart';

class SendListenDataCommand extends ComponentActionCommand {
  SendListenDataCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "SendListenData", "sld", success, failure,
            usePrevResult, value);

  @override
  run(result) {
    super.run(result);
    try {
      String commandMsg = getValue()[0];
      dynamic commandData = getValue()[1];

      IOWebSocketChannel channel = IOWebSocketChannel.connect(
          "ws://${NetworkUtils.websocketAddr}:${NetworkUtils.websocketPortNum}/send_listen_data");

      channel.sink.add(jsonEncode({
        "user_id":
            value.length > 2 && getValue()[2] != null && getValue()[2] != ""
                ? getValue()[2]
                : componentAction.viewControllerState.configurationModel.userID,
        "constraint_name":
            value.length > 3 && getValue()[3] != null && getValue()[3] != ""
                ? getValue()[3]
                : componentAction
                    .viewControllerState.configurationModel.constraintName,
        "stage_name": value.length > 4 &&
                getValue()[4] != null &&
                getValue()[4] != ""
            ? getValue()[4]
            : componentAction.viewControllerState.configurationModel.stageName,
        "task_id":
            value.length > 5 && getValue()[5] != null && getValue()[5] != ""
                ? getValue()[5]
                : componentAction.viewControllerState.configurationModel.taskID,
        "command_msg": commandMsg,
        "command_data": commandData
      }));

      channel.stream.listen((event) {
        Map<String, dynamic> recvData = jsonDecode(event);
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("SendListenData error: $e");
      runFailure();
    }
  }
}
