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
  TextComponent optionName;
  TextComponent variantName;
  ListComponent variantsList;
  ButtonComponent newVariantBtn;
  TextComponent dummy4;
  GlobalKey key = GlobalKey();
  UniqueKey key1 = UniqueKey();

  List<ConfigurationModel> configModels;
  ComponentsTestPageState() {
    optionName = TextComponent("option_name", ViewMargin(20, 10, 30, 0), "",
        ComponentAlign.left, 20, "#000000");
    variantName = TextComponent("variant_name", ViewMargin(10, 0, 30, 0), "",
        ComponentAlign.left, 16, "#263238");
    dummy4 = TextComponent("text3", ViewMargin(0, 10, 0, 0),
        "Get the exchange rates", ComponentAlign.center, 20, "#000000");
    variantsList = ListComponent(
        "variants_list", ViewMargin(0, 10, 0, 0), [""], [variantName]);

    newVariantBtn = ButtonComponent("new_variant_btn", ViewMargin(0, 0, 0, 20),
        "Add new variant", ComponentAlign.right, {
      "commandName": "gcld",
      "success": {
        "commandName": "sev",
        "success": {
          "commandName": "sdwi",
          "success": {
            "commandName": "sev",
            "success": {
              "commandName": "gev",
              "success": {
                "commandName": "gcfl",
                "success": {
                  "commandName": "sev",
                  "success": {
                    "commandName": "gev",
                    "success": {
                      "commandName": "adtlc",
                      "success": null,
                      "failure": null,
                      "usePrevResult": false,
                      "value": [
                        "{0}",
                        ["{1}"]
                      ]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": ["id", "value"]
                  },
                  "failure": null,
                  "usePrevResult": false,
                  "value": ["id", "{0}"]
                },
                "failure": null,
                "usePrevResult": false,
                "value": ["list", "{0}", 1]
              },
              "failure": null,
              "usePrevResult": false,
              "value": ["index"]
            },
            "failure": null,
            "usePrevResult": false,
            "value": ["value", "{0}"]
          },
          "failure": null,
          "usePrevResult": false,
          "value": [
            "New variant",
            ["Variant name"]
          ]
        },
        "failure": null,
        "usePrevResult": false,
        "value": ["index", "{0}"]
      },
      "failure": null,
      "usePrevResult": false,
      "value": []
    });

    configModels = [
      ConfigurationModel(
          "1",
          false,
          [
            ConfigEntry([
              TextComponent("title", ViewMargin(30, 0, 30, 0),
                  "Product variants", ComponentAlign.left, 25, "#000000"),
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent(
                  "title",
                  ViewMargin(5, 0, 30, 0),
                  "Add variants to the product",
                  ComponentAlign.left,
                  19,
                  "#263238"),
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              ButtonComponent(
                "ID",
                ViewMargin(20, 0, 0, 20),
                "Add new option",
                ComponentAlign.right,
                {
                  "commandName": "sdwi",
                  "success": {
                    "commandName": "adtlc",
                    "success": null,
                    "failure": null,
                    "usePrevResult": false,
                    "value": [
                      "list",
                      ["{0}", [], ""]
                    ]
                  },
                  "failure": null,
                  "usePrevResult": false,
                  "value": [
                    "New option",
                    ["Option name"]
                  ]
                },
              ),
            ], ViewMargin(10, 0, 0, 0)),
            ConfigEntry([
              ListComponent("list", ViewMargin(0, 0, 0, 0), [],
                  [optionName, variantsList, newVariantBtn])
            ], ViewMargin(0, 0, 0, 0)),
          ],
          [],
          false,
          false,
          draggableSheetMaxHeight: 0.2,
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
              // height: MediaQuery.of(context).size.height,
              key: key,
              child: sectionData.state.buildTopView()),

          ///Draggable bottom section
          Container(key: key1, child: ConstraintDraggableSheet(sectionData)),
        ],
      ),
    )));
  }
}
