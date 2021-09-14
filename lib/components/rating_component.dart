import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingComponent extends Component {
  double ratingValue = 1;
  int itemSize;
  ComponentAlign componentAlign;

  RatingComponent(
      String ID, ViewMargin margin, ComponentAlign componentAlign, int itemSize)
      : super(ID, margin, ComponentType.Rating) {
    this.ID = ID;
    this.margin = margin;
    this.componentAlign = componentAlign;
    this.itemSize = itemSize;
  }

  RatingComponent.forStatic() : super.forStatic();

  @override
  buildComponent(List componentParams, bool fromConstraint,
      {bool replaceComponent = false}) {
    String ID = componentParams[0];
    ViewMargin margin = fromConstraint
        ? ViewMargin.fromString(componentParams[1])
        : componentParams[1];
    ComponentAlign componentAlign =
        getComponentAlignFromString(componentParams[2]);

    int itemSize = int.parse(componentParams[3].toString());

    return RatingComponent(ID, margin, componentAlign, itemSize);
  }

  static Alignment getAlignment(ComponentAlign align) {
    return align == ComponentAlign.center
        ? Alignment.center
        : align == ComponentAlign.left
            ? Alignment.centerLeft
            : align == ComponentAlign.right
                ? Alignment.centerRight
                : Alignment.center;
  }

  @override
  buildComponentView() {
    return Container(
      alignment: RatingComponent.getAlignment(componentAlign),
      child: RatingBar.builder(
        glow: false,
        itemSize: double.parse(itemSize.toString()),
        initialRating: 1,
        minRating: 1,
        direction: Axis.horizontal,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return Icon(
                Icons.sentiment_very_dissatisfied,
                color: Colors.red,
              );
            case 1:
              return Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.redAccent,
              );
            case 2:
              return Icon(
                Icons.sentiment_neutral,
                color: Colors.amber,
              );
            case 3:
              return Icon(
                Icons.sentiment_satisfied,
                color: Colors.lightGreen,
              );
            case 4:
              return Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.green,
              );
            default:
              return Icon(Icons.star, color: Colors.green);
          }
        },
        onRatingUpdate: (rating) {
          ratingValue = rating;
        },
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }

  @override
  getValue() {
    return ratingValue;
  }

  @override
  setValue(value) {
    ratingValue = double.parse(value.toString());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "component_properties": [
        ID,
        margin.toString(),
        componentAlignToString(componentAlign),
        itemSize
      ],
      "type": "rating"
    };
  }
}
