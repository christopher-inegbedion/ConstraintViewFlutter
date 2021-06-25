import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';

class ListComponent extends Component {
  String ID;
  List data;
  List<Component> components;
  ViewMargin margin;

  ListComponent(this.ID, this.margin, this.data, this.components)
      : super(ID, margin, ComponentType.List);

  ListComponent.forStatic() : super.forStatic();

  @override
  buildComponent(List componentParams, bool fromConstraint) {
    // TODO: implement buildComponent
    throw UnimplementedError();
  }

  @override
  Widget buildComponentView() {
    List<Widget> componentViews = [];
    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < data[i].length; j++) {
        Component component = components[j];
        dynamic componentData = data[i][j];

        switch (component.type) {
          case ComponentType.Text:
            if (!(componentData is List)) {
              TextComponent textComponent = component;
              ViewMargin margin = textComponent.margin;
              textComponent.setValue(componentData);

              componentViews.add(Container(
                  margin: EdgeInsets.only(
                      top: margin.top,
                      bottom: margin.bottom,
                      left: margin.left,
                      right: margin.right),
                  child: textComponent.buildComponentView()));
            }
            break;
          case ComponentType.List:
            if ((componentData is List)) {
              ListComponent listComponent = component;
              ViewMargin margin = listComponent.margin;
              listComponent.setValue(componentData);
              componentViews.add(Container(
                  margin: EdgeInsets.only(
                      top: margin.top,
                      bottom: margin.bottom,
                      left: margin.left,
                      right: margin.right),
                  child: listComponent.buildComponentView()));
            }
            break;
          default:
            break;
        }
      }
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: componentViews.length,
      itemBuilder: (context, index) {
        return componentViews[index];
      },
    );
  }

  @override
  getValue() {
    // TODO: implement getValue
    throw UnimplementedError();
  }

  @override
  setValue(value) {
    this.data = value;
  }
}
