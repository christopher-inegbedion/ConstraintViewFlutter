import 'package:constraint_view/components/button_component.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/config_entry.dart';
import 'package:constraint_view/models/section_data.dart';

import '../view_controller.dart';
import 'margin_model.dart';

class ConfigurationModel {
  String ID;
  SectionData sectionData;
  bool centerTopSectionData;
  double draggableSheetMaxHeight;
  List<ConfigEntry> topSection;
  List<ConfigEntry> bottomSection;
  ViewController topViewController;
  ViewController bottomViewController;

  ConfigurationModel(
      this.ID, this.centerTopSectionData, this.topSection, this.bottomSection,
      {this.draggableSheetMaxHeight = 0.7});

  ViewController buildTopView() {
    topViewController = ViewController(this, "top");
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
      Margin margin, ComponentType componentType, List componentParams) {
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
    } else if (section == "bottom") {
      if (configEntryIndex > this.bottomSection.length) {
        throw Exception(
            "ConfigEntry index: $configEntryIndex is greater than bottomSection length");
      }
      configEntry = this.bottomSection.elementAt(configEntryIndex);
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

  void removeConfigEntry(int configIndex, String section) {
    if (section == "top") {
      topSection.removeAt(configIndex);
    } else if (section == "bottom") {
      bottomSection.removeAt(configIndex);
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
        component = TextComponent.forStatic().buildComponent(componentParams);
        break;
      default:
    }

    return component;
  }
}
