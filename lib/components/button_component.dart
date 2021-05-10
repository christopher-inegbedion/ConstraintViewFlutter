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
      Margin margin,
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
  ButtonComponent buildComponent(List componentParams) {
    String ID = componentParams[0];
    Margin margin = componentParams[1];
    String text = componentParams[2];
    ComponentAlign alignment = componentParams[3];
    String requirementFunction = "";
    List requirementFunctionArgs = [];
    String actionFunction = "";
    List actionFunctionArgs = [];
    String color = componentParams[8];

    return ButtonComponent(ID, margin, text, alignment, requirementFunction,
        requirementFunctionArgs, actionFunction, actionFunctionArgs,
        color: color);
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
