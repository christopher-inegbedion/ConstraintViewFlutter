import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class TextComponent extends Component {
  String ID;
  ViewMargin margin;
  String placeholder;
  ComponentAlign textComponentAlign;
  double textSize;
  String textColor;

  TextComponent(String ID, ViewMargin margin, String placeholder,
      ComponentAlign textComponentAlign, double textSize, String textColor)
      : super(ID, margin, ComponentType.Text) {
    this.ID = ID;
    this.margin = margin;
    this.placeholder = placeholder;
    this.textComponentAlign = textComponentAlign;
    this.textSize = textSize;
    this.textColor = textColor;
  }

  TextComponent.forStatic() : super.forStatic();

  static TextAlign getTextAlignment(ComponentAlign align) {
    return align == ComponentAlign.center
        ? TextAlign.center
        : align == ComponentAlign.left
            ? TextAlign.left
            : align == ComponentAlign.right
                ? TextAlign.right
                : TextAlign.center;
  }

  @override
  Widget buildComponentView() {
    return Text(
      this.placeholder,
      style: TextStyle(
          fontSize: this.textSize,
          fontFamily: "JetBrainMono",
          color: HexColor(textColor)),
      textAlign: TextComponent.getTextAlignment(this.textComponentAlign),
    );
  }

  @override
  TextComponent buildComponent(List componentParams, bool fromConstraint) {
    String ID = componentParams[0];
    ViewMargin margin;
    if (fromConstraint) {
      margin = ViewMargin.fromString(componentParams[1]);
    } else {
      margin = ViewMargin(
          double.parse("${componentParams[1][0]}"),
          double.parse("${componentParams[1][1]}"),
          double.parse("${componentParams[1][2]}"),
          double.parse("${componentParams[1][3]}"));
    }

    String placeholder = componentParams[2];
    ComponentAlign componentAlign =
        getComponentAlignFromString(componentParams[3]);
    double textSize = double.parse("${componentParams[4]}");
    String textColor = componentParams[5];

    return TextComponent(
        ID, margin, placeholder, componentAlign, textSize, textColor);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "component_properties": [
        ID,
        margin.toString(),
        placeholder,
        componentAlignToString(textComponentAlign),
        textSize,
        textColor
      ],
      "type": "text"
    };
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

  void setValue(dynamic value) {
    this.placeholder = value;
  }

  @override
  getValue() {
    return this.placeholder;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
