import 'package:constraint_view/components/button_component.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/config_entry.dart';
import 'package:constraint_view/models/section_data.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:web_socket_channel/io.dart';

import '../view_controller.dart';
import 'margin_model.dart';

class ConfigurationModel {
  String ID;
  String bgColor;
  String bottomSheetColor;
  bool bottomSectionCanOpen;
  bool bottomSectionCanExpand;
  bool centerTopSectionData;
  double draggableSheetMaxHeight;
  List<ConfigEntry> topSection;
  List<ConfigEntry> bottomSection;
  List<Map> topViewCommand = [];
  List<Map> bottomViewCommand = [];

  ViewController topViewController;
  ViewController bottomViewController;

  String stageName;
  String constraintName;
  String taskID;
  String userID;
  Map<String, dynamic> configurationInputs;

  ConfigurationModel(
      this.ID,
      this.centerTopSectionData,
      this.topSection,
      this.bottomSection,
      this.bottomSectionCanOpen,
      this.bottomSectionCanExpand,
      {this.topViewCommand,
      this.bottomViewCommand,
      this.draggableSheetMaxHeight = 0.7,
      this.bgColor = "#ffffff",
      this.bottomSheetColor = "#ffffff",
      this.stageName,
      this.constraintName,
      this.taskID,
      this.userID,
      this.configurationInputs});

  ViewController buildTopView({bool isDialog = false}) {
    topViewController = ViewController(this, "top", isDialog = isDialog);
    return topViewController;
  }

  ViewController buildBottomView() {
    bottomViewController = ViewController(this, "bottom");
    return bottomViewController;
  }

  void modifyComponent(
      String componentID, dynamic valueToChange, String section) {
    if (section == "top") {
      for (ConfigEntry entry in topSection) {
        for (Component component in entry.components) {
          if (component.ID == componentID) {
            component.setValue(valueToChange);
            topViewController.notifyChange();
          }
        }
      }
    } else if (section == "bottom") {
      for (ConfigEntry entry in bottomSection) {
        for (Component component in entry.components) {
          if (component.ID == componentID) {
            component.setValue(valueToChange);
            bottomViewController.notifyChange();
          }
        }
      }
    }
  }

  String getComponentValue(String componentID, String section) {
    if (section == "top") {
      for (ConfigEntry entry in topSection) {
        for (Component component in entry.components) {
          if (component.ID == componentID) {
            return component.getValue();
          }
        }
      }
    } else if (section == "bottom") {
      for (ConfigEntry entry in bottomSection) {
        for (Component component in entry.components) {
          if (component.ID == componentID) {
            return component.getValue();
          }
        }
      }
    }

    return null;
  }

  void addConfigEntryWithComponent(int configEntryIndex, String section,
      ViewMargin margin, ComponentType componentType, List componentParams) {
    ConfigEntry defaultConfigEntry = ConfigEntry([], margin);

    Component builtComponent = addComponent(componentType, componentParams);

    if (builtComponent != null) {
      defaultConfigEntry.components.add(builtComponent);
    } else {
      throw Exception(
          "Error building component with params: componentType: $componentType, componentParams: $componentParams");
    }

    if (configEntryIndex == -1) {
      if (section == "top") {
        topSection.insert(topSection.length, defaultConfigEntry);
      } else if (section == "bottom") {
        bottomSection.insert(topSection.length, defaultConfigEntry);
      }
    } else {
      if (section == "top") {
        topSection.insert(configEntryIndex, defaultConfigEntry);
      } else if (section == "bottom") {
        bottomSection.insert(configEntryIndex, defaultConfigEntry);
      }
    }
  }

  void addComponentToConfigEntry(int configEntryIndex, int componentIndex,
      String section, ComponentType componentType, List componentParams) {
    ConfigEntry configEntry;

    if (section == "top") {
      if (configEntryIndex > this.topSection.length) {
        throw Exception(
            "ConfigEntry index: $configEntryIndex is greater than topSection length");
      }

      configEntry = this.topSection.elementAt(configEntryIndex);
      if (configEntry == null) {
        throw Exception("ConfigEntry with index $configEntryIndex not found");
      }
    } else if (section == "bottom") {
      if (configEntryIndex > this.bottomSection.length) {
        throw Exception(
            "ConfigEntry index: $configEntryIndex is greater than bottomSection length");
      }

      configEntry = this.bottomSection.elementAt(configEntryIndex);
      if (configEntry == null) {
        throw Exception("ConfigEntry with index $configEntryIndex not found");
      }
    }

    Component builtComponent = addComponent(componentType, componentParams);
    configEntry.components.add(builtComponent);
  }

  void removeComponentFromConfigEntry(
      int componentIndex, int configEntryIndex, String section) {
    ConfigEntry configEntry;

    if (section == "top") {
      if (configEntryIndex > this.topSection.length) {
        throw Exception(
            "ConfigEntry index: $configEntryIndex is greater than topSection length");
      }
      configEntry = this.topSection.elementAt(configEntryIndex);
      configEntry.components.removeAt(componentIndex);
    } else if (section == "bottom") {
      if (configEntryIndex > this.bottomSection.length) {
        throw Exception(
            "ConfigEntry index: $configEntryIndex is greater than bottomSection length");
      }
      configEntry = this.bottomSection.elementAt(configEntryIndex);
      configEntry.components.removeAt(componentIndex);
    }
  }

  void removeConfigEntry(int configEntryIndex, String section) {
    if (section == "top") {
      topSection.removeAt(configEntryIndex);
    } else if (section == "bottom") {
      bottomSection.removeAt(configEntryIndex);
    }
  }

  Component addComponent(ComponentType componentType, List componentParams) {
    Component component;

    switch (componentType) {
      case ComponentType.Button:
        component = null;
        break;
      case ComponentType.ColorBlock:
        component = null;
        break;
      case ComponentType.Image:
        component = null;
        break;
      case ComponentType.Input:
        component = null;
        break;
      case ComponentType.Text:
        component =
            TextComponent.forStatic().buildComponent(componentParams, true);
        break;
      default:
    }

    return component;
  }

  Map<String, dynamic> toJson() {
    List topSectionData = [];
    for (ConfigEntry configEntry in topSection) {
      topSectionData.add(configEntry.toJson());
    }

    List bottomSectionData = [];
    for (ConfigEntry configEntry in bottomSection) {
      bottomSectionData.add(configEntry.toJson());
    }

    return {
      "id": this.ID,
      "bg_color": this.bgColor,
      "bottom_section_can_expand": this.bottomSectionCanExpand ? "1" : "0",
      "bottom_section_can_open": this.bottomSectionCanOpen ? "1" : "0",
      "bottom_sheet_color": this.bottomSheetColor,
      "center_top_section_data": this.centerTopSectionData ? "1" : "0",
      "draggable_sheet_max_height": this.draggableSheetMaxHeight,
      "top_section": topSectionData,
      "bottom_section": bottomSectionData,
      "top_view_command": topViewCommand,
      "bottom_view_command": bottomViewCommand
    };
  }
}
