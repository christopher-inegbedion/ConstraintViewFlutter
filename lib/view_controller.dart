import 'dart:convert';

import 'package:constraint_view/components/button_component.dart';
import 'package:constraint_view/components/image_component.dart';
import 'package:constraint_view/components/input_field_component.dart';
import 'package:constraint_view/components/live_model_component.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/config_entry.dart';
import 'package:constraint_view/models/configuration_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:model_viewer/model_viewer.dart';
import 'package:web_socket_channel/io.dart';

import 'models/section_data.dart';

class ViewController extends StatefulWidget {
  ConfigurationModel configurationModel;
  final String section;
  _ViewControllerState state;

  ViewController(this.configurationModel, this.section) {
    state = _ViewControllerState(configurationModel, section);
  }

  void notifyChange() {
    state.notifyChange();
  }

  @override
  _ViewControllerState createState() => state;
}

class _ViewControllerState extends State<ViewController> {
  ConfigurationModel configurationModel;
  String section;
  Map builtComponents = {};
  Map<String, dynamic> savedValues = {};
  List<ConfigEntry> sectionToUse;
  bool ignoreScoll = false;

  _ViewControllerState(this.configurationModel, this.section);

  Widget buildView() {
    if (this.configurationModel == null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
                child: Center(
              child: Text("SectionData currentConfig not set"),
            )),
          ],
        ),
      );
    }

    if (this.section == "top") {
      sectionToUse = configurationModel.topSection;
    } else if (this.section == "bottom") {
      sectionToUse = configurationModel.bottomSection;
    } else {
      return Expanded(
          child: Center(
        child: Text("Unrecognized section: ${section}"),
      ));
    }

    List<Widget> entries = [];

    for (ConfigEntry entry in this.sectionToUse) {
      ViewMargin entryMargin = entry.margin;
      List<Widget> components = [];

      for (Component component in entry.components) {
        switch (component.type) {
          case ComponentType.Text:
            TextComponent textComponent = component;
            Widget builtComponent = buildTextComponent(textComponent);

            components.add(builtComponent);
            break;
          case ComponentType.Input:
            InputFieldComponent inputFieldComponent = component;
            Widget builtComponent =
                buildInputFieldComponent(inputFieldComponent);
            components.add(builtComponent);
            break;
          case ComponentType.Image:
            ImageComponent imageComponent = component;
            Widget builtComponent = buildImageComponent(imageComponent);

            components.add(builtComponent);
            break;
          case ComponentType.Button:
            ButtonComponent buttonComponent = component;
            Widget builtComponent = buildButtonComponent(buttonComponent);

            components.add(builtComponent);
            break;
          case ComponentType.LiveModel:
            LiveModelComponent liveModelComponent = component;
            Widget builtComponent = buildLiveModelComponent(liveModelComponent);

            components.add(builtComponent);
            break;
          default:
            throw Exception(
                "Component ${component.type} has not been rendered");
        }
      }

      Container entryWidget = Container(
        child: Row(
          children: components,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        margin: EdgeInsets.only(
            top: entryMargin.top,
            bottom: entryMargin.bottom,
            left: entryMargin.left,
            right: entryMargin.right),
      );
      entries.add(entryWidget);
    }

    return SingleChildScrollView(
      physics: ignoreScoll
          ? NeverScrollableScrollPhysics()
          : AlwaysScrollableScrollPhysics(),
      child: section == "top"
          ? Container(
              color: HexColor(configurationModel.bgColor),
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: configurationModel.centerTopSectionData
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: entries,
              ),
            )
          : Column(
              mainAxisAlignment: configurationModel.centerTopSectionData
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: entries,
            ),
    );
  }

  Widget buildTextComponent(TextComponent textComponent) {
    ViewMargin componentMargin = textComponent.margin;
    textComponent.placeholder = formatText(textComponent.placeholder);
    Text textWidget = textComponent.buildComponentView();

    builtComponents[textComponent.ID] = textComponent;

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
            top: componentMargin.top,
            bottom: componentMargin.bottom,
            left: componentMargin.left,
            right: componentMargin.right),
        child: textWidget,
      ),
    );
  }

  Widget buildInputFieldComponent(InputFieldComponent inputFieldComponent) {
    ViewMargin componentMargin = inputFieldComponent.margin;

    Form textFormField = inputFieldComponent.buildComponentView();

    builtComponents[inputFieldComponent.ID] = inputFieldComponent;

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
            top: componentMargin.top,
            bottom: componentMargin.bottom,
            left: componentMargin.left,
            right: componentMargin.right),
        child: textFormField,
      ),
    );
  }

  Widget buildImageComponent(ImageComponent imageComponent) {
    ViewMargin componentMargin = imageComponent.margin;
    double imageHeight = imageComponent.height;
    double imageWidth = imageComponent.width;

    Image imageWidget = imageComponent.buildComponentView();

    builtComponents[imageComponent.ID] = imageComponent;

    return Container(
      margin: EdgeInsets.only(
          top: componentMargin.top,
          bottom: componentMargin.bottom,
          left: componentMargin.left,
          right: componentMargin.right),
      width: imageWidth,
      height: imageHeight,
      child: imageWidget,
    );
  }

  Widget buildButtonComponent(ButtonComponent buttonComponent) {
    ViewMargin componentMargin = buttonComponent.margin;
    TextButton textButton = buttonComponent.buildComponentView(function: () {
      processButtonAction(buttonComponent);
    });

    builtComponents[buttonComponent.ID] = textButton;

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
            top: componentMargin.top,
            bottom: componentMargin.bottom,
            left: componentMargin.left,
            right: componentMargin.right),
        alignment: buttonComponent.alignment == ComponentAlign.center
            ? Alignment.center
            : buttonComponent.alignment == ComponentAlign.left
                ? Alignment.centerLeft
                : buttonComponent.alignment == ComponentAlign.right
                    ? Alignment.centerRight
                    : Alignment.center,
        child: textButton,
      ),
    );
  }

  Widget buildLiveModelComponent(LiveModelComponent liveModelComponent) {
    ViewMargin componentMargin = liveModelComponent.margin;
    ModelViewer liveModel = liveModelComponent.buildComponentView();

    builtComponents[liveModelComponent.ID] = liveModel;

    return Listener(
      onPointerDown: (d) {
        ignoreScoll = true;
        notifyChange();
      },
      onPointerUp: (d) {
        ignoreScoll = false;
        notifyChange();
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: liveModel,
          margin: EdgeInsets.only(
              top: componentMargin.top,
              bottom: componentMargin.bottom,
              left: componentMargin.left,
              right: componentMargin.right),
        ),
      ),
    );
  }

  bool processButtonRequirement(
      String requirementFunction, List requirementArgs) {
    switch (requirementFunction) {
      case "value":
        dynamic requiredValue = requirementArgs[0];
        String valueKey = requirementArgs[1];

        if (savedValues.containsKey(valueKey)) {
          if (savedValues[valueKey] == requiredValue) {
            return true;
          }
        }

        return false;
      case "availability":
        String valueKey = requirementArgs[0];

        if (savedValues.containsKey(valueKey)) {
          return true;
        }
        return false;
      case "input_field":
        bool isInputFieldValid = true;
        for (String inputId in requirementArgs) {
          if (getComponentValue(inputId) == null) {
            isInputFieldValid = false;
          }
        }

        return isInputFieldValid;
        break;
      default:
        return true;
    }
  }

  String formatText(String msg) {
    bool isLeftBracketFound = false;
    int startIndex = 0;
    int endIndex = 0;
    String string = msg;
    bool keywordFound = false;
    int replaceableWords = 0;

    string.characters.forEach((element) {
      var character = element;
      if (character == "{") {
        isLeftBracketFound = true;
      } else if (character == "}") {
        if (isLeftBracketFound) {
          isLeftBracketFound = false;
          replaceableWords++;
        }
      }
    });

    for (int i = 0; i < replaceableWords; i++) {
      int count = 0;
      List characters = string.characters.toList();
      for (String character in characters) {
        count++;
        if (keywordFound) {
          keywordFound = false;
          break;
        } else {
          if (character == "{") {
            startIndex = count;
            isLeftBracketFound = true;
          } else if (character == "}") {
            if (isLeftBracketFound) {
              if (isLeftBracketFound) {
                endIndex = count;

                isLeftBracketFound = false;
                String word = string.substring(startIndex, endIndex - 1);

                if (configurationModel.configurationInputs.containsKey(word)) {
                  string = string.replaceAll(
                      string.substring(startIndex - 1, endIndex),
                      configurationModel.configurationInputs[word]);
                } else {
                  string = string.replaceAll(
                      string.substring(startIndex - 1, endIndex), "Loading");
                }

                keywordFound = true;
              }
            }
          }
        }
      }
    }

    return string;
  }

  ///Save a value to the global [savedValues] dictionary.
  ///
  ///Pass the [actionFunction] which defines how the save operation should be
  ///carried out, [valueKey] which represents the key of the value to be saved
  ///in the [savedValues] dictionary and [valueIDs] which represent where the
  ///values should be gotten from (a component or an existing value)
  void saveValue(String actionFunction, String valueKey, List valueIDs) {
    switch (actionFunction) {
      case "save":
        List values = [];
        for (String valueID in valueIDs) {
          dynamic value = getComponentValue(valueID);
          values.add(value);
        }

        if (values.contains(null)) {
          return;
        }
        savedValues[valueKey] = values;
        break;
      case "save_val":
        List values = [];
        for (String valueID in valueIDs) {
          if (savedValues.containsKey(valueID)) {
            values.add(savedValues[valueID]);
          } else {
            throw Exception("A value with key $valueID has not been saved");
          }
        }

        savedValues[valueKey] = values;
        break;
      case "send_inputs":
        List values = [];
        for (String inputIDs in valueIDs) {
          values.add(getComponentValue(inputIDs));
        }

        final channel = IOWebSocketChannel.connect(
            "ws://192.168.1.129:4321/start_constraint2");
        channel.sink.add(jsonEncode({
          "response": "INPUT_REQUIRED",
          "constraint_name": configurationModel.constraintName,
          "stage_name": configurationModel.stageName,
          "user_id": configurationModel.userID,
          "task_id": configurationModel.taskID,
          "data": values
        }));

        break;
      default:
    }
  }

  dynamic getComponentValue(String componentID) {
    if (!builtComponents.containsKey(componentID)) {
      throw Exception("Component with ID $componentID cannot be found");
    }
    Component component = builtComponents[componentID];

    dynamic componentValue = component.getValue();

    if (componentValue != null) {
      return componentValue;
    }

    return null;
  }

  void processButtonAction(ButtonComponent buttonComponent) {
    bool isRequirementSatisfied = processButtonRequirement(
        buttonComponent.requirementFunction,
        buttonComponent.requirementFuncitonArgs);

    configurationModel.modifyComponent("2", "therr", "top");

    if (isRequirementSatisfied) {
      saveValue(
          buttonComponent.actionFunction,
          buttonComponent.actionFunctionArgs[0],
          buttonComponent.actionFunctionArgs);
    } else {
      throw Exception(
          "Button ${buttonComponent.ID}'s requirement not fulfilled");
    }
  }

  void notifyChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    formatText("{data} bv bb {data2} {data} {data}");

    return buildView();
  }
}
