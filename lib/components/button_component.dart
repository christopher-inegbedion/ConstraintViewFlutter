import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';

class ButtonComponent extends Component {
  String text;
  String color;
  Map actionCommand;
  ComponentAlign alignment;

  ButtonComponent(String ID, ViewMargin margin, String text,
      ComponentAlign alignment, Map actionCommand,
      {String color})
      : super(ID, margin, ComponentType.Button) {
    this.text = text;
    this.color = color;
    this.alignment = alignment;
    this.actionCommand = actionCommand;
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
  ButtonComponent buildComponent(List componentParams, bool fromConstraint, {bool replaceComponent=false}) {
    String ID = componentParams[0];
    ViewMargin margin = fromConstraint
        ? ViewMargin.fromString(componentParams[1])
        : componentParams[1];
    String text = componentParams[2];
    ComponentAlign alignment = getComponentAlignFromString(componentParams[3]);
    String color = componentParams[5];

    return ButtonComponent(ID, margin, text, alignment, componentParams[4],
        color: color);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "button",
      "component_properties": [
        ID,
        margin.toString(),
        text,
        componentAlignToString(alignment),
        actionCommand,
        color
      ]
    };
  }

  @override
  getValue() {
    return this.text;
  }

  @override
  setValue(value) {
    this.text = value;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
