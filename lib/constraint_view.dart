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

  void addComponent() {
    List componentParams = [
      "text",
      Margin(0, 0, 0, 0),
      "new text",
      ComponentAlign.center,
      20.0,
      "#000000"
    ];

    sectionData.state.addConfigEntry(
        -1, "top", Margin(0, 0, 0, 0), ComponentType.Text, componentParams);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Container(key: UniqueKey(), child: sectionData.state.buildTopView()),
          // TextButton(
          //     onPressed: () {
          //       addComponent();
          //     },
          //     child: Text("item")),
          Container(
              key: UniqueKey(),
              child: ConstraintDraggableSheet(
                  this.canOpen, this.fullyExpanded, sectionData))
        ],
      ),
    );
  }
}
