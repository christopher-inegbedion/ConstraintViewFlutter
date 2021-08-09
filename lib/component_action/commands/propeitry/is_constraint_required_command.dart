import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/utils/network_functions.dart';

class IsConstraintRequiredCommand extends ComponentActionCommand {
  IsConstraintRequiredCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "IsConstraintRequired", "icr", success,
            failure, usePrevResult, value);

  Future<dynamic> getAllConstraints() async {
    Future<dynamic> data = NetworkUtils.performNetworkAction(
        NetworkUtils.serverAddr + NetworkUtils.portNum, "/constraints", "get");

    Map<String, dynamic> parsedData = jsonDecode(await data);
    return parsedData;
  }

  @override
  run(result) {
    super.run(result);

    try {
      String constraintName = getValue()[0];

      getAllConstraints().then((value) {
        List allConstraints = value["constraints"];
        for (Map constraint in allConstraints) {
          if (constraint["constraint_name"] == constraintName) {
            if (constraint["is_configuration_input_required"]) {
              this.result = [true];
              runSuccess();
            } else {
              this.result = [false];
              runFailure();
            }
          }
        }
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("IsConstraintRequired error: $e");
      this.result = [false];
      runFailure();
    }
  }
}
