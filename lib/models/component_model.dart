import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/cupertino.dart';

///A type of widget in an [Entry] that can be interacted with.
abstract class Component extends StatefulWidget {
  String ID;
  ComponentType type;
  ViewMargin margin;
  dynamic value;
  State state;

  //These variables are for children of the list component
  int parentListIndex;
  int dataIndex;
  int componentIndex;
  bool inList = false;

  Component(this.ID, this.margin, this.type);

  Component.forStatic() {}

  buildComponentView();

  buildComponent(List componentParams, bool fromConstraint, {bool replaceComponent=false});

  setValue(dynamic value);

  getValue();

  Map<String, dynamic> toJson();

  ComponentAlign getComponentAlignFromString(String componentAlign) {
    switch (componentAlign) {
      case "center":
        return ComponentAlign.center;
      case "left":
        return ComponentAlign.left;
      case "right":
        return ComponentAlign.right;
      default:
        return null;
    }
  }
}
