import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';

class ConfigEntry {
  List<ComponentModel> components;
  Margin margin;

  ConfigEntry(this.components, this.margin);
}
