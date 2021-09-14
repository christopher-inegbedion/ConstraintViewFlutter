import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/widgets.dart';
import 'package:model_viewer/model_viewer.dart';

class LiveModelComponent extends Component {
  String ID;
  String url;
  bool arEnabled;
  ViewMargin margin;

  LiveModelComponent(String ID, String url, bool arEnabled, ViewMargin margin)
      : super(ID, margin, ComponentType.LiveModel) {
    this.ID = ID;
    this.url = url;
    this.arEnabled = arEnabled;
    this.margin = margin;
  }

  LiveModelComponent.forStatic() : super.forStatic();

  @override
  LiveModelComponent buildComponent(List componentParams, bool fromConstraint, {bool replaceComponent=false}) {
    String ID = componentParams[0];
    ViewMargin margin = fromConstraint
        ? ViewMargin.fromString(componentParams[1])
        : componentParams[1];
    String url = componentParams[2];
    bool arEnabled = componentParams[3];

    return LiveModelComponent(ID, url, arEnabled, margin);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "component_properties": [ID, margin.toString(), url, arEnabled],
      "type": "live_model"
    };
  }

  @override
  buildComponentView() {
    Widget view = ModelViewer(
      src: this.url,
      alt: "A 3D model of an astronaut",
      ar: arEnabled,
      autoRotate: true,
      cameraControls: true,
    );

    return view;
  }

  @override
  getValue() {
    return url;
  }

  @override
  setValue(value) {
    this.url = value;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
