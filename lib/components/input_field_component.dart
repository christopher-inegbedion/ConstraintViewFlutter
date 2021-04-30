import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/margin_model.dart';

class InputFieldComponent extends ComponentModel {
  InputFieldComponent(String ID, Margin margin, String hintText)
      : super(ID, margin, ComponentType.Input);
}
