import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/margin_model.dart';

class ComponentModel {
  String ID;
  ComponentType type;
  Margin margin;
  dynamic value;

  ComponentModel(this.ID, this.margin, this.type);
}
