import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/widgets.dart';
import 'package:model_viewer/model_viewer.dart';

class LiveModelComponent extends Component {
  String ID;
  String url;
  bool arEnabled;
  Margin margin;

  LiveModelComponent(String ID, String url, bool arEnabled, Margin margin)
      : super(ID, margin, ComponentType.LiveModel) {
    this.ID = ID;
    this.url = url;
    this.arEnabled = arEnabled;
    this.margin = margin;
  }

  LiveModelComponent.forStatic() : super.forStatic();

  @override
  LiveModelComponent buildComponent(List componentParams) {
    String ID = componentParams[0];
    String url = componentParams[1];
    bool arEnabled = componentParams[2];
    margin = componentParams[3];

    return LiveModelComponent(ID, url, arEnabled, margin);
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
    // TODO: implement getValue
    throw UnimplementedError();
  }

  @override
  setValue(value) {
    // TODO: implement setValue
    throw UnimplementedError();
  }
}
