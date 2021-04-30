import 'package:constraint_view/components/buttom_component.dart';
import 'package:constraint_view/components/image_component.dart';
import 'package:constraint_view/components/input_field_component.dart';
import 'package:constraint_view/custom_views/draggable_sheet.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/view_controller.dart';
import 'package:flutter/material.dart';

import 'components/text_component.dart';
import 'models/entry_model.dart';
import 'models/margin_model.dart';

class ConstraintView extends StatefulWidget {
  bool canOpen;

  ConstraintView(canOpen);

  @override
  _ConstraintViewState createState() => _ConstraintViewState(this.canOpen);
}

class _ConstraintViewState extends State<ConstraintView> {
  bool canOpen;

  _ConstraintViewState(this.canOpen);

  List<ConfigEntry> entries = [
    ConfigEntry([
      TextComponent(
          "1", Margin(0, 0, 0, 0), "placeholder", ComponentAlign.center, 20),
      // TextComponent(
      //     "1", Margin(0, 0, 0, 0), "placeholder", TextComponentAlign.center),
      InputFieldComponent("1", Margin(0, 0, 0, 0), "placeholder"),
      // TextComponent(
      //     "1", Margin(0, 0, 0, 0), "placeholder", TextComponentAlign.center),
    ], Margin(20.0, 20.0, 0, 0)),
    ConfigEntry([
      ImageComponent(
          "ID",
          Margin(0, 0, 0, 0),
          "https://media.giphy.com/media/0XvSCsMVigSeF8PhNJ/giphy.gif",
          100,
          100),
      ImageComponent(
          "ID",
          Margin(0, 0, 0, 0),
          "https://media.giphy.com/media/0XvSCsMVigSeF8PhNJ/giphy.gif",
          100,
          100),
    ], Margin(0, 0, 0, 0)),
    ConfigEntry([
      ButtonComponent("ID", Margin(0, 0, 0, 0), "type", ComponentAlign.left)
    ], Margin(0, 0, 0, 0)),
    ConfigEntry([
      TextComponent(
          "1", Margin(0, 0, 0, 0), "placeholder", ComponentAlign.center, 10)
    ], Margin(0, 0, 0, 0)),
  ];
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          // height: 100,
          child: ViewController(entries),
        ),
        ConstraintDraggableSheet(true)
      ],
    );
  }
}
