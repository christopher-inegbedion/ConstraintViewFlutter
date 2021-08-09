import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';

class ColorBlockComponent extends Component {
  String ID;
  double width;
  double height;
  String color;

  ColorBlockComponent(
      String ID, ViewMargin margin, String color, double width, double height)
      : super(ID, margin, ComponentType.ColorBlock) {
    this.ID = ID;
    this.margin = margin;
    this.color = color;
    this.width = width;
    this.height = height;
  }

  @override
  ColorBlockComponent buildComponent(
      List componentParams, bool fromConstraint) {
    String ID = componentParams[0];
    ViewMargin margin = fromConstraint
        ? ViewMargin.fromString(componentParams[1])
        : componentParams[1];
    double width = componentParams[2];
    double height = componentParams[3];
    String color = componentParams[4];

    return ColorBlockComponent(ID, margin, color, width, height);
  }

  @override
  buildComponentView() {
    return Container(
      color: HexColor(color),
      width: width,
      height: height,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "component_properties": [ID, margin.toString(), width, height, color],
      "type": "color"
    };
  }

  @override
  getValue() {
    return color;
  }

  @override
  setValue(value) {
    this.color = value;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
