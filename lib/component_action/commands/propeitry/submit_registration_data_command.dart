import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/utils/network_functions.dart';

class SubmitRegistrationDataCommand extends ComponentActionCommand {
  SubmitRegistrationDataCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "SubmitRegistrationData", "srd", success,
            failure, usePrevResult, value);

  @override
  run(result) {
    super.run(result);
    try {
      dynamic data = {"stages": getValue()[0]};
      print(data);
      Future<dynamic> response = NetworkUtils.performNetworkAction(
          NetworkUtils.serverAddr + NetworkUtils.portNum,
          "/stage_group",
          "post",
          data: jsonEncode(data));
      response.then((value) {
        Map result = jsonDecode(value);
        if (result["result"] == "success") {
          this.result = [result["msg"]];
        } else {
          this.result = [""];
        }
      }).onError((error, stackTrace) {
        runFailure();
      }).whenComplete(() {
        runSuccess();
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("SubmitRegistrationData error: $e");
      runFailure();
    }
  }
}