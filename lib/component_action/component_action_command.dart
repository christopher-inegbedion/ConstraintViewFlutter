import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:flutter/material.dart';

abstract class ComponentActionCommand {
  String id;
  ComponentAction componentAction;
  String name;
  String commandName;
  ComponentActionCommand success;
  ComponentActionCommand failure;
  bool usePrevResult;
  List value;
  dynamic result;

  ComponentActionCommand(
      this.componentAction,
      this.id,
      this.name,
      this.commandName,
      this.success,
      this.failure,
      this.usePrevResult,
      this.value);

  dynamic run(dynamic result) {
    if (usePrevResult) {
      if (result != null) {
        value = result;
      }
    } else {
      List newValue = [];
      value.forEach((element) {
        newValue.add(formatText(element, result));
      });
      value = newValue;
    }
  }

  void runSuccess() {
    if (this.success != null) {
      success.run(result);
    }
  }

  void runFailure() {
    if (this.failure != null) {
      failure.run(result);
    }
  }

  dynamic formatText(dynamic data, List prevResult) {
    if (data is String) {
      bool isLeftBracketFound = false;
      int startIndex = 0;
      int endIndex = 0;
      String string = data.toString();
      int replaceableWords = 0;

      string.characters.forEach((element) {
        var character = element;
        if (character == "{") {
          isLeftBracketFound = true;
        } else if (character == "}") {
          if (isLeftBracketFound) {
            isLeftBracketFound = false;
            replaceableWords++;
          }
        }
      });

      for (int i = 0; i < replaceableWords; i++) {
        int count = 0;
        List characters = string.characters.toList();
        for (String character in characters) {
          count++;
          if (character == "{") {
            startIndex = count;
            isLeftBracketFound = true;
          } else if (character == "}") {
            if (isLeftBracketFound) {
              endIndex = count;

              isLeftBracketFound = false;
              int index = int.parse(string.substring(startIndex, endIndex - 1));
              dynamic word = prevResult[index];
              return word;
            }
          }
        }
      }
    } else if (data is List) {
      String type = data.runtimeType.toString();
      if (type == "List<String>") {
        List<String> newList = [];
        int i = 0;
        data.forEach((element) {
          newList.add(formatText(element, prevResult));
          i++;
        });

        return newList;
      } else {
        List newList = [];
        int i = 0;
        data.forEach((element) {
          newList.add(formatText(element, prevResult));
          i++;
        });

        return newList;
      }
    }

    return data;
  }
}
