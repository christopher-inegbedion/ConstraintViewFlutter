import 'package:constraint_view/components/list_component.dart';
import 'package:constraint_view/custom_views/constraint_view.dart';
import 'package:constraint_view/custom_views/draggable_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'components/button_component.dart';
import 'components/input_field_component.dart';
import 'components/live_model_component.dart';
import 'components/text_component.dart';
import 'enums/component_align.dart';
import 'models/config_entry.dart';
import 'models/configuration_model.dart';
import 'models/margin_model.dart';
import 'models/section_data.dart';

class ComponentsTestPage extends StatelessWidget {
  TextComponent dummy;
  ListComponent dummy2;

  List<ConfigurationModel> configModels;
  ComponentsTestPage() {
    dummy = TextComponent("2", ViewMargin(0, 10, 0, 0),
        "Get the exchange rates", ComponentAlign.center, 20, "#000000");
    dummy2 = ListComponent("sd", ViewMargin(0, 10, 0, 0), [""], [dummy]);

    configModels = [
      ConfigurationModel(
          "1",
          true,
          [
            // ConfigEntry([
            //   TextComponent(
            //       "2",
            //       ViewMargin(0, 0, 0, 0),
            //       "Get the exchange rates",
            //       ComponentAlign.center,
            //       20,
            //       "#000000"),
            // ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              ListComponent("33", ViewMargin(0, 0, 0, 0), [
                [
                  "original text",
                  [
                    ["base text1"],
                    ["base text2"]
                  ]
                ],
                [
                  "original text2",
                ]
              ], [
                dummy,
                dummy2
              ])
            ], ViewMargin(0, 0, 0, 0)),
            // ConfigEntry([
            //   TextComponent("3", ViewMargin(0, 0, 0, 0), "Result: {result}",
            //       ComponentAlign.center, 16, "#000000"),
            // ], ViewMargin(10, 0, 0, 0)),
          ],
          [
            ConfigEntry([
              TextComponent(
                  "enter_data",
                  ViewMargin(0, 0, 0, 0),
                  "Enter exchange rate data",
                  ComponentAlign.left,
                  20,
                  "#000000")
            ], ViewMargin(20, 0, 20, 0)),
            ConfigEntry([
              InputFieldComponent("x_rate1", ViewMargin(0, 0, 20, 20),
                  "Exchange rate 1", "Exchange rate 1 required"),
              InputFieldComponent("x_rate2", ViewMargin(0, 0, 20, 20),
                  "Exchange rate 2", "Exchange rate 2 required"),
            ], ViewMargin(20, 0, 0, 0)),
            ConfigEntry([
              ButtonComponent(
                  "ID",
                  ViewMargin(0, 0, 0, 20),
                  "Submit",
                  ComponentAlign.right,
                  "",
                  [],
                  "save",
                  [
                    "keyy",
                    ["x_rate1", "x_rate2"]
                  ]),
            ], ViewMargin(10, 0, 0, 0)),
          ],
          true,
          true,
          draggableSheetMaxHeight: 0.32,
          configurationInputs: {"result": "dsf"}),
      ConfigurationModel(
          "2",
          true,
          [
            ConfigEntry([
              TextComponent("3", ViewMargin(0, 0, 0, 0), "Result: ",
                  ComponentAlign.center, 16, "#000000"),
            ], ViewMargin(10, 0, 0, 0)),
          ],
          [
            ConfigEntry([
              TextComponent(
                  "enter_data",
                  ViewMargin(0, 0, 0, 0),
                  "Enter exchange rate data",
                  ComponentAlign.left,
                  20,
                  "#000000")
            ], ViewMargin(20, 0, 20, 0))
          ],
          true,
          true,
          draggableSheetMaxHeight: 0.32),
      ConfigurationModel(
          "3",
          false,
          [
            ConfigEntry([
              TextComponent("view_chair", ViewMargin(0, 0, 0, 0),
                  "View your chair", ComponentAlign.left, 30.0, "#000000")
            ], ViewMargin(40, 0, 30, 0)),
            ConfigEntry([
              LiveModelComponent(
                  "ID", 'assets/chair.gltf', false, ViewMargin(0, 0, 0, 0))
            ], ViewMargin(20, 0, 0, 0))
          ],
          [],
          true,
          true,
          draggableSheetMaxHeight: 0.1)
    ];
  }
  @override
  Widget build(BuildContext context) {
    SectionData sectionData = SectionData(configModels, true, "stage",
        "constraintName", "taskID", "userID", {"result": "dsf"});
    sectionData.setInitialState("1");

    return SafeArea(
        child: Scaffold(
            body: Container(
      color: Colors.white,
      child: Stack(
        children: [
          ///Top section
          Container(
              color: HexColor(sectionData.state.bgColor),
              height: MediaQuery.of(context).size.height,
              key: UniqueKey(),
              child: sectionData.state.buildTopView()),

          ///Draggable bottom section
          Container(
              key: UniqueKey(), child: ConstraintDraggableSheet(sectionData)),
        ],
      ),
    )));
  }
}
