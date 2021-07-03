import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';

class ConfigEntry {
  List<Component> components;
  ViewMargin margin;

  ConfigEntry(this.components, this.margin);

  Map<String, dynamic> toJson() {
    List componentsJson = [];
    for (Component component in components) {
      componentsJson.add(component.toJson());
    }
    return {"components": componentsJson, "margin": margin.toString()};
  }
}
