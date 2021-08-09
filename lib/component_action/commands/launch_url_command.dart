import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlCommand extends ComponentActionCommand {
  LaunchUrlCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "LaunchUrl", "lu", success, failure,
            usePrevResult, value);

  @override
  run(result) {
    super.run(result);
    try {
      String link = formatText(getValue()[0], result);
      canLaunch("https://" + link).then((value) {
        if (value) {
          launch("https://" + link);
        } else {
          runFailure();
        }
      }).whenComplete(() {
        runSuccess();
      });
    } catch (e, stacktrace) {
      print(stacktrace);
      print("LaunchUrl error: $e");
      runFailure();
    }
  }
}
