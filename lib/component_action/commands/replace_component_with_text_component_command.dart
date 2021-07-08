import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/models/margin_model.dart';

class ReplaceComponentWithTextComponentCommand extends ComponentActionCommand {
  ReplaceComponentWithTextComponentCommand(
      String id,
      ComponentAction componentAction,
      ComponentActionCommand success,
      ComponentActionCommand failure,
      bool usePrevResult,
      List value)
      : super(id, componentAction, "ReplaceComponentWithTextComponentCommand",
            "rcwtc", success, failure, usePrevResult, value);

  @override
  run(dynamic result) {
    super.run(result);
    try {
      String id = value[0];
      ViewMargin margin = ViewMargin(
        double.parse(value[1][0].toString()),
        double.parse(value[1][1].toString()),
        double.parse(value[1][2].toString()),
        double.parse(value[1][3].toString()),
      );
      String placeholder = value[2];
      String align = value[3];
      double textSize = double.parse(value[4].toString());
      String textColor = value[5];

      TextComponent textComponent = TextComponent(id, margin, placeholder,
          getComponentAlignFromString(align), textSize, textColor);
      componentAction.viewControllerState.changeComponent(id, textComponent);
      runSuccess();
    } catch (e) {
      print("ReplaceComponentWithTextComponent error: $e");
      runFailure();
    }
  }

  ComponentAlign getComponentAlignFromString(String componentAlign) {
    switch (componentAlign) {
      case "center":
        return ComponentAlign.center;
      case "left":
        return ComponentAlign.left;
      case "right":
        return ComponentAlign.right;
      default:
        return null;
    }
  }
}
