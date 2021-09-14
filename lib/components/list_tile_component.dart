import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:constraint_view/view_controller.dart';
import 'package:flutter/material.dart';

class ListTileComponent extends Component {
  String text;
  String miniText;
  Map selectActionCommand;
  Map unSelectActionCommand;
  bool selected = false;
  int fontSize;
  int miniFontSize;
  ComponentAlign alignment;
  Function selectFunc;
  Function unSelectFunc;

  ListTileComponent(
      String ID,
      ViewMargin margin,
      int fontSize,
      int miniFontSize,
      String text,
      String miniText,
      ComponentAlign alignment,
      Map selectActionCommand,
      Map unSelectActionCommand)
      : super(ID, margin, ComponentType.ListTile) {
    this.state = ListTileState(this);
    this.text = text;
    this.miniText = miniText;
    this.selectActionCommand = selectActionCommand;
    this.unSelectActionCommand = unSelectActionCommand;
    this.fontSize = fontSize;
    this.miniFontSize = miniFontSize;
    this.alignment = alignment;
  }

  ListTileComponent.forStatic() : super.forStatic();

  @override
  buildComponent(List componentParams, bool fromConstraint, {bool replaceComponent=false}) {
    String ID = componentParams[0];
    ViewMargin margin = fromConstraint
        ? ViewMargin.fromString(componentParams[1])
        : componentParams[1];
    int fontSize = componentParams[2];
    int miniFontSize = componentParams[3];
    String text = componentParams[4];
    String miniText = componentParams[5];
    ComponentAlign alignment = getComponentAlignFromString(componentParams[6]);
    Map selectActionCommand = componentParams[7];
    Map unSelectActionCommand = componentParams[8];

    return ListTileComponent(ID, margin, fontSize, miniFontSize, text, miniText,
        alignment, selectActionCommand, unSelectActionCommand);
  }

  @override
  buildComponentView() {
    return this;
  }

  void setSelectFunc(Function selectFunc) {
    this.selectFunc = selectFunc;
  }

  void setUnSelectFunc(Function unSelectFunc) {
    this.unSelectFunc = unSelectFunc;
  }

  void setSelectedState() {
    this.text = "!selected";
  }

  @override
  getValue() {
    return text;
  }

  @override
  setValue(value) {
    this.text = value;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "list_tile",
      "component_properties": [
        ID,
        margin.toString(),
        fontSize,
        miniFontSize,
        text,
        miniText,
        componentAlignToString(alignment),
        selectActionCommand,
        unSelectActionCommand
      ]
    };
  }

  @override
  State<StatefulWidget> createState() {
    return state;
  }
}

class ListTileState extends State<ListTileComponent> {
  ListTileComponent listTileComponent;

  ListTileState(this.listTileComponent);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      selectedTileColor: Colors.red,
      title: Text(
        listTileComponent.text,
        style: TextStyle(
            fontSize: double.parse(listTileComponent.fontSize.toString())),
      ),
      subtitle: listTileComponent.miniText.isEmpty
          ? null
          : Text(
              listTileComponent.miniText,
              style: TextStyle(
                  fontSize:
                      double.parse(listTileComponent.miniFontSize.toString())),
            ),
      selected: listTileComponent.selected,
      onTap: () {
        if (listTileComponent.selected) {
          listTileComponent.unSelectFunc();
          setState(() {
            listTileComponent.selected = false;
          });
        } else {
          listTileComponent.selectFunc();
          setState(() {
            listTileComponent.selected = true;
          });
        }
        // notifyStateFunc();
      },
    );
  }
}
