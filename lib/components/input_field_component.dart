import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:flutter/material.dart';

class InputFieldComponent extends Component {
  String ID;
  ViewMargin margin;
  String hintText;
  String errorText;
  bool isFormGood = true;
  Form form;

  InputFieldComponent(
      String ID, ViewMargin margin, String hintText, String errorText)
      : super(ID, margin, ComponentType.Input) {
    this.ID = ID;
    this.margin = margin;
    this.hintText = hintText;
    this.errorText = errorText;
  }

  InputFieldComponent.forStatic() : super.forStatic();

  @override
  Widget buildComponentView() {
    TextEditingController controller = TextEditingController();

    form = Form(
      key: GlobalKey<FormState>(),
      child: TextFormField(
        controller: controller,
        validator: (String value) {
          return (value == null || value.isEmpty) ? this.errorText : null;
        },
        decoration: InputDecoration(
            hintText: this.hintText, errorText: isFormGood ? null : "Error"),
      ),
    );

    return form;
  }

  @override
  InputFieldComponent buildComponent(
      List componentParams, bool fromConstraint, {bool replaceComponent=false}) {
    String ID = componentParams[0];
    ViewMargin margin = fromConstraint
        ? ViewMargin.fromString(componentParams[1])
        : componentParams[1];
    String hintText = componentParams[2];
    String errorText = componentParams[3];

    return InputFieldComponent(ID, margin, hintText, errorText);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "component_properties": [ID, margin.toString(), hintText, errorText],
      "type": "input"
    };
  }

  void setValue(dynamic value) {
    TextFormField textFormField = form.child;
    textFormField.controller.text = value;
  }

  @override
  String getValue() {
    GlobalKey<FormState> key = form.key;
    TextFormField textFormField = form.child;

    if (key.currentState.validate()) {
      return textFormField.controller.text;
    }

    return null;
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
