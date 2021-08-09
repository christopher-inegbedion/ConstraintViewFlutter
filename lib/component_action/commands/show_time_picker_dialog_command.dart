import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:flutter/material.dart';

class ShowTimePickerDialogCommand extends ComponentActionCommand {
  ShowTimePickerDialogCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "ShowTimePickerDialog", "stpd", success,
            failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    int hour;
    int minute;
    String period;
    try {
      componentAction.viewControllerState
          .showTimeSelector()
          .then((TimeOfDay value) {
        hour = value.hour;
        minute = value.minute;
        if (value.period == DayPeriod.am) {
          period = "am";
        } else {
          period = "pm";
        }
        this.result = [hour, minute, period];
        runSuccess();
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("ShowTimePickerDialog error $e");
      runFailure();
    }
  }
}
