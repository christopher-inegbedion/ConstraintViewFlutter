import 'package:constraint_view/models/configuration_model.dart';
import 'package:constraint_view/view_controller.dart';

///This model defines the view for the Top/Bottom section
class SectionData {
  List<ConfigurationModel> allStates;
  ConfigurationModel state;

  SectionData(this.allStates);

  void setCurrentConfig(String configID) {
    for (ConfigurationModel configurationModel in allStates) {
      if (configurationModel.ID == configID) {
        this.state = configurationModel;
        return;
      }
    }

    throw Exception("config ID $configID not found");
  }
}
