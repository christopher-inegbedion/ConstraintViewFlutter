import 'dart:convert';
import 'dart:developer';

import 'package:constraint_view/component_action/commands/terminal_print_command.dart';
import 'package:constraint_view/components/dropdown_component.dart';
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
  SectionData sectionData2;
  TextComponent dummy;
  TextComponent optionName;
  TextComponent variantName;
  ListComponent variantsList;
  ButtonComponent newVariantBtn;
  GlobalKey key = GlobalKey();
  UniqueKey key1 = UniqueKey();

  List<ConfigurationModel> configModels, configModels2, configModels3;
  ComponentsTestPageState() {
    optionName = TextComponent("option_name", ViewMargin(20, 10, 30, 0),
        "Option name", ComponentAlign.left, 20, "#000000");
    variantName = TextComponent("variant_name", ViewMargin(10, 0, 30, 0),
        "Variant name", ComponentAlign.left, 16, "#263238");
    variantsList = ListComponent(
        "variants_list", ViewMargin(0, 10, 0, 0), [""], [variantName]);

    newVariantBtn = ButtonComponent("new_variant_btn", ViewMargin(0, 0, 20, 0),
        "Add new variant", ComponentAlign.left, {
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
                      "success": {
                        "commandName": "gev",
                        "success": {
                          "commandName": "gcfl",
                          "success": {
                            "commandName": "cv",
                            "success": {
                              "commandName": "sev",
                              "success": {
                                "commandName": "gev",
                                "success": {
                                  "commandName": "sevtl",
                                  "success": null,
                                  "failure": null,
                                  "usePrevResult": false,
                                  "value": ["{0}", "{1}", false]
                                },
                                "failure": null,
                                "usePrevResult": false,
                                "value": [
                                  ["option_name", "value"],
                                  true
                                ]
                              },
                              "failure": null,
                              "usePrevResult": false,
                              "value": ["option_name", "{0}", true]
                            },
                            "failure": null,
                            "usePrevResult": false,
                            "value": ["{0}"]
                          },
                          "failure": null,
                          "usePrevResult": false,
                          "value": ["list", "{0}", 0]
                        },
                        "failure": null,
                        "usePrevResult": false,
                        "value": [
                          ["index"],
                          true
                        ]
                      },
                      "failure": null,
                      "usePrevResult": false,
                      "value": [
                        "{0}",
                        ["{1}"]
                      ]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": [
                      ["id", "value"],
                      true
                    ]
                  },
                  "failure": null,
                  "usePrevResult": false,
                  "value": ["id", "{0}", true]
                },
                "failure": null,
                "usePrevResult": false,
                "value": ["list", "{0}", 1]
              },
              "failure": null,
              "usePrevResult": false,
              "value": [
                ["index"],
                true
              ]
            },
            "failure": null,
            "usePrevResult": false,
            "value": ["value", "{0}", true]
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
        "value": ["index", "{0}", true]
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
              TextComponent("title", ViewMargin(0, 0, 30, 0),
                  "Product variants", ComponentAlign.left, 22, "#000000"),
              ButtonComponent("save_data", ViewMargin(0, 0, 0, 20), "Save",
                  ComponentAlign.right, {
                "commandName": "gev",
                "success": null,
                "failure": null,
                "usePrevResult": false,
                "value": null
              })
            ], ViewMargin(30, 0, 0, 0)),
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
                    "commandName": "sev",
                    "success": {
                      "commandName": "gev",
                      "success": {
                        "commandName": "adtlc",
                        "success": {
                          "commandName": "gev",
                          "success": {
                            "commandName": "sevtl",
                            "success": null,
                            "failure": null,
                            "usePrevResult": false,
                            "value": ["{0}", null, false]
                          },
                          "failure": null,
                          "usePrevResult": false,
                          "value": [
                            ["option_name"],
                            true
                          ]
                        },
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
                        ["option_name"],
                        true
                      ]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": ["option_name", "{0}", true]
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

    ButtonComponent buttonComponent = ButtonComponent(
        "constraint_component",
        ViewMargin(0, 0, 20, 0),
        "d",
        ComponentAlign.left,
        {
          "commandName": "gcld",
          "success": {
            "commandName": "gcfl",
            "success": {
              "commandName": "cv",
              "success": {
                "commandName": "sev",
                "success": {
                  "commandName": "icr",
                  "success": {
                    "commandName": "gev",
                    "success": {
                      "commandName": "scd",
                      "success": {
                        "commandName": "sev",
                        "success": {
                          "commandName": "gev",
                          "success": {
                            "commandName": "smkvtk",
                            "success": {
                              "commandName": "gev",
                              "success": {
                                "commandName": "gev",
                                "success": {
                                  "commandName": "smkvtk",
                                  "success": {
                                    "commandName": "cv",
                                    "success": {
                                      "commandName": "sev",
                                      "success": {
                                        "commandName": "gev",
                                        "success": {
                                          "commandName": "gev",
                                          "success": {
                                            "commandName": "sevtl",
                                            "success": null,
                                            "failure": null,
                                            "usePrevResult": false,
                                            "value": ["{1}", "{0}", false]
                                          },
                                          "failure": null,
                                          "usePrevResult": false,
                                          "value": [
                                            ["{0}", "current_stage"],
                                            false
                                          ]
                                        },
                                        "failure": null,
                                        "usePrevResult": false,
                                        "value": [
                                          ["name"],
                                          true
                                        ]
                                      },
                                      "failure": null,
                                      "usePrevResult": false,
                                      "value": ["current_stage", "{0}", false]
                                    },
                                    "failure": null,
                                    "usePrevResult": false,
                                    "value": ["dropdown"]
                                  },
                                  "failure": null,
                                  "usePrevResult": false,
                                  "value": [
                                    "{0}",
                                    [
                                      ["constraint_name", "{0}"],
                                      ["config_inputs", "{1}"]
                                    ],
                                    false
                                  ]
                                },
                                "failure": null,
                                "usePrevResult": false,
                                "value": [
                                  ["name", "{0}"],
                                  true
                                ]
                              },
                              "failure": null,
                              "usePrevResult": false,
                              "value": [
                                ["name"],
                                true
                              ]
                            },
                            "failure": null,
                            "usePrevResult": false,
                            "value": [
                              "{0}",
                              [
                                ["config_inputs", "{1}"]
                              ],
                              true
                            ]
                          },
                          "failure": null,
                          "usePrevResult": false,
                          "value": [
                            ["name", "config_value"],
                            true
                          ]
                        },
                        "failure": null,
                        "usePrevResult": false,
                        "value": ["config_value", "{0}", true]
                      },
                      "failure": null,
                      "usePrevResult": false,
                      "value": ["{0}", "ds"]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": [
                      ["name"],
                      true
                    ]
                  },
                  "failure": {
                    "commandName": "gev",
                    "success": {
                      "commandName": "smkvtk",
                      "success": {
                        "commandName": "gev",
                        "success": {
                          "commandName": "gev",
                          "success": {
                            "commandName": "smkvtk",
                            "success": {
                              "commandName": "cv",
                              "success": {
                                "commandName": "sev",
                                "success": {
                                  "commandName": "gev",
                                  "success": {
                                    "commandName": "gev",
                                    "success": {
                                      "commandName": "sevtl",
                                      "success": null,
                                      "failure": null,
                                      "usePrevResult": false,
                                      "value": ["{1}", "{0}", false]
                                    },
                                    "failure": null,
                                    "usePrevResult": false,
                                    "value": [
                                      ["{0}", "current_stage"],
                                      false
                                    ]
                                  },
                                  "failure": null,
                                  "usePrevResult": false,
                                  "value": [
                                    ["name"],
                                    true
                                  ]
                                },
                                "failure": null,
                                "usePrevResult": false,
                                "value": ["current_stage", "{0}", false]
                              },
                              "failure": null,
                              "usePrevResult": false,
                              "value": ["dropdown"]
                            },
                            "failure": null,
                            "usePrevResult": false,
                            "value": [
                              "{0}",
                              [
                                ["constraint_name", "{0}"],
                                ["config_inputs", "{1}"]
                              ],
                              false
                            ]
                          },
                          "failure": null,
                          "usePrevResult": false,
                          "value": [
                            ["name", "{0}"],
                            true
                          ]
                        },
                        "failure": null,
                        "usePrevResult": false,
                        "value": [
                          ["name"],
                          true
                        ]
                      },
                      "failure": null,
                      "usePrevResult": false,
                      "value": [
                        "{0}",
                        [
                          ["config_inputs", null]
                        ],
                        true
                      ]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": [
                      ["name"],
                      true
                    ]
                  },
                  "usePrevResult": false,
                  "value": ["{0}"]
                },
                "failure": null,
                "usePrevResult": false,
                "value": ["name", "{0}", true]
              },
              "failure": null,
              "usePrevResult": false,
              "value": ["{0}"]
            },
            "failure": null,
            "usePrevResult": false,
            "value": ["list", "{0}", "{1}"]
          },
          "failure": null,
          "usePrevResult": false,
          "value": []
        },
        color: "#000000");

    configModels2 = [
      ConfigurationModel(
          "1",
          false,
          [
            ConfigEntry([
              TextComponent(
                  "toptext",
                  ViewMargin(0, 0, 0, 0),
                  "Select constraints for your task",
                  ComponentAlign.left,
                  25,
                  "#000000")
            ], ViewMargin(40, 0, 30, 0)),
            ConfigEntry([
              TextComponent(
                  "toptext",
                  ViewMargin(0, 0, 0, 0),
                  "The constraints you select will be part of your task",
                  ComponentAlign.left,
                  18,
                  "#000000")
            ], ViewMargin(10, 0, 30, 30)),
            ConfigEntry([
              TextComponent("toptext", ViewMargin(0, 0, 0, 0), "Stages:",
                  ComponentAlign.left, 16, "#000000")
            ], ViewMargin(30, 0, 30, 0)),
            ConfigEntry([
              DropdownComponent(
                  "dropdown",
                  ViewMargin(0, 0, 30, 50),
                  ["Pending", "Active", "Complete"],
                  "Pending",
                  ComponentAlign.left,
                  {
                    "commandName": "cv",
                    "success": {
                      "commandName": "tp",
                      "success": null,
                      "failure": null,
                      "usePrevResult": true,
                      "value": ["dropdown"]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": ["dropdown"]
                  })
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("toptext", ViewMargin(0, 0, 0, 0),
                  "Available constraints:", ComponentAlign.left, 16, "#000000")
            ], ViewMargin(30, 0, 30, 0)),
            ConfigEntry([
              ListComponent("list", ViewMargin(0, 0, 0, 0), [
                ["Exchange rate"],
                ["Pause"],
                ["Product description"]
              ], [
                buttonComponent
              ])
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              ButtonComponent("complete", ViewMargin(0, 0, 0, 0), "Complete",
                  ComponentAlign.right, {
                "commandName": "gev",
                "success": {
                  "commandName": "smkvtk",
                  "success": {
                    "commandName": "gev",
                    "success": {
                      "commandName": "smkvtk",
                      "success": {
                        "commandName": "gev",
                        "success": {
                          "commandName": "smkvtk",
                          "success": {
                            "commandName": "gev",
                            "success": {
                              "commandName": "sevtl",
                              "success": {
                                "commandName": "gev",
                                "success": {
                                  "commandName": "sevtl",
                                  "success": {
                                    "commandName": "gev",
                                    "success": {
                                      "commandName": "sevtl",
                                      "success": {
                                        "commandName": "gev",
                                        "success": {
                                          "commandName": "srd",
                                          "success": null,
                                          "failure": null,
                                          "usePrevResult": false,
                                          "value": ["{0}"]
                                        },
                                        "failure": null,
                                        "usePrevResult": false,
                                        "value": [
                                          ["stages"],
                                          false
                                        ]
                                      },
                                      "failure": null,
                                      "usePrevResult": false,
                                      "value": ["stages", "{0}", false]
                                    },
                                    "failure": null,
                                    "usePrevResult": false,
                                    "value": [
                                      ["Complete_data"],
                                      false
                                    ]
                                  },
                                  "failure": null,
                                  "usePrevResult": false,
                                  "value": ["stages", "{0}", false]
                                },
                                "failure": null,
                                "usePrevResult": false,
                                "value": [
                                  ["Active_data"],
                                  false
                                ]
                              },
                              "failure": null,
                              "usePrevResult": false,
                              "value": ["stages", "{0}", false]
                            },
                            "failure": null,
                            "usePrevResult": false,
                            "value": [
                              ["Pending_data"],
                              false
                            ]
                          },
                          "failure": null,
                          "usePrevResult": false,
                          "value": [
                            "Complete_data",
                            [
                              ["stage_name", "Complete"],
                              ["constraints", "{0}"]
                            ],
                            false
                          ]
                        },
                        "failure": null,
                        "usePrevResult": false,
                        "value": [
                          ["Complete"],
                          false
                        ]
                      },
                      "failure": null,
                      "usePrevResult": false,
                      "value": [
                        "Active_data",
                        [
                          ["stage_name", "Active"],
                          ["constraints", "{0}"]
                        ],
                        false
                      ]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": [
                      ["Active"],
                      false
                    ]
                  },
                  "failure": null,
                  "usePrevResult": false,
                  "value": [
                    "Pending_data",
                    [
                      ["stage_name", "Pending"],
                      ["constraints", "{0}"]
                    ],
                    false
                  ]
                },
                "failure": null,
                "usePrevResult": false,
                "value": [
                  ["Pending"],
                  false
                ]
              })
            ], ViewMargin(50, 0, 0, 30))
          ],
          [],
          false,
          false,
          draggableSheetMaxHeight: 0.1)
    ];

    sectionData2 = SectionData(configModels2, true, "stage",
        "Product description", 'kln', 'kn', {"Product name": "Jet engine"});
    configModels3 = [
      ConfigurationModel(
          "1",
          true,
          [
            ConfigEntry([
              TextComponent("text1", ViewMargin(0, 0, 30, 0),
                  "Product description", ComponentAlign.left, 25, "#000000")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent(
                  "text2",
                  ViewMargin(5, 0, 0, 0),
                  "Enter your product description details",
                  ComponentAlign.left,
                  18,
                  "#000000")
            ], ViewMargin(0, 0, 30, 0)),
            ConfigEntry([
              TextComponent(
                  "text3",
                  ViewMargin(50, 0, 30, 0),
                  "The name of your product",
                  ComponentAlign.left,
                  18,
                  "#000000")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              InputFieldComponent("input1", ViewMargin(5, 0, 0, 0),
                  "Product name", "Please enter the product name")
            ], ViewMargin(0, 0, 30, 30)),
            ConfigEntry([
              TextComponent(
                  "text4",
                  ViewMargin(50, 0, 30, 0),
                  "The description of your product",
                  ComponentAlign.left,
                  18,
                  "#000000")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              InputFieldComponent("input2", ViewMargin(5, 0, 0, 0),
                  "Product description", "Please describe your product")
            ], ViewMargin(0, 0, 30, 30)),
            ConfigEntry([
              ButtonComponent("complete_btn", ViewMargin(0, 0, 0, 0), "Save",
                  ComponentAlign.right, {
                "commandName": "cv",
                "success": {
                  "commandName": "sevtl",
                  "success": {
                    "commandName": "cv",
                    "success": {
                      "commandName": "sevtl",
                      "success": null,
                      "failure": null,
                      "usePrevResult": false,
                      "value": ["config_inputs", "{0}", false]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": ["input2"]
                  },
                  "failure": null,
                  "usePrevResult": false,
                  "value": ["config_inputs", "{0}", false]
                },
                "failure": null,
                "usePrevResult": false,
                "value": [
                  "input1",
                ]
              })
            ], ViewMargin(40, 0, 0, 30))
          ],
          [],
          false,
          false)
    ];
  }

  @override
  Widget build(BuildContext context) {
    SectionData sectionData = SectionData(configModels, true, "stage",
        "constraintName", "taskID", "userID", {"result": "dsf"});
    sectionData.setInitialState("1");

    SectionData sectionData3 = SectionData(configModels3, true, "null",
        "Product description_config", "null", "null", null);
    sectionData2.setCurrentConfig("1");
    // log(jsonEncode(sectionData2.toJson()).toString());

    return SafeArea(
        child: Scaffold(
            body: Container(
      color: Colors.white,
      child: Stack(
        children: [
          ///Top section
          Container(
              color: HexColor(sectionData2.state.bgColor),
              // height: MediaQuery.of(context).size.height,
              key: key,
              child: sectionData2.state.buildTopView()),

          ///Draggable bottom section
          Container(key: key1, child: ConstraintDraggableSheet(sectionData2)),
        ],
      ),
    )));
  }
}
