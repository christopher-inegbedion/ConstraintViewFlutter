import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';

class ButtonComponent extends Component {
  String text;
  String color;
  String requirementFunction;
  List<dynamic> requirementFuncitonArgs;
  String actionFunction;
  List<dynamic> actionFunctionArgs;
  ComponentAlign alignment;

  ButtonComponent(
      String ID,
      ViewMargin margin,
      String text,
      ComponentAlign alignment,
      String requirementFunction,
      List<dynamic> requirementFuncitonArgs,
      String actionFunction,
      List<dynamic> actionFunctionArgs,
      {String color})
      : super(ID, margin, ComponentType.Button) {
    this.text = text;
    this.color = color;
    this.alignment = alignment;
    this.requirementFunction = requirementFunction;
    this.requirementFuncitonArgs = requirementFuncitonArgs;
    this.actionFunction = actionFunction;
    this.actionFunctionArgs = actionFunctionArgs;
  }

  ButtonComponent.forStatic() : super.forStatic();

  @override
  buildComponentView({Function function}) {
    Color backgroundColor;

    if (color != null) {
      backgroundColor = color != null
          ? Color(int.parse(color.replaceAll("#", "0xff")))
          : Colors.white;
    }

    return TextButton(
        onPressed: function,
        child: Text(
          text,
          style: TextStyle(color: backgroundColor),
        ));
  }

  @override
  ButtonComponent buildComponent(List componentParams, bool fromConstraint) {
    String ID = componentParams[0];
    ViewMargin margin = fromConstraint
        ? ViewMargin.fromString(componentParams[1])
        : componentParams[1];
    String text = componentParams[2];
    ComponentAlign alignment = getComponentAlignFromString(componentParams[3]);
    String requirementFunction = componentParams[4];
    List requirementFunctionArgs =
        fromConstraint ? componentParams[5].split(",") : componentParams[5];
    String actionFunction = componentParams[6];
    List actionFunctionArgs =
        fromConstraint ? componentParams[7].split(",") : componentParams[7];
    String color = componentParams[8];

    return ButtonComponent(ID, margin, text, alignment, requirementFunction,
        requirementFunctionArgs, actionFunction, actionFunctionArgs,
        color: color);
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

  @override
  getValue() {
    return text;
  }

  @override
  setValue(value) {
    // TODO: implement setValue
    throw UnimplementedError();
  }
}
