import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';

class ImageComponent extends Component {
  String imageUrl;
  double height;
  double width;

  ImageComponent(
      String ID, ViewMargin margin, String imageUrl, double height, double width)
      : super(ID, margin, ComponentType.Image) {
    this.imageUrl = imageUrl;
    this.height = height;
    this.width = width;
  }

  ImageComponent.forStatic() : super.forStatic();

  @override
  buildComponentView() {
    return Image(
      image: NetworkImage(imageUrl),
    );
  }

  @override
  ImageComponent buildComponent(List componentParams, bool fromConstraint) {
    String ID = componentParams[0];
    ViewMargin margin = fromConstraint ? ViewMargin.fromString(componentParams[1]) : componentParams[1];
    String imageUrl = componentParams[2];
    double height = componentParams[3];
    double width = componentParams[4];

    return ImageComponent(ID, margin, imageUrl, height, width);
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
}
