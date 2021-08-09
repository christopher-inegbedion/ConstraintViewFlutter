import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/utils/network_functions.dart';

class SubmitTaskRegistrationDataCommand extends ComponentActionCommand {
  SubmitTaskRegistrationDataCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "SubmitTaskRegistrationData", "strd",
            success, failure, usePrevResult, value);

  @override
  run(result) {
    super.run(result);
    try {
      String taskName = getValue()[0];
      String taskDesc = getValue()[1];
      String stageGroupID = getValue()[2];

      dynamic data = {
        "task_name": taskName,
        "task_desc": taskDesc,
        "stage_group_id": stageGroupID
      };

      Future<dynamic> response = NetworkUtils.performNetworkAction(
          NetworkUtils.serverAddr + NetworkUtils.portNum,
          "/create_task",
          "post",
          data: data);
      response.then((value) {
        Map result = jsonDecode(value);
        print(result);
        this.result = [result["task_id"]];
      }).onError((error, stackTrace) {
        runFailure();
      }).whenComplete(() {
        runSuccess();
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("SubmitTaskRegistrationData error: $e");
      runFailure();
    }
  }
}
