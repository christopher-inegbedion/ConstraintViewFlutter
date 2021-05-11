import 'package:constraint_view/custom_views/draggable_sheet.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/section_data.dart';
import 'package:flutter/material.dart';

import 'enums/component_align.dart';
import 'models/margin_model.dart';

class ConstraintView extends StatefulWidget {
  final bool canOpen;
  final bool fullyExpanded;
  SectionData sectionData;
  _ConstraintViewState state;

  ConstraintView(this.canOpen, this.fullyExpanded, this.sectionData) {
    state = _ConstraintViewState(canOpen, fullyExpanded, sectionData);
  }

  @override
  _ConstraintViewState createState() => state;
}

class _ConstraintViewState extends State<ConstraintView> {
  bool canOpen;
  bool fullyExpanded;
  SectionData sectionData;

  _ConstraintViewState(this.canOpen, this.fullyExpanded, this.sectionData);

  void changeCurrentState(String state) {
    setState(() {
      sectionData.setCurrentConfig(state);
    });
  }

  void addConfigEntryWithComponent(int configEntryIndex, String section,
      Margin margin, ComponentType componentType, List componentParams) {
    sectionData.state.addConfigEntryWithComponent(
        configEntryIndex, section, margin, componentType, componentParams);

    setState(() {});
  }

  void addComponentToConfigEntry(int configEntryIndex, int componentIndex,
      String section, ComponentType componentType, List componentParams) {
    sectionData.state.addComponentToConfigEntry(configEntryIndex,
        componentIndex, section, componentType, componentParams);

    setState(() {});
  }

  void removeComponentFromConfigEntry(
      int componentIndex, int configEntryIndex, String section) {
    sectionData.state.removeComponentFromConfigEntry(
        componentIndex, configEntryIndex, section);
    setState(() {});
  }

  void removeConfigEntry(int configIndex, String section) {
    sectionData.state.removeConfigEntry(configIndex, section);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Container(key: UniqueKey(), child: sectionData.state.buildTopView()),
          TextButton(
              onPressed: () {
                addComponentToConfigEntry(0, 0, "top", ComponentType.Text, [
                  "text",
                  Margin(0, 0, 0, 0),
                  "placeholder" + DateTime.now().toString(),
                  ComponentAlign.center,
                  20.0,
                  "#000000"
                ]);
              },
              child: Text("add")),
          Container(
            margin: EdgeInsets.only(left: 50),
            child: TextButton(
                onPressed: () {
                  removeConfigEntry(0, "top");
                },
                child: Text("remove")),
          ),
          Container(
            margin: EdgeInsets.only(left: 110),
            child: TextButton(
                onPressed: () {
                  changeCurrentState("3");
                },
                child: Text("refresh")),
          ),
          Container(
              key: UniqueKey(),
              child: ConstraintDraggableSheet(
                  this.canOpen, this.fullyExpanded, sectionData))
        ],
      ),
    );
  }
}
