import 'dart:convert';
import 'dart:developer';

import 'package:constraint_view/component_action/commands/terminal_print_command.dart';
import 'package:constraint_view/components/color_block_component.dart';
import 'package:constraint_view/components/dropdown_component.dart';
import 'package:constraint_view/components/image_component.dart';
import 'package:constraint_view/components/list_component.dart';
import 'package:constraint_view/components/list_tile_component.dart';
import 'package:constraint_view/components/rating_component.dart';
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

  List<ConfigurationModel> configModels,
      configModels2,
      configModels3,
      configModels4,
      configModel5,
      configModel6,
      configModel7,
      configModel8;
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
              ListComponent("list", ViewMargin(0, 0, 0, 0), [],
                  [optionName, variantsList, newVariantBtn])
            ], ViewMargin(0, 0, 0, 0)),
          ],
          [
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
          ],
          true,
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

    configModels4 = [
      ConfigurationModel(
          "1",
          true,
          [
            ConfigEntry([
              TextComponent("", ViewMargin(0, 0, 30, 30), "Delivery status",
                  ComponentAlign.left, 20, "#000000")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent(
                  "ID",
                  ViewMargin(5, 0, 30, 30),
                  "Track the status of the task real-time.",
                  ComponentAlign.left,
                  16,
                  "#616161")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("started", ViewMargin(30, 0, 30, 30), "Started",
                  ComponentAlign.left, 16, "#F44336")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("started_msg", ViewMargin(5, 0, 30, 30), "-",
                  ComponentAlign.left, 14, "#616161")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("preping", ViewMargin(30, 0, 30, 0), "Preparing",
                  ComponentAlign.left, 16, "#F44336")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("preping_msg", ViewMargin(5, 0, 30, 30), "-",
                  ComponentAlign.left, 14, "#616161")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("en_route", ViewMargin(30, 0, 30, 0), "En-route",
                  ComponentAlign.left, 16, "#F44336")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("en_route_msg", ViewMargin(5, 0, 30, 30), "-",
                  ComponentAlign.left, 14, "#616161")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("delivered", ViewMargin(30, 0, 30, 0), "Delivered",
                  ComponentAlign.left, 16, "#F44336")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("delivered_msg", ViewMargin(5, 0, 30, 30), "-",
                  ComponentAlign.left, 14, "#616161")
            ], ViewMargin(0, 0, 0, 0)),
          ],
          [],
          false,
          false,
          draggableSheetMaxHeight: 0.12,
          topViewCommand: [
            {
              "commandName": "ltcca",
              "success": {
                "commandName": "sev",
                "success": {
                  "commandName": "gev",
                  "success": {
                    "commandName": "pmc",
                    "success": {
                      "commandName": "eq",
                      "success": {
                        "commandName": "ctc",
                        "success": {
                          "commandName": "gev",
                          "success": {
                            "commandName": "pmc",
                            "success": {
                              "commandName": "stcv",
                              "success": null,
                              "failure": null,
                              "usePrevResult": false,
                              "value": [
                                ["{0}"],
                                "started_msg"
                              ]
                            },
                            "failure": null,
                            "usePrevResult": false,
                            "value": [
                              ["data", "msg"],
                              "{0}"
                            ]
                          },
                          "failure": null,
                          "usePrevResult": false,
                          "value": [
                            ["status"],
                            false
                          ]
                        },
                        "failure": null,
                        "usePrevResult": false,
                        "value": ["started", "#4CAF50"]
                      },
                      "failure": {
                        "commandName": "gev",
                        "success": {
                          "commandName": "pmc",
                          "success": {
                            "commandName": "eq",
                            "success": {
                              "commandName": "ctc",
                              "success": {
                                "commandName": "gev",
                                "success": {
                                  "commandName": "pmc",
                                  "success": {
                                    "commandName": "stcv",
                                    "success": null,
                                    "failure": null,
                                    "usePrevResult": false,
                                    "value": [
                                      ["{0}"],
                                      "preping_msg"
                                    ]
                                  },
                                  "failure": null,
                                  "usePrevResult": false,
                                  "value": [
                                    ["data", "msg"],
                                    "{0}"
                                  ]
                                },
                                "failure": null,
                                "usePrevResult": false,
                                "value": [
                                  ["status"],
                                  false
                                ]
                              },
                              "failure": null,
                              "usePrevResult": false,
                              "value": ["preping", "#4CAF50"]
                            },
                            "failure": {
                              "commandName": "gev",
                              "success": {
                                "commandName": "pmc",
                                "success": {
                                  "commandName": "eq",
                                  "success": {
                                    "commandName": "ctc",
                                    "success": {
                                      "commandName": "gev",
                                      "success": {
                                        "commandName": "pmc",
                                        "success": {
                                          "commandName": "stcv",
                                          "success": null,
                                          "failure": null,
                                          "usePrevResult": false,
                                          "value": [
                                            ["{0}"],
                                            "en_route_msg"
                                          ]
                                        },
                                        "failure": null,
                                        "usePrevResult": false,
                                        "value": [
                                          ["data", "msg"],
                                          "{0}"
                                        ]
                                      },
                                      "failure": null,
                                      "usePrevResult": false,
                                      "value": [
                                        ["status"],
                                        false
                                      ]
                                    },
                                    "failure": null,
                                    "usePrevResult": false,
                                    "value": ["en_route", "#4CAF50"]
                                  },
                                  "failure": {
                                    "commandName": "gev",
                                    "success": {
                                      "commandName": "pmc",
                                      "success": {
                                        "commandName": "eq",
                                        "success": {
                                          "commandName": "ctc",
                                          "success": {
                                            "commandName": "gev",
                                            "success": {
                                              "commandName": "pmc",
                                              "success": {
                                                "commandName": "stcv",
                                                "success": null,
                                                "failure": null,
                                                "usePrevResult": false,
                                                "value": [
                                                  ["{0}"],
                                                  "delivered_msg"
                                                ]
                                              },
                                              "failure": null,
                                              "usePrevResult": false,
                                              "value": [
                                                ["data", "msg"],
                                                "{0}"
                                              ]
                                            },
                                            "failure": null,
                                            "usePrevResult": false,
                                            "value": [
                                              ["status"],
                                              false
                                            ]
                                          },
                                          "failure": null,
                                          "usePrevResult": false,
                                          "value": ["delivered", "#4CAF50"]
                                        },
                                        "failure": null,
                                        "usePrevResult": false,
                                        "value": ["{0}", "done"]
                                      },
                                      "failure": null,
                                      "usePrevResult": false,
                                      "value": [
                                        ["data", "stage"],
                                        "{0}"
                                      ]
                                    },
                                    "failure": null,
                                    "usePrevResult": false,
                                    "value": [
                                      ["status"],
                                      false
                                    ]
                                  },
                                  "usePrevResult": false,
                                  "value": ["{0}", "en_route"]
                                },
                                "failure": null,
                                "usePrevResult": false,
                                "value": [
                                  ["data", "stage"],
                                  "{0}"
                                ]
                              },
                              "failure": null,
                              "usePrevResult": false,
                              "value": [
                                ["status"],
                                false
                              ]
                            },
                            "usePrevResult": false,
                            "value": ["{0}", "prep"]
                          },
                          "failure": null,
                          "usePrevResult": false,
                          "value": [
                            ["data", "stage"],
                            "{0}"
                          ]
                        },
                        "failure": null,
                        "usePrevResult": false,
                        "value": [
                          ["status"],
                          false
                        ]
                      },
                      "usePrevResult": false,
                      "value": ["{0}", "start"]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": [
                      ["data", "stage"],
                      "{0}"
                    ]
                  },
                  "failure": null,
                  "usePrevResult": false,
                  "value": [
                    ["status"],
                    false
                  ]
                },
                "failure": null,
                "usePrevResult": false,
                "value": ["status", "{0}", false]
              },
              "failure": null,
              "usePrevResult": false,
              "value": []
            },
          ])
    ];

    configModel5 = [
      ConfigurationModel(
          "1",
          true,
          [
            ConfigEntry([
              TextComponent("", ViewMargin(0, 0, 30, 30), "Delivery status",
                  ComponentAlign.left, 20, "#000000")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("ID", ViewMargin(5, 0, 30, 30),
                  "Set the current status", ComponentAlign.left, 16, "#616161")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent("current_stage", ViewMargin(0, 0, 0, 0),
                  "Not started", ComponentAlign.left, 15, "#000000"),
              InputFieldComponent("ID", ViewMargin(0, 0, 15, 0),
                  "Status message", "Please enter a status message")
            ], ViewMargin(30, 0, 30, 30)),
            ConfigEntry([
              TextComponent("next_status", ViewMargin(0, 0, 30, 0),
                  "Next stage: Stage", ComponentAlign.left, 14, "#757575"),
              ButtonComponent("update", ViewMargin(0, 0, 0, 30), "UPDATE",
                  ComponentAlign.right, {
                "commandName": "gev",
                "success": {
                  "commandName": "eq",
                  "success": {
                    "commandName": "sev",
                    "success": {
                      "commandName": "sld",
                      "success": null,
                      "failure": null,
                      "usePrevResult": false,
                      "value": ["start", "custom msg", null, "Delivery"]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": ["status", "started", false]
                  },
                  "failure": {
                    "commandName": "gev",
                    "success": {
                      "commandName": "eq",
                      "success": {
                        "commandName": "gev",
                        "success": {
                          "commandName": "sld",
                          "success": null,
                          "failure": null,
                          "usePrevResult": false,
                          "value": ["prep", "custom msg", null, "Delivery"]
                        },
                        "failure": null,
                        "usePrevResult": false,
                        "value": [
                          ["status"],
                          false
                        ]
                      },
                      "failure": {
                        "commandName": "gev",
                        "success": {
                          "commandName": "eq",
                          "success": {
                            "commandName": "gev",
                            "success": {
                              "commandName": "sld",
                              "success": null,
                              "failure": null,
                              "usePrevResult": false,
                              "value": [
                                "en_route",
                                "custom msg",
                                null,
                                "Delivery"
                              ]
                            },
                            "failure": null,
                            "usePrevResult": false,
                            "value": ["status", "prep", false]
                          },
                          "failure": {
                            "commandName": "gev",
                            "success": {
                              "commandName": "eq",
                              "success": {
                                "commandName": "gev",
                                "success": {
                                  "commandName": "sld",
                                  "success": null,
                                  "failure": null,
                                  "usePrevResult": false,
                                  "value": [
                                    "done",
                                    "custom msg",
                                    null,
                                    "Delivery"
                                  ]
                                },
                                "failure": null,
                                "usePrevResult": false,
                                "value": ["status", "done", false]
                              },
                              "failure": {
                                "commandName": "gev",
                                "success": {
                                  "commandName": "eq",
                                  "success": null,
                                  "failure": null,
                                  "usePrevResult": false,
                                  "value": ["{0}", "done"]
                                },
                                "failure": null,
                                "usePrevResult": false,
                                "value": [
                                  ["status"],
                                  false
                                ]
                              },
                              "usePrevResult": false,
                              "value": ["{0}", "en_route"]
                            },
                            "failure": null,
                            "usePrevResult": false,
                            "value": [
                              ["status"],
                              false
                            ]
                          },
                          "usePrevResult": false,
                          "value": ["{0}", "prep"]
                        },
                        "failure": null,
                        "usePrevResult": false,
                        "value": [
                          ["status"],
                          false
                        ]
                      },
                      "usePrevResult": false,
                      "value": ["{0}", "started"]
                    },
                    "failure": null,
                    "usePrevResult": false,
                    "value": [
                      ["status"],
                      false
                    ]
                  },
                  "usePrevResult": false,
                  "value": ["{0}", null]
                },
                "failure": null,
                "usePrevResult": false,
                "value": [
                  ["status"],
                  false
                ]
              })
            ], ViewMargin(20, 0, 0, 0)),
          ],
          [],
          false,
          false,
          draggableSheetMaxHeight: 0.12,
          topViewCommand: [])
    ];

    configModel6 = [
      ConfigurationModel(
          "1",
          false,
          [
            ConfigEntry([
              ImageComponent(
                  "image",
                  ViewMargin(40, 0, 0, 0),
                  "https://images.unsplash.com/photo-1540319585560-a4fcf1810366?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=2250&q=80",
                  200,
                  0,
                  true),
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              ListComponent("list", ViewMargin(0, 0, 0, 0), [], [
                TextComponent("title", ViewMargin(0, 0, 30, 0), "",
                    ComponentAlign.left, 14, "#9E9E9E"),
                TextComponent("value", ViewMargin(0, 30, 30, 0), "",
                    ComponentAlign.left, 20, "#000000")
              ])
            ], ViewMargin(30, 0, 0, 0)),
          ],
          [],
          false,
          false,
          topViewCommand: [
            {
              "commandName": "gcci",
              "success": {
                "commandName": "adtlc",
                "success": null,
                "failure": null,
                "usePrevResult": false,
                "value": ["list", "{0}"]
              },
              "failure": null,
              "usePrevResult": false,
              "value": [
                // {"data": "sd", "data2": "sd"}
              ]
            }
          ])
    ];

    configModel7 = [
      ConfigurationModel(
          "1",
          true,
          [
            ConfigEntry([
              TextComponent("text1", ViewMargin(0, 0, 0, 0),
                  "Face-To-Face payment", ComponentAlign.center, 23, "#000000"),
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              TextComponent(
                  "text1",
                  ViewMargin(10, 0, 30, 30),
                  "Tap the button below when the customer pays you",
                  ComponentAlign.center,
                  16,
                  "#9E9E9E")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              ButtonComponent("btn", ViewMargin(0, 0, 0, 0), "Payment received",
                  ComponentAlign.center, {
                "commandName": "sld",
                "success": null,
                "failure": null,
                "usePrevResult": false,
                "value": ["paid", "", null, "Face-To-Face payment"]
              })
            ], ViewMargin(0, 0, 0, 0))
          ],
          [],
          false,
          false)
    ];

    configModel8 = [
      ConfigurationModel(
          "1",
          true,
          [
            ConfigEntry([
              TextComponent("text", ViewMargin(0, 0, 0, 0), "Rate this service",
                  ComponentAlign.center, 25, "#000000"),
            ], ViewMargin(0, 0, 0, 0)),
            // ConfigEntry([
            //   TextComponent("text", ViewMargin(5, 0, 0, 0),
            //       "Submit your review", ComponentAlign.center, 20, "#9E9E9E")
            // ], ViewMargin(0, 0, 0, 0))
          ],
          [
            ConfigEntry([
              TextComponent(
                  "sd",
                  ViewMargin(20, 0, 30, 20),
                  "Tell the service provider what you think",
                  ComponentAlign.left,
                  16,
                  "#000000")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              InputFieldComponent("input", ViewMargin(10, 0, 30, 30),
                  "Write a review", "Please enter your review message")
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              RatingComponent(
                  "rating", ViewMargin(30, 0, 0, 0), ComponentAlign.center, 30)
            ], ViewMargin(0, 0, 0, 0)),
            ConfigEntry([
              ButtonComponent("sumbit", ViewMargin(0, 0, 0, 0), "Submit",
                  ComponentAlign.right, {
                "commandName": "tp",
                "success": null,
                "failure": null,
                "usePrevResult": false,
                "value": ["input", "rating"]
              })
            ], ViewMargin(0, 0, 0, 30))
          ],
          true,
          true,
          draggableSheetMaxHeight: 0.4)
    ];
  }

  @override
  Widget build(BuildContext context) {
    SectionData sectionData4 =
        SectionData(configModel8, true, "stage", "Rating and Review", "", "", null);
    sectionData4.setCurrentConfig("1");
    // log(jsonEncode(sectionData4.toJson()).toString());

    return SafeArea(
        child: Scaffold(
            body: Container(
      color: Colors.white,
      child: Stack(
        children: [
          ///Top section
          Container(
              color: HexColor(sectionData4.state.bgColor),
              // height: MediaQuery.of(context).size.height,
              key: key,
              child: sectionData4.state.buildTopView()),

          ///Draggable bottom section
          Container(key: key1, child: ConstraintDraggableSheet(sectionData4)),
        ],
      ),
    )));
  }
}
