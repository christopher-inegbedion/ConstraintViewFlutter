import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';

class TextComponent extends ComponentModel {
  String placeholder;
  ComponentAlign textComponentAlign;
  double textSize;

  TextComponent(String ID, Margin margin, String placeholder,
      ComponentAlign textComponentAlign, double textSize)
      : super(ID, margin, ComponentType.Text) {
    this.placeholder = placeholder;
    this.textComponentAlign = textComponentAlign;
    this.textSize = textSize;
  }

  static TextAlign getTextAlignment(ComponentAlign align) {
    return align == ComponentAlign.center
        ? TextAlign.center
        : align == ComponentAlign.left
            ? TextAlign.left
            : align == ComponentAlign.right
                ? TextAlign.right
                : TextAlign.center;
  }
}
