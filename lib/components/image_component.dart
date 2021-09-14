import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';

class ImageComponent extends Component {
  String imageUrl;
  double height;
  double width;
  bool maxWidth;

  ImageComponent(String ID, ViewMargin margin, String imageUrl, double height,
      double width, bool maxWidth)
      : super(ID, margin, ComponentType.Image) {
    this.ID = ID;
    this.margin = margin;
    this.imageUrl = imageUrl;
    this.height = height;
    this.width = width;
    this.maxWidth = maxWidth;
  }

  ImageComponent.forStatic() : super.forStatic();

  @override
  buildComponentView({BuildContext context}) {
    return Image(
      width: maxWidth ? MediaQuery.of(context).size.width : width,
      height: height,
      image: NetworkImage(imageUrl),
    );
  }

  @override
  ImageComponent buildComponent(List componentParams, bool fromConstraint, {bool replaceComponent=false}) {
    String ID = componentParams[0];
    ViewMargin margin = fromConstraint
        ? ViewMargin.fromString(componentParams[1])
        : componentParams[1];
    String imageUrl = componentParams[2];
    double height = double.parse(componentParams[3].toString());
    double width = double.parse(componentParams[4].toString());
    bool maxWidth = componentParams[5];

    return ImageComponent(ID, margin, imageUrl, height, width, maxWidth);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "component_properties": [
        ID,
        margin.toString(),
        imageUrl,
        height,
        width,
        maxWidth
      ],
      "type": "image"
    };
  }

  @override
  getValue() {
    return imageUrl;
  }

  @override
  setValue(value) {
    // TODO: implement setValue
    throw UnimplementedError();
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
