import 'package:constraint_view/models/configuration_model.dart';

class ConstraintViewModel {
  List<ConfigurationModel> allConfigs;
  ConfigurationModel currentConfig;

  ConstraintViewModel(this.allConfigs, this.currentConfig);
}
