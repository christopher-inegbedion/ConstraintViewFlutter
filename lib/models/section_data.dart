import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/models/configuration_model.dart';
import 'package:constraint_view/view_controller.dart';

import 'config_entry.dart';
import 'margin_model.dart';

///This model defines the view for the Top/Bottom section
class SectionData {
  List<ConfigurationModel> allStates;
  ConfigurationModel state;
  String initialStateID;
  bool isComplete;
  bool isRequired;

  ConfigurationModel defaultState = ConfigurationModel(
      "constraint_not_connected",
      true,
      [
        ConfigEntry([
          TextComponent(
              "no_connection_text",
              Margin(0, 0, 0, 0),
              "Awaiting connection to constraint",
              ComponentAlign.center,
              30.0,
              "#ffffff")
        ], Margin(0, 0, 0, 0))
      ],
      [],
      false,
      false,
      draggableSheetMaxHeight: 0.1,
      bgColor: "#000000",
      bottomSheetColor: "#000000");

  SectionData(this.allStates, this.isRequired) {
    this.setCurrentConfig("", model: defaultState);
  }

  void setCurrentConfig(String configID, {ConfigurationModel model}) {
    if (configID == "") {
      this.state = model;
      return;
    } else {
      for (ConfigurationModel configurationModel in allStates) {
        if (configurationModel.ID == configID) {
          this.state = configurationModel;
          return;
        }
      }
    }

    throw Exception("config ID $configID not found");
  }

  void setNoConnectionState() {
    setCurrentConfig("", model: defaultState);
  }

  void setInitialState(String configID) {
    for (ConfigurationModel configurationModel in allStates) {
      if (configurationModel.ID == configID) {
        this.initialStateID = configID;
        this.state = configurationModel;
        return;
      }
    }

    throw Exception("config ID $configID not found");
  }
}
