import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/models/entry_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:constraint_view/view_controller.dart';
import 'package:flutter/material.dart';

class ConstraintDraggableSheet extends StatefulWidget {
  bool canOpen;

  ConstraintDraggableSheet(this.canOpen);

  @override
  _ConstraintDraggableSheetState createState() =>
      _ConstraintDraggableSheetState(this.canOpen);
}

class _ConstraintDraggableSheetState extends State<ConstraintDraggableSheet> {
  bool canOpen;
  final double maxExpandHeight = 0.6;
  final double minExpandHeight = 0.05;
  final double initialExpansionHeight = 0.3;
  _ConstraintDraggableSheetState(this.canOpen);

  List<ConfigEntry> entries = [
    ConfigEntry([
      TextComponent(
          "1", Margin(0, 0, 0, 0), "placeholder1", ComponentAlign.right, 10),
      TextComponent(
          "1", Margin(0, 0, 0, 0), "placeholder", ComponentAlign.left, 10),
      // TextComponent("1", Margin(0, 0, 0, 0), "placeholder"),
      // TextComponent("1", Margin(0, 0, 0, 0), "placeholder"),
    ], Margin(20.0, 20.0, 0, 0)),
    ConfigEntry([
      TextComponent(
          "1", Margin(0, 0, 0, 0), "placeholder", ComponentAlign.center, 10)
    ], Margin(0, 0, 0, 0)),
    ConfigEntry([
      TextComponent(
          "1", Margin(0, 0, 0, 0), "placeholder", ComponentAlign.center, 10)
    ], Margin(0, 0, 0, 0)),
    ConfigEntry([
      TextComponent(
          "1", Margin(0, 0, 0, 0), "placeholder", ComponentAlign.center, 10)
    ], Margin(0, 0, 0, 0)),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: canOpen ? initialExpansionHeight : minExpandHeight,
        minChildSize: minExpandHeight,
        maxChildSize: maxExpandHeight,
        builder: (BuildContext context, ScrollController scrollController) {
          return Card(
            color: canOpen ? Colors.white : Colors.grey[300],
            elevation: 10,
            margin: EdgeInsets.zero,
            child: SingleChildScrollView(
              physics: canOpen
                  ? BouncingScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 6,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  Container(
                    child: ViewController(entries),
                  )
                ],
              ),
            ),
          );
        });
  }
}
