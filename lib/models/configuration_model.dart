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

  void addConfigEntry(int prevConfigEntryIndex, String section, Margin margin,
      ComponentType componentType, List componentParams) {
    ConfigEntry defaultConfigEntry = ConfigEntry([], margin);

    Component builtComponent = addComponent(componentType, componentParams);

    if (builtComponent != null) {
      defaultConfigEntry.components.add(builtComponent);
    } else {
      throw Exception(
          "Error building component with params: componentType: $componentType, componentParams: $componentParams");
    }

    if (prevConfigEntryIndex == -1) {
      if (section == "top") {
        topSection.insert(topSection.length, defaultConfigEntry);
      } else if (section == "bottom") {
        bottomSection.insert(topSection.length, defaultConfigEntry);
      }
    } else {
      if (section == "top") {
        topSection.insert(prevConfigEntryIndex + 1, defaultConfigEntry);
      } else if (section == "bottom") {
        bottomSection.insert(prevConfigEntryIndex + 1, defaultConfigEntry);
      }
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
