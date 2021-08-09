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
      this.id,
      this.componentAction,
      this.name,
      this.commandName,
      this.success,
      this.failure,
      this.usePrevResult,
      this.value);

  dynamic run(dynamic result) {
    this.result = result;
    if (usePrevResult) {
      if (result != null) {
        value = result;
      }
    } else {
      // List newValue = [];
      // if (value != null) {
      //   value.forEach((element) {
      //     newValue.add(formatText(element, result));
      //   });
      //   value = jsonDecode(jsonEncode(newValue));
      // }

      // bool allDataIsString = true;

      // for (dynamic i in value) {
      //   dynamic formattedData = formatText(i, result);
      //   if (!(formattedData is String)) {
      //     allDataIsString = false;
      //   }
      // }

      // if (allDataIsString) {
      //   List<String> newList = [];
      //   this.value.forEach((element) {
      //     newList.add(formatText(element, result));
      //   });

      //   this.value = newList;
      // } else {
      //   List newList = [];
      //   int i = 0;
      //   this.value.forEach((element) {
      //     newList.add(formatText(element, result));
      //     i++;
      //   });

      //   this.value = newList;
      // }
    }
  }

  dynamic getValue() {
    bool allDataIsString = true;

    for (dynamic i in value) {
      dynamic formattedData = formatText(i, result);
      if (!(formattedData is String)) {
        allDataIsString = false;
      }
    }

    if (allDataIsString) {
      List<String> newList = [];
      this.value.forEach((element) {
        newList.add(formatText(element, result));
      });

      return newList;
    } else {
      List newList = [];
      this.value.forEach((element) {
        newList.add(formatText(element, result));
      });

      return newList;
    }
  }

  void runSuccess() {
    ComponentActionCommand newCommand = this.success;
    if (newCommand != null) {
      newCommand.run(result);
    }
  }

  void runFailure() {
    ComponentActionCommand newCommand = this.failure;
    if (newCommand != null) {
      newCommand.run(result);
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
              String key = string.substring(startIndex, endIndex - 1);
              if (componentAction.viewControllerState.configurationModel
                          .configurationInputs !=
                      null &&
                  componentAction.viewControllerState.configurationModel
                      .configurationInputs
                      .containsKey(key)) {
                dynamic word = componentAction.viewControllerState
                    .configurationModel.configurationInputs[key];

                return word;
              } else {
                int index;
                if (double.parse(key) != null) {
                  index = int.parse(key);
                }

                if (prevResult.length > index) {
                  dynamic word = prevResult[index];
                  return word;
                }
              }
              if (double.parse(key) != null) {
                int index = int.parse(key);
              }
            }
          }
        }
      }
    } else if (data is List) {
      String type = data.runtimeType.toString();
      bool allDataIsString = true;

      for (dynamic i in data) {
        dynamic formattedData = formatText(i, prevResult);
        if (!(formattedData is String)) {
          allDataIsString = false;
        }
      }

      if (allDataIsString) {
        List<String> newList = [];
        data.forEach((element) {
          newList.add(formatText(element, prevResult));
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
