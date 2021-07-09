import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';

class DropdownComponent extends Component {
  List<String> data = [];
  ComponentAlign alignment;
  Map command;
  String currentItem;
  String initialItem;

  DropdownComponent(String ID, ViewMargin margin, List<String> data,
      String initialItem, ComponentAlign align, Map command)
      : super(ID, margin, ComponentType.DropDown) {
    this.data = data;
    this.alignment = alignment;
    this.command = command;
    this.currentItem = initialItem;
  }

  DropdownComponent.forStatic() : super.forStatic();

  @override
  buildComponent(List componentParams, bool fromConstraint) {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  buildComponentView({Function function, Function notifyFunction}) {
    return DropdownButton(
        value: currentItem,
        icon: const Icon(Icons.arrow_downward),
        underline: Container(
          height: 2,
          color: Colors.blueGrey,
        ),
        onChanged: (value) {
          currentItem = value;
          function();
          notifyFunction();
        },
        items: data.map<DropdownMenuItem<String>>((String e) {
          return DropdownMenuItem<String>(
            value: e,
            child: Text(e),
          );
        }).toList());
  }

  @override
  getValue() {
    return currentItem;
  }

  @override
  setValue(value) {
    if (data.contains(value)) {
      currentItem = value;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
