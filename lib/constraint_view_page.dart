import 'package:constraint_view/custom_views/constraint_view.dart';
import 'package:constraint_view/models/section_data.dart';
import 'package:flutter/material.dart';

import 'components/button_component.dart';
import 'components/input_field_component.dart';
import 'components/live_model_component.dart';
import 'components/text_component.dart';
import 'enums/component_align.dart';
import 'models/config_entry.dart';
import 'models/configuration_model.dart';
import 'models/margin_model.dart';

class ConstraintViewPage extends StatefulWidget {
  String constraintName;

  ConstraintViewPage(this.constraintName);

  @override
  _ConstraintViewPageState createState() =>
      _ConstraintViewPageState(constraintName);
}

class _ConstraintViewPageState extends State<ConstraintViewPage> {
  String constraintName;
  List<ConfigurationModel> configModels = [
    ConfigurationModel(
        "1",
        true,
        [
          ConfigEntry([
            TextComponent("2", Margin(0, 0, 0, 0), "Get the exchange rates",
                ComponentAlign.center, 20, "#000000"),
          ], Margin(0, 0, 0, 0)),
          ConfigEntry([
            TextComponent("3", Margin(0, 0, 0, 0), "Result: ",
                ComponentAlign.center, 16, "#000000"),
          ], Margin(10, 0, 0, 0)),
        ],
        [
          ConfigEntry([
            TextComponent("enter_data", Margin(0, 0, 0, 0),
                "Enter exchange rate data", ComponentAlign.left, 20, "#000000")
          ], Margin(20, 0, 20, 0)),
          ConfigEntry([
            InputFieldComponent("x_rate1", Margin(0, 0, 20, 20),
                "Exchange rate 1", "Exchange rate 1 required"),
            InputFieldComponent("x_rate2", Margin(0, 0, 20, 20),
                "Exchange rate 2", "Exchange rate 2 required"),
          ], Margin(20, 0, 0, 0)),
          ConfigEntry([
            ButtonComponent(
                "ID",
                Margin(0, 0, 0, 20),
                "Submit",
                ComponentAlign.right,
                "",
                [],
                "save",
                [
                  "keyy",
                  ["x_rate1", "x_rate2"]
                ]),
          ], Margin(10, 0, 0, 0)),
        ],
        true,
        true,
        draggableSheetMaxHeight: 0.32),
    ConfigurationModel(
        "2",
        true,
        [
          ConfigEntry([
            TextComponent("3", Margin(0, 0, 0, 0), "Result: ",
                ComponentAlign.center, 16, "#000000"),
          ], Margin(10, 0, 0, 0)),
        ],
        [
          ConfigEntry([
            TextComponent("enter_data", Margin(0, 0, 0, 0),
                "Enter exchange rate data", ComponentAlign.left, 20, "#000000")
          ], Margin(20, 0, 20, 0))
        ],
        true,
        true,
        draggableSheetMaxHeight: 0.32),
    ConfigurationModel(
        "3",
        false,
        [
          ConfigEntry([
            TextComponent("view_chair", Margin(0, 0, 0, 0), "View your chair",
                ComponentAlign.left, 30.0, "#000000")
          ], Margin(40, 0, 30, 0)),
          ConfigEntry([
            LiveModelComponent(
                "ID", 'assets/chair.gltf', false, Margin(0, 0, 0, 0))
          ], Margin(20, 0, 0, 0))
        ],
        [],
        true,
        true,
        draggableSheetMaxHeight: 0.1)
  ];

  _ConstraintViewPageState(this.constraintName);

  @override
  Widget build(BuildContext context) {
    SectionData sectionData = SectionData(configModels, true);
    sectionData.setInitialState("2");

    return SafeArea(child: Scaffold(body: ConstraintView(sectionData)));
  }
}
