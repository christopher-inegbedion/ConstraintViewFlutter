import 'package:constraint_view/components/buttom_component.dart';
import 'package:constraint_view/components/image_component.dart';
import 'package:constraint_view/components/input_field_component.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/entry_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';

class ViewController extends StatefulWidget {
  List<ConfigEntry> sectionViewData;

  ViewController(this.sectionViewData);

  @override
  _ViewControllerState createState() => _ViewControllerState(sectionViewData);
}

class _ViewControllerState extends State<ViewController> {
  List<ConfigEntry> sectionViewData;
  Map<String, dynamic> builtComponents = {};
  bool canOpen;

  _ViewControllerState(this.sectionViewData);

  Widget buildView() {
    if (this.sectionViewData == null) {
      return null;
    }

    List<Widget> entries = [];
    for (ConfigEntry entry in this.sectionViewData) {
      Margin entryMargin = entry.margin;
      List<Widget> components = [];

      for (ComponentModel component in entry.components) {
        switch (component.type) {
          case ComponentType.Text:
            TextComponent textComponent = component;
            Widget builtComponent = buildTextComponent(textComponent);
            builtComponents[ComponentType.Text.toString()] = builtComponent;
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
            builtComponents[ComponentType.Image.toString()] = builtComponent;
            components.add(builtComponent);
            break;
          case ComponentType.Button:
            ButtonComponent buttonComponent = component;
            Widget builtComponent = buildButtonComponent(buttonComponent);
            builtComponents[ComponentType.Button.toString()] = builtComponent;
            components.add(builtComponent);
            break;
          default:
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
      children: entries,
    );
  }

  Widget buildTextComponent(TextComponent textComponent) {
    Margin componentMargin = textComponent.margin;

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
            top: componentMargin.top,
            bottom: componentMargin.bottom,
            left: componentMargin.left,
            right: componentMargin.right),
        child: Text(
          textComponent.placeholder,
          style: TextStyle(fontSize: textComponent.textSize),
          textAlign:
              TextComponent.getTextAlignment(textComponent.textComponentAlign),
        ),
      ),
    );
  }

  Widget buildInputFieldComponent(InputFieldComponent inputFieldComponent) {
    Margin componentMargin = inputFieldComponent.margin;
    TextEditingController controller = TextEditingController();

    builtComponents[ComponentType.Input.toString()] = controller;

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
            top: componentMargin.top,
            bottom: componentMargin.bottom,
            left: componentMargin.left,
            right: componentMargin.right),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
              border: OutlineInputBorder(), hintText: 'Enter a search term'),
        ),
      ),
    );
  }

  Widget buildImageComponent(ImageComponent imageComponent) {
    Margin componentMargin = imageComponent.margin;
    double imageHeight = imageComponent.height;
    double imageWidth = imageComponent.width;

    return Container(
      width: imageWidth,
      height: imageHeight,
      child: Image(
        image: NetworkImage(imageComponent.imageUrl),
      ),
    );
  }

  Widget buildButtonComponent(ButtonComponent buttonComponent) {
    Margin margin = buttonComponent.margin;
    Color backgroundColor;

    if (buttonComponent.color != null) {
      Color backgroundColor = buttonComponent.color != null
          ? Color(int.parse(buttonComponent.color.replaceAll("#", "0xff")))
          : Colors.white;
    }

    return Expanded(
      child: Container(
        alignment: buttonComponent.alignment == ComponentAlign.center
            ? Alignment.center
            : buttonComponent.alignment == ComponentAlign.left
                ? Alignment.centerLeft
                : buttonComponent.alignment == ComponentAlign.right
                    ? Alignment.centerRight
                    : Alignment.center,
        child: TextButton(
            onPressed: () {
              processButtonClick();
            },
            child: Text(
              buttonComponent.text,
              style: TextStyle(color: backgroundColor),
            )),
      ),
    );
  }

  void processButtonClick() {
    builtComponents.forEach((key, value) {
      if (key == "ComponentType.Input") {
        TextEditingController controller = value;
        print(controller.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildView();
  }
}
