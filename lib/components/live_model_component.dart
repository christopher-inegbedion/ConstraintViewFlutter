import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/widgets.dart';
import 'package:model_viewer/model_viewer.dart';

class LiveModelComponent extends Component {
  String ID;
  Margin margin;

  LiveModelComponent(String ID, Margin margin)
      : super(ID, margin, ComponentType.LiveModel) {
    this.ID = ID;
    this.margin = margin;
  }

  @override
  buildComponent(List componentParams) {
    // TODO: implement buildComponent
    throw UnimplementedError();
  }

  @override
  buildComponentView() {
    Widget view = ModelViewer(
      src: 'assets/wraith.glb',
      alt: "A 3D model of an astronaut",
      ar: true,
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
