import 'package:constraint_view/models/section_data.dart';
import 'package:constraint_view/view_controller.dart';
import 'package:flutter/material.dart';

class ConstraintDraggableSheet extends StatefulWidget {
  final bool canOpen;
  final bool fullyExpanded;
  SectionData sectionData;

  ConstraintDraggableSheet(this.canOpen, this.fullyExpanded, this.sectionData);

  @override
  _ConstraintDraggableSheetState createState() =>
      _ConstraintDraggableSheetState(
          this.canOpen, this.fullyExpanded, this.sectionData);
}

class _ConstraintDraggableSheetState extends State<ConstraintDraggableSheet> {
  bool canOpen;
  bool fullyExpanded;
  SectionData sectionData;

  double maxExpandHeight;
  double minExpandHeight;
  double initialExpansionHeight;

  Widget view;

  _ConstraintDraggableSheetState(
      bool canOpen, bool fullyExpanded, SectionData sectionData) {
    this.canOpen = canOpen;
    this.fullyExpanded = fullyExpanded;
    this.sectionData = sectionData;

    maxExpandHeight = sectionData.state.draggableSheetMaxHeight;
    minExpandHeight = 0.04;
    initialExpansionHeight = 0.3;

    view = sectionData.state.buildBottomView();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: canOpen
            ? this.fullyExpanded
                ? maxExpandHeight
                : initialExpansionHeight
            : minExpandHeight,
        minChildSize: minExpandHeight,
        maxChildSize: maxExpandHeight,
        builder: (BuildContext context, ScrollController scrollController) {
          return Card(
            color: canOpen ? Colors.white : Colors.grey[300],
            elevation: 10,
            margin: EdgeInsets.zero,
            child: SingleChildScrollView(
              physics: canOpen
                  ? BouncingScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 5,
                    width: 30,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      child: view,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
