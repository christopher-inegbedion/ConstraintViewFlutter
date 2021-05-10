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
import 'package:model_viewer/model_viewer.dart';

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
      Margin entryMargin = entry.margin;
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

    return Column(
      mainAxisAlignment: configurationModel.centerTopSectionData
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: entries,
    );
  }

  Widget buildTextComponent(TextComponent textComponent) {
    Margin componentMargin = textComponent.margin;
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
    Margin componentMargin = inputFieldComponent.margin;

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
    Margin componentMargin = imageComponent.margin;
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
    Margin componentMargin = buttonComponent.margin;
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
    Margin componentMargin = liveModelComponent.margin;
    ModelViewer liveModel = liveModelComponent.buildComponentView();

    builtComponents[liveModelComponent.ID] = liveModel;

    return Container(
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(
          top: componentMargin.top,
          bottom: componentMargin.bottom,
          left: componentMargin.left,
          right: componentMargin.right),
      child: liveModel,
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
      default:
        return true;
    }
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
        print(savedValues);
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
        print(savedValues);
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
          buttonComponent.actionFunctionArgs[1]);
    } else {
      throw Exception(
          "Button ${buttonComponent.ID}'s requirement not fulfilled");
    }

    print(isRequirementSatisfied);
  }

  void notifyChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return buildView();
  }
}
