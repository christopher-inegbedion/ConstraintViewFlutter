import 'package:constraint_view/components/button_component.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:constraint_view/models/section_data.dart';
import 'package:flutter/material.dart';

class ListComponent extends Component {
  String ID;
  List data;
  List<Component> componentsTemplate = [];
  List<Component> componentViews = [];
  ViewMargin margin;

  ListComponent(this.ID, this.margin, this.data, this.componentsTemplate)
      : super(ID, margin, ComponentType.List);

  ListComponent.forStatic() : super.forStatic();

  @override
  buildComponent(List componentParams, bool fromConstraint,
      {bool replaceComponent = false}) {
    String ID = componentParams[0];
    ViewMargin margin = fromConstraint
        ? ViewMargin.fromString(componentParams[1])
        : componentParams[1];
    List data = componentParams[2];
    List componentsTemplateJson = componentParams[3];
    List<Component> componentsTemplate = [];
    for (Map component in componentsTemplateJson) {
      componentsTemplate.add(SectionData.parseComponentFromList(component));
    }
    return ListComponent(ID, margin, data, componentsTemplate);
  }

  @override
  Map<String, dynamic> toJson() {
    List componentsTemplateJson = [];
    for (Component c in componentsTemplate) {
      componentsTemplateJson.add(c.toJson());
    }

    return {
      "type": "list",
      "component_properties": [
        ID,
        margin.toString(),
        data,
        componentsTemplateJson
      ]
    };
  }

  @override
  Widget buildComponentView() {
    throw UnimplementedError();
  }

  @override
  getValue({int index}) {
    // if (index == null) {
    //   return data;
    // }
    return data[index];
  }

  @override
  setValue(value) {
    this.data = value;
  }

  addValue(dynamic value) {
    //sometimes more than 1 value might be passed, eg: [[value1], [value2]]
    bool areAllValsLists = true;
    for (dynamic val in value) {
      if (!(val is List)) {
        areAllValsLists = false;
      }
    }

    if (areAllValsLists) {
      for (var val in value) {
        this.data.add(val);
      }
    } else {
      this.data.add(value);
    }
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
