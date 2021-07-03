import 'package:constraint_view/components/button_component.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';

class ListComponent extends Component {
  String ID;
  List data;
  List<Component> initialComponents = [];
  List<Component> componentViews = [];
  ViewMargin margin;

  ListComponent(this.ID, this.margin, this.data, this.initialComponents)
      : super(ID, margin, ComponentType.List);

  ListComponent.forStatic() : super.forStatic();

  @override
  buildComponent(List componentParams, bool fromConstraint) {
    // TODO: implement buildComponent
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  Widget buildComponentView() {
    throw UnimplementedError();
  }

  @override
  getValue({int index}) {
    return data[index];
  }

  @override
  setValue(value) {
    this.data = value;
  }

  addValue(dynamic value) {
    this.data.add(value);
  }
}
