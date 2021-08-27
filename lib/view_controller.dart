import 'dart:convert';

import 'package:constraint_view/component_action/component_action.dart';
import 'package:constraint_view/component_action/component_action_command.dart';
import 'package:constraint_view/components/button_component.dart';
import 'package:constraint_view/components/color_block_component.dart';
import 'package:constraint_view/components/dropdown_component.dart';
import 'package:constraint_view/components/image_component.dart';
import 'package:constraint_view/components/input_field_component.dart';
import 'package:constraint_view/components/list_tile_component.dart';
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
  bool isDialog = false;
  ViewControllerState state;

  ViewController(this.configurationModel, this.section, [this.isDialog]) {
    state =
        ViewControllerState(configurationModel, section, isDialog: isDialog);
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
  bool isDialog = false;
  BuildContext dialogContext;
  SectionData sData;
  double screenHeight;
  double screenWidth;

  Widget view;

  ViewControllerState(this.configurationModel, this.section, {this.isDialog});

  Future<void> showDialogWithMsg(String title, String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        dialogContext = context;
        return AlertDialog(
          title: Text(title),
          content: Container(
            child: SelectableText(msg),
          ),
        );
      },
    );
  }

  Future showConstraintInDialog(String constraintName, String stageName) async {
    Future<SectionData> sectionData = SectionData.forStatic(
            stageName, constraintName, "taskID", "userID", null)
        .fromConstraint(constraintName);

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
                      width: screenWidth,
                      height: screenHeight / 2,
                      child: FutureBuilder(
                          future: sectionData,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              sData = snapshot.data;
                              sData.setInitialState("1");
                              return sData.state.buildTopView(isDialog: true);
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }))
                ]),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      if (sData.state.topViewController.state
                              .savedValues["config_inputs"] !=
                          null) {
                        Navigator.pop(context, [
                          sData.state.topViewController.state
                              .savedValues["config_inputs"]
                        ]);
                      }
                    },
                    child: Text("Done"))
              ],
            );
          });
        });
  }

  Future<TimeOfDay> showTimeSelector() async {
    TimeOfDay _time = TimeOfDay(hour: 10, minute: 0);
    return await showTimePicker(context: context, initialTime: _time);
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
              width: screenWidth,
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

  Future showDialogForSingleChoice(String title, List<String> options) async {
    List<Widget> widgets = [];
    for (String i in options) {
      widgets.add(
        TextButton(
          child: Text(i),
          onPressed: () {
            Navigator.pop(context, i);
          },
        ),
      );
    }
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(title),
            children: widgets,
          );
        });
  }

  void closeDialog() {
    if (sData.state.topViewController.state.savedValues["config_inputs"] !=
        null) {
      Navigator.pop(dialogContext,
          [sData.state.topViewController.state.savedValues["config_inputs"]]);
    } else {
      Navigator.of(dialogContext).pop();
    }
  }

  Widget buildView() {
    if (this.configurationModel == null) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
          case ComponentType.ListTile:
            ListTileComponent listTileComponent = component;
            Widget builtComponent = buildListTileComponent(listTileComponent);

            components.add(builtComponent);
            break;
          case ComponentType.ColorBlock:
            ColorBlockComponent colorBlockComponent = component;
            Widget builtComponent =
                buildColorBlockComponent(colorBlockComponent);

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
      physics: ignoreScoll
          ? NeverScrollableScrollPhysics()
          : AlwaysScrollableScrollPhysics(),
      child: section == "top"
          ? Container(
              width: screenWidth,
              color: HexColor(configurationModel.bgColor),
              height: isDialog
                  ? null
                  : configurationModel.centerTopSectionData
                      ? MediaQuery.of(context).size.height
                      : null,
              child: Column(
                mainAxisSize: MainAxisSize.max,
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

  Widget buildColorBlockComponent(ColorBlockComponent colorBlockComponent) {
    ViewMargin componentMargin = colorBlockComponent.margin;
    Container widget = colorBlockComponent.buildComponentView();
    builtComponents[colorBlockComponent.ID] = colorBlockComponent;

    return Expanded(
        child: Container(
      margin: EdgeInsets.only(
          top: componentMargin.top,
          bottom: componentMargin.bottom,
          left: componentMargin.left,
          right: componentMargin.right),
      child: widget,
    ));
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
    List<Component> listComponents = listComponent.componentsTemplate;
    for (int i = 0; i < listData.length; i++) {
      for (int j = 0; j < listData[i].length; j++) {
        dynamic componentData = listData[i][j];

        if (componentData != null) {
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
                    templateComponent.componentsTemplate);
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
            case ComponentType.ListTile:
              if (!(componentData is List)) {
                ListTileComponent templateComponent = listComponents[j];
                ListTileComponent listTileComponent = ListTileComponent(
                    "${templateComponent.ID}-${(i)}-$j",
                    templateComponent.margin,
                    templateComponent.fontSize,
                    templateComponent.miniFontSize,
                    templateComponent.text,
                    templateComponent.miniText,
                    templateComponent.alignment,
                    templateComponent.selectActionCommand,
                    templateComponent.unSelectActionCommand);
                listTileComponent.parentListIndex = listComponent.dataIndex;
                listTileComponent.dataIndex = i;
                listTileComponent.componentIndex = j;
                listTileComponent.inList = true;
                listTileComponent.setValue(componentData);
                builtComponents[listTileComponent.ID] = listTileComponent;

                views.add(buildListTileComponent(listTileComponent));
                listComponent.componentViews.add(listTileComponent);
              }
              break;
            default:
              break;
          }
        }
      }
    }

    Widget listWidget = ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: views.length,
        itemBuilder: (context, index) {
          return views[index];
        });
    ViewMargin componentMargin = listComponent.margin;

    builtComponents[listComponent.ID] = listComponent;

    return Expanded(
      child: Container(
          width: screenWidth,
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

  Widget buildListTileComponent(ListTileComponent listTileComponent) {
    ViewMargin componentMargin = listTileComponent.margin;
    listTileComponent.text = formatText(listTileComponent.text);
    listTileComponent.miniText = formatText(listTileComponent.miniText);
    listTileComponent.selectFunc = () {
      processActionCommand(
          listTileComponent, listTileComponent.selectActionCommand);
    };
    listTileComponent.unSelectFunc = () {
      processActionCommand(
          listTileComponent, listTileComponent.unSelectActionCommand);
    };
    Widget listTileWidget = listTileComponent.buildComponentView();

    builtComponents[listTileComponent.ID] = listTileComponent;

    return Expanded(
        key: GlobalKey(),
        child: Container(
          margin: EdgeInsets.only(
              top: componentMargin.top,
              bottom: componentMargin.bottom,
              left: componentMargin.left,
              right: componentMargin.right),
          alignment: listTileComponent.alignment == ComponentAlign.center
              ? Alignment.center
              : listTileComponent.alignment == ComponentAlign.left
                  ? Alignment.centerLeft
                  : listTileComponent.alignment == ComponentAlign.right
                      ? Alignment.centerRight
                      : Alignment.center,
          child: listTileWidget,
        ));
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

    Image imageWidget = imageComponent.buildComponentView(context: context);

    builtComponents[imageComponent.ID] = imageComponent;

    return Container(
      margin: EdgeInsets.only(
          top: componentMargin.top,
          bottom: componentMargin.bottom,
          left: componentMargin.left,
          right: componentMargin.right),
      child: imageWidget,
    );
  }

  Widget buildButtonComponent(ButtonComponent buttonComponent) {
    ViewMargin componentMargin = buttonComponent.margin;
    buttonComponent.text = formatText(buttonComponent.text);
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
        height: screenHeight,
        width: screenWidth,
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
      ComponentAction.fromJson(this, commandInitiator, command).start();
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

  void changeComponentValue(String id) {
    setComponentValue(id, 'value');
  }

  void notifyChange() {
    if (mounted) {
      setState(() {});
    }
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

  void setTextColor(TextComponent component, String color) {
    component.textColor = color;
    notifyChange();
  }

  void runCommand() {
    if (configurationModel.topViewCommand != null) {
      if (this.section == "top") {
        for (Map command in configurationModel.topViewCommand) {
          processActionCommand(null, command);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
      runCommand();
    });
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
    return buildView();
  }
}
