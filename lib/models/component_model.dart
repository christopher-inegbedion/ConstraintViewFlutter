import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/margin_model.dart';

///A type of widget in an [Entry] that can be interacted with.
abstract class Component {
  String ID;
  ComponentType type;
  ViewMargin margin;
  dynamic value;

  //These variables are for children of the list component
  int parentListIndex;
  int dataIndex;
  int componentIndex;
  bool inList = false;

  Component(this.ID, this.margin, this.type);

  Component.forStatic() {}

  buildComponentView();

  buildComponent(List componentParams, bool fromConstraint);

  setValue(dynamic value);

  getValue();
}
