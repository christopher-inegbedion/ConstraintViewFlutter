import 'package:constraint_view/component_action/commands/greater_than_comperator_command.dart';
import 'package:constraint_view/component_action/commands/terminal_print_command.dart';
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

class ComponentsTestPage extends StatefulWidget {
  ComponentsTestPage();

  @override
  ComponentsTestPageState createState() => ComponentsTestPageState();
}

class ComponentsTestPageState extends State<ComponentsTestPage> {
  TextComponent dummy;
  ListComponent dummy2;
  ButtonComponent dummy3;
  TextComponent dummy4;
  UniqueKey key = UniqueKey();

  List<ConfigurationModel> configModels;
  ComponentsTestPageState() {
    dummy = TextComponent("text1", ViewMargin(0, 10, 0, 0),
        "Get the exchange rates", ComponentAlign.center, 20, "#000000");
    dummy4 = TextComponent("text2", ViewMargin(0, 10, 0, 0),
        "Get the exchange rates", ComponentAlign.center, 20, "#000000");
    dummy2 = ListComponent("sd", ViewMargin(0, 10, 0, 0), [""], [dummy4]);

    dummy3 = ButtonComponent("new_variant_btn", ViewMargin(0, 0, 0, 20),
        "New variant", ComponentAlign.right, {
      "commandName": "gcld",
      "success": {
        "commandName": "gcfl",
        "success": null,
        "failure": null,
        "usePrevResult": false,
        "value": ["list", "{0}", 1]
      },
      "failure": null,
      "usePrevResult": false,
      "value": []
    });

    configModels = [
      ConfigurationModel(
          "1",
          true,
          [
            ConfigEntry([
              ListComponent(
                  "list", ViewMargin(0, 0, 0, 0), [[]], [dummy, dummy2, dummy3])
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              ButtonComponent(
                "ID", ViewMargin(0, 0, 0, 20), "Add new option",
                ComponentAlign.right,
                {
                  "commandName": "adtlc",
                  "success": null,
                  "failure": null,
                  "usePrevResult": false,
                  "value": [
                    "list",
                    [
                      DateTime.now().toString(),
                      [
                        ["base text1"],
                        ["base text2"]
                      ],
                      "Add new variant"
                    ]
                  ]
                },
                //     {
                //   "commandName": "cv",
                //   "success": {
                //     "commandName": "sev",
                //     "success": {
                //       "commandName": "cv",
                //       "success": {
                //         "commandName": "sev",
                //         "success": null,
                //         "failure": null,
                //         "usePrevResult": false,
                //         "value": ["ss2"]
                //       },
                //       "usePrevResult": false,
                //       "failure": null,
                //       "value": ["x_rate2"]
                //     },
                //     "failure": null,
                //     "usePrevResult": false,
                //     "value": ["ss"]
                //   },
                //   "usePrevResult": false,
                //   "failure": null,
                //   "value": ["x_rate1"]
                // }
              ),
            ], ViewMargin(10, 0, 0, 0))
          ],
          [
            ConfigEntry([
              TextComponent(
                  "enter_data",
                  ViewMargin(0, 0, 0, 0),
                  "Enter exchange rate data",
                  ComponentAlign.left,
                  20,
                  "#000000"),
              TextComponent(
                  "enter_data2",
                  ViewMargin(0, 0, 0, 0),
                  "Enter exchange rate data 2",
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
          Container(key: key, child: ConstraintDraggableSheet(sectionData)),
        ],
      ),
    )));
  }
}
