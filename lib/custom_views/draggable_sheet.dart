import 'package:constraint_view/models/section_data.dart';
import 'package:constraint_view/view_controller.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ConstraintDraggableSheet extends StatefulWidget {
  SectionData sectionData;

  ConstraintDraggableSheet(this.sectionData);

  @override
  _ConstraintDraggableSheetState createState() =>
      _ConstraintDraggableSheetState(this.sectionData);
}

class _ConstraintDraggableSheetState extends State<ConstraintDraggableSheet> {
  SectionData sectionData;

  double maxExpandHeight;
  double minExpandHeight;
  double initialExpansionHeight;

  Widget view;

  _ConstraintDraggableSheetState(SectionData sectionData) {
    this.sectionData = sectionData;

    maxExpandHeight = sectionData.state.draggableSheetMaxHeight;
    minExpandHeight = 0.04;
    initialExpansionHeight = 0.3;

    view = sectionData.state.buildBottomView();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: sectionData.state.bottomSectionCanOpen
            ? sectionData.state.bottomSectionCanExpand
                ? maxExpandHeight
                : initialExpansionHeight
            : minExpandHeight,
        minChildSize: minExpandHeight,
        maxChildSize: maxExpandHeight,
        builder: (BuildContext context, ScrollController scrollController) {
          return Card(
            color: sectionData.state.bottomSectionCanOpen
                ? HexColor(sectionData.state.bottomSheetColor)
                : Colors.grey[850],
            elevation: 10,
            margin: EdgeInsets.zero,
            child: SingleChildScrollView(
              physics: sectionData.state.bottomSectionCanOpen
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
                  Container(
                    child: view,
                  )
                ],
              ),
            ),
          );
        });
  }
}
