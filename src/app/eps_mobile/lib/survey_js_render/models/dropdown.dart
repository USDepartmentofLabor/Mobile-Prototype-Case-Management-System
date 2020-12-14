import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eps_mobile/survey_js_render/models/display_text_value.dart';
import 'package:eps_mobile/survey_js_render/models/survey_object.dart';

class Dropdown extends SurveyObject {
  String name;
  List<DisplayTextValue> choices;

  FormBuilderDropdown widget;
  List<DisplayTextValue> options;

  Dropdown() {
    this.name = '';
    this.choices = new List<DisplayTextValue>();
  }

  @override
  List<Widget> getWidgets(String surveyResponseValue) {
    var list = new List<Widget>();
    if (this.widget == null) {
      widget = FormBuilderDropdown(
        decoration: InputDecoration(labelText: title),
        items: choices
            .map((choice) => DropdownMenuItem(
                  value: choice.value,
                  child: Text(choice.displayText),
                ))
            .toList(),
        attribute: name,
      );
    }
    list.add(this.widget);
    return list;
  }

  @override
  String getResponse(Map formBuilderKeyValue) {
    var rtn = '"' + name + '": ';
    if (formBuilderKeyValue.containsKey(name)) {
      rtn = rtn + '"' + formBuilderKeyValue[name] + '"';
    }
    return rtn;
  }

  @override
  Map getResponseSubMap(Map formBuilderKeyValue) {
    var value = '';
    if (formBuilderKeyValue.containsKey(name)) {
      value = formBuilderKeyValue[name];
    }
    return {name: value};
  }
}
