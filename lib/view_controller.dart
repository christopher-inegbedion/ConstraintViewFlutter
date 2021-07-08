import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/components/button_component.dart';
import 'package:constraint_view/components/dropdown_component.dart';
import 'package:constraint_view/components/image_component.dart';
import 'package:constraint_view/components/input_field_component.dart';
import 'package:constraint_view/components/live_model_component.dart';
import 'package:constraint_view/components/text_component.dart';
import 'package:constraint_view/enums/component_type.dart';
import 'package:constraint_view/enums/component_align.dart';
import 'package:constraint_view/models/component_model.dart';
import 'package:constraint_view/models/config_entry.dart';
import 'package:constraint_view/models/configuration_model.dart';
import 'package:constraint_view/models/margin_model.dart';
import 'package:constraint_view/utils/network_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:model_viewer/model_viewer.dart';
import 'package:web_socket_channel/io.dart';

import 'components/list_component.dart';
import 'models/section_data.dart';

class ViewController extends StatefulWidget {
  ConfigurationModel configurationModel;
  final String section;
  ViewControllerState state;

  ViewController(this.configurationModel, this.section) {
    state = ViewControllerState(configurationModel, section);
  }

  void notifyChange() {
    state.notifyChange();
  }

  @override
  ViewControllerState createState() => state;
}

class ViewControllerState extends State<ViewController> {
  ConfigurationModel configurationModel;
  String section;
  Map builtComponents = {};
  Map<String, dynamic> savedValues = {};
  Map<String, dynamic> tempValues = {};
  List<ConfigEntry> sectionToUse;
  bool ignoreScoll = false;
  bool initialised = false;
  BuildContext dialogContext;

  Widget view;

  ViewControllerState(this.configurationModel, this.section);

