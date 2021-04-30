import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';

class ButtonComponent extends ComponentModel {
  String text;
  String color;
  ComponentAlign alignment;
  ButtonComponent(
      String ID, Margin margin, String text, ComponentAlign alignment,
      {String color})
      : super(ID, margin, ComponentType.Button) {
    this.text = text;
    this.color = color;
    this.alignment = alignment;
  }
}
