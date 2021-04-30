import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';

class ImageComponent extends ComponentModel {
  String imageUrl;
  double height;
  double width;

  ImageComponent(
      String ID, Margin margin, String imageUrl, double height, double width)
      : super(ID, margin, ComponentType.Image) {
    this.imageUrl = imageUrl;
    this.height = height;
    this.width = width;
  }
}
