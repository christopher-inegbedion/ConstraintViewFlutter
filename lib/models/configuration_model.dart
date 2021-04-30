
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/entry_model.dart';

class ConfigurationModel {
  String ID;
  List<ConfigEntry> topSection;
  List<ConfigEntry> bottomSection;

  ConfigurationModel(this.ID, this.topSection, this.bottomSection);
}
