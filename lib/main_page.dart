import 'package:constraint_view/constraint_view.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: ConstraintView(true)));
  }
}