  Future<void> showDialogWithMsg(String title, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        dialogContext = context;
        return AlertDialog(
          title: Text(title),
          content: Container(
            child: Text(msg),
          ),
        );
      },
    );
  }

  Future showConstraintInDialog(String constraintName, String stageName) async {
    Future<SectionData> sectionData = SectionData.forStatic(
            stageName, constraintName, "taskID", "userID", null)
        .fromConstraint(constraintName);
    SectionData sData;
    ViewController topView;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              content: Container(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: FutureBuilder(
                          future: sectionData,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              sData = snapshot.data;
                              sData.setInitialState("1");
                              topView = sData.state.buildTopView();
                              print(topView.state.savedValues);
                              return topView;
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }))
                ]),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      print(sData.state.topViewController.state.savedValues);
                      // if (topView.state.savedValues["config_inputs"] ==
                      //     null) {
                      // } else {
                      //   print(topView.state.savedValues["config_inputs"]);
                      //   Navigator.pop(context);
                      // }
                    },
                    child: Text("Done"))
              ],
            );
          });
        });
  }

  Future<dynamic> showDialogWithButtons(
      String title, List<String> inputFields) async {
    GlobalKey<FormState> key = GlobalKey();
    List<TextEditingController> textControllers = [];
    List values = [];
    inputFields.forEach((element) {
      textControllers.add(TextEditingController());
    });

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Container(
              width: MediaQuery.of(context).size.width,
              child: Form(
                  key: key,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: inputFields.length,
                      itemBuilder: (context, index) {
                        dialogContext = context;
                        return TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            controller: textControllers[index],
                            decoration: InputDecoration(
                              hintText: inputFields[index],
                            ));
                      })),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    if (key.currentState.validate()) {
                      textControllers.forEach((controller) {
                        values.add(controller.text);
                      });
                      Navigator.pop(context, values);
                    }
                  },
                  child: Text("Done"))
            ],
          );
        });
  }

  void closeDialog() {
    Navigator.of(context).pop();
  }

  Widget buildView() {
    if (this.configurationModel == null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
                child: Center(
              child: Text("SectionData currentConfig not set"),
            )),
          ],
        ),
      );
    }

    if (this.section == "top") {
      sectionToUse = configurationModel.topSection;
    } else if (this.section == "bottom") {
      sectionToUse = configurationModel.bottomSection;
    } else {
      return Expanded(
          child: Center(
        child: Text("Unrecognized section: ${section}"),
      ));
    }

    List<Widget> entries = [];

    for (ConfigEntry entry in this.sectionToUse) {
      ViewMargin entryMargin = entry.margin;
      List<Widget> components = [];

      for (Component component in entry.components) {
        switch (component.type) {
          case ComponentType.Text:
            TextComponent textComponent = component;
            Widget builtComponent = buildTextComponent(textComponent);

            components.add(builtComponent);
            break;
          case ComponentType.Input:
            InputFieldComponent inputFieldComponent = component;
            Widget builtComponent =
                buildInputFieldComponent(inputFieldComponent);
            components.add(builtComponent);
            break;
          case ComponentType.Image:
            ImageComponent imageComponent = component;
            Widget builtComponent = buildImageComponent(imageComponent);

            components.add(builtComponent);
            break;
          case ComponentType.Button:
            ButtonComponent buttonComponent = component;
            Widget builtComponent = buildButtonComponent(buttonComponent);

            components.add(builtComponent);
            break;
          case ComponentType.LiveModel:
            LiveModelComponent liveModelComponent = component;
            Widget builtComponent = buildLiveModelComponent(liveModelComponent);

            components.add(builtComponent);
            break;
          case ComponentType.List:
            ListComponent listComponent = component;
            Widget builtComponent = buildListComponent(listComponent);

            components.add(builtComponent);
            break;
          case ComponentType.DropDown:
            DropdownComponent dropdownComponent = component;
            Widget builtComponent = buildDropdownComponent(dropdownComponent);

            components.add(builtComponent);
            break;
          default:
            throw Exception("Component ${component.type} cannot be rendered");
        }
      }

      Container entryWidget = Container(
        child: Row(
          children: components,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        margin: EdgeInsets.only(
            top: entryMargin.top,
            bottom: entryMargin.bottom,
            left: entryMargin.left,
            right: entryMargin.right),
      );
      entries.add(entryWidget);
    }

    return SingleChildScrollView(
      key: GlobalKey(),
      physics: ignoreScoll
          ? NeverScrollableScrollPhysics()
          : AlwaysScrollableScrollPhysics(),
      child: section == "top"
          ? Container(
              width: MediaQuery.of(context).size.width,
              color: HexColor(configurationModel.bgColor),
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: configurationModel.centerTopSectionData
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: entries,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: configurationModel.centerTopSectionData
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: entries,
            ),
    );
  }

  Widget buildDropdownComponent(DropdownComponent dropdownComponent) {
    ViewMargin componentMargin = dropdownComponent.margin;

    DropdownButton dropdownButton = dropdownComponent.buildComponentView(
        function: () {
          processActionCommand(dropdownComponent, dropdownComponent.command);
        },
        notifyFunction: notifyChange);
    builtComponents[dropdownComponent.ID] = dropdownComponent;

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
            top: componentMargin.top,
            bottom: componentMargin.bottom,
            left: componentMargin.left,
            right: componentMargin.right),
        child: dropdownButton,
      ),
    );
  }

  Widget buildListComponent(ListComponent listComponent) {
    List<Widget> views = [];
    List listData = listComponent.data;
    List<Component> listComponents = listComponent.initialComponents;
    for (int i = 0; i < listData.length; i++) {
      for (int j = 0; j < listData[i].length; j++) {
        dynamic componentData = listData[i][j];

        switch (listComponents[j].type) {
          case ComponentType.Text:
            if (!(componentData is List)) {
              TextComponent templateComponent = listComponents[j];
              TextComponent textComponent = TextComponent(
                  "${templateComponent.ID}-${(i)}-$j",
                  templateComponent.margin,
                  templateComponent.placeholder,
                  templateComponent.textComponentAlign,
                  templateComponent.textSize,
                  templateComponent.textColor);
              textComponent.parentListIndex = listComponent.dataIndex;
              textComponent.dataIndex = i;
              textComponent.componentIndex = j;
              textComponent.inList = true;
              textComponent.setValue(componentData);
              builtComponents[textComponent.ID] = textComponent;

              views.add(buildTextComponent(textComponent));

              listComponent.componentViews.add(textComponent);
            }
            break;
          case ComponentType.List:
            if ((componentData is List)) {
              ListComponent templateComponent = listComponents[j];
              ListComponent listComponent1 = ListComponent(
                  "${templateComponent.ID}-${(i)}-$j",
                  templateComponent.margin,
                  templateComponent.data,
                  templateComponent.initialComponents);
              listComponent1.parentListIndex = listComponent.dataIndex;
              listComponent1.dataIndex = i;
              listComponent1.componentIndex = j;
              listComponent1.inList = true;
              listComponent1.setValue(componentData);
              builtComponents[listComponent1.ID] = listComponent1;

              views.add(buildListComponent(listComponent1));
              listComponent.componentViews.add(listComponent1);
            }
            break;
          case ComponentType.Button:
            if (!(componentData is List)) {
              ButtonComponent templateComponent = listComponents[j];
              ButtonComponent buttonComponent = ButtonComponent(
                  "${templateComponent.ID}-${(i)}-$j",
                  templateComponent.margin,
                  templateComponent.text,
                  templateComponent.alignment,
                  templateComponent.actionCommand);
              buttonComponent.parentListIndex = listComponent.dataIndex;
              buttonComponent.dataIndex = i;
              buttonComponent.componentIndex = j;
              buttonComponent.inList = true;
              buttonComponent.setValue(componentData);
              builtComponents[buttonComponent.ID] = buttonComponent;

              views.add(buildButtonComponent(buttonComponent));
              listComponent.componentViews.add(buttonComponent);
            }
            break;
          case ComponentType.Input:
            if (!(componentData is List)) {
              InputFieldComponent templateComponent = listComponents[j];
              InputFieldComponent inputFieldComponent = InputFieldComponent(
                  "${templateComponent.ID}-${(i)}-$j",
                  templateComponent.margin,
                  templateComponent.hintText,
                  templateComponent.errorText);

              inputFieldComponent.parentListIndex = listComponent.dataIndex;
              inputFieldComponent.dataIndex = i;
              inputFieldComponent.componentIndex = j;
              inputFieldComponent.inList = true;
              builtComponents[inputFieldComponent.ID] = inputFieldComponent;

              views.add(buildInputFieldComponent(inputFieldComponent));
              listComponent.componentViews.add(inputFieldComponent);
            }
            break;
          default:
            break;
        }
      }
    }

    Widget listWidget = ListView.builder(
        shrinkWrap: true,
        itemCount: views.length,
        itemBuilder: (context, index) {
          return views[index];
        });
    ViewMargin componentMargin = listComponent.margin;

    builtComponents[listComponent.ID] = listComponent;

    return Expanded(
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(
              top: componentMargin.top,
              bottom: componentMargin.bottom,
              left: componentMargin.left,
              right: componentMargin.right),
          child: listWidget),
    );
  }

  Widget buildTextComponent(TextComponent textComponent) {
    ViewMargin componentMargin = textComponent.margin;
    textComponent.placeholder = formatText(textComponent.placeholder);
    Text textWidget = textComponent.buildComponentView();

    builtComponents[textComponent.ID] = textComponent;

    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
            top: componentMargin.top,
            bottom: componentMargin.bottom,
            left: componentMargin.left,
            right: componentMargin.right),
        child: textWidget,
      ),
    );
  }

  Widget buildInputFieldComponent(InputFieldComponent inputFieldComponent) {
    ViewMargin componentMargin = inputFieldComponent.margin;

    Form textFormField = inputFieldComponent.buildComponentView();

    builtComponents[inputFieldComponent.ID] = inputFieldComponent;

    return Flexible(
      child: Container(
        margin: EdgeInsets.only(
            top: componentMargin.top,
            bottom: componentMargin.bottom,
            left: componentMargin.left,
            right: componentMargin.right),
        child: textFormField,
      ),
    );
  }

  Widget buildImageComponent(ImageComponent imageComponent) {
    ViewMargin componentMargin = imageComponent.margin;
    double imageHeight = imageComponent.height;
    double imageWidth = imageComponent.width;

    Image imageWidget = imageComponent.buildComponentView();

    builtComponents[imageComponent.ID] = imageComponent;

    return Container(
      margin: EdgeInsets.only(
          top: componentMargin.top,
          bottom: componentMargin.bottom,
          left: componentMargin.left,
          right: componentMargin.right),
      width: imageWidth,
      height: imageHeight,
      child: imageWidget,
    );
  }

  Widget buildButtonComponent(ButtonComponent buttonComponent) {
    ViewMargin componentMargin = buttonComponent.margin;
    TextButton textButton = buttonComponent.buildComponentView(function: () {
      processActionCommand(buttonComponent, buttonComponent.actionCommand);
    });

    builtComponents[buttonComponent.ID] = buttonComponent;

    return Flexible(
      child: Container(
        margin: EdgeInsets.only(
            top: componentMargin.top,
            bottom: componentMargin.bottom,
            left: componentMargin.left,
            right: componentMargin.right),
        alignment: buttonComponent.alignment == ComponentAlign.center
            ? Alignment.center
            : buttonComponent.alignment == ComponentAlign.left
                ? Alignment.centerLeft
                : buttonComponent.alignment == ComponentAlign.right
                    ? Alignment.centerRight
                    : Alignment.center,
        child: textButton,
      ),
    );
  }

  Widget buildLiveModelComponent(LiveModelComponent liveModelComponent) {
    ViewMargin componentMargin = liveModelComponent.margin;
    ModelViewer liveModel = liveModelComponent.buildComponentView();

    builtComponents[liveModelComponent.ID] = liveModel;

    return Listener(
      onPointerDown: (d) {
        ignoreScoll = true;
        notifyChange();
      },
      onPointerUp: (d) {
        ignoreScoll = false;
        notifyChange();
      },
      child: SizedBox(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: liveModel,
          margin: EdgeInsets.only(
              top: componentMargin.top,
              bottom: componentMargin.bottom,
              left: componentMargin.left,
              right: componentMargin.right),
        ),
      ),
    );
  }

  void processActionCommand(Component commandInitiator, Map command) {
    if (command != null) {
      ComponentAction componentAction =
          ComponentAction.fromJson(this, commandInitiator, command);
      componentAction.start();
    } else {
      print("No command");
    }
  }

  String formatText(String msg) {
    bool isLeftBracketFound = false;
    int startIndex = 0;
    int endIndex = 0;
    String string = msg;
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
            String word = string.substring(startIndex, endIndex - 1);
            print(configurationModel.configurationInputs);

            if (configurationModel.configurationInputs != null) {
              if (configurationModel.configurationInputs.containsKey(word)) {
                string = string.replaceAll(
                    string.substring(startIndex - 1, endIndex),
                    configurationModel.configurationInputs[word]);
              } else {
                if (savedValues.containsKey(word)) {
                  string = string.replaceAll(
                      string.substring(startIndex - 1, endIndex),
                      savedValues[word]);
                } else {
                  string = string.replaceAll(
                      string.substring(startIndex - 1, endIndex), "Loading");
                }
              }
            } else {
              return string;
            }
          }
        }
      }
    }

    return string;
  }

  Component getComponentFromListWithIndex(
      String listComponentID, int dataIndex, int componentIndex) {
    Component component = getComponentFromID(listComponentID);
    Component result;
    if (component.type != ComponentType.List) {
      throw Exception("List component required");
    }

    ListComponent listComponent = component;
    listComponent.componentViews.forEach((element) {
      Component component = element;
      if (component.componentIndex == componentIndex &&
          component.dataIndex == dataIndex) {
        result = component;
        return result;
      }
    });

    return result;
  }

  Component getComponentFromList(String listComponentID, String componentID) {
    Component component = getComponentFromID(listComponentID);
    Component result;
    if (component.type != ComponentType.List) {
      throw Exception("List component required");
    }

    ListComponent listComponent = component;
    listComponent.componentViews.forEach((element) {
      Component component = element;
      if (component.ID == componentID) {
        result = component;
        return;
      }
    });

    return result;
  }

  dynamic getComponentValue(String componentID) {
    Component component = getComponentFromID(componentID);

    dynamic componentValue = component.getValue();

    if (componentValue != null) {
      return componentValue;
    }

    return null;
  }

  Component getComponentFromID(String id) {
    if (!builtComponents.containsKey(id)) {
      throw Exception("Component with ID $id cannot be found");
    }
    Component component = builtComponents[id];
    return component;
  }

  void setComponentValue(String componentID, dynamic value) {
    Component component = getComponentFromID(componentID);

    component.setValue(value);
    notifyChange();
  }

  void addValueToListComponent(String componentID, dynamic value,
      {Component componentData}) {
    Component component;
    if (componentID != null) {
      component = getComponentFromID(componentID);
    } else {
      component = componentData;
    }

    if (component.type != ComponentType.List) {
      throw Exception("This method can only be used with a List component");
    }

    ListComponent listComponent = component;
    listComponent.addValue(value);

    notifyChange();
  }

  void notifyChange() {
    setState(() {});
  }

  void changeComponent(String initialComponentID, Component newComponent,
      {String listComponentID, int dataIndex, int componentIndex}) {
    bool componentFound = true;
    int index = 0;

    for (ConfigEntry entry in this.sectionToUse) {
      entry.components.removeWhere((element) {
        Component tempComp = element;
        componentFound = tempComp.ID == initialComponentID;
        return componentFound;
      });

      if (componentFound) {
        entry.components.insert(index, newComponent);
        break;
      }
      index++;
    }

    notifyChange();
  }

  @override
  void initState() {
    super.initState();
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   setState(() {
    //   });
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialised) {
      view = buildView();
      initialised = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return view;
  }
}
