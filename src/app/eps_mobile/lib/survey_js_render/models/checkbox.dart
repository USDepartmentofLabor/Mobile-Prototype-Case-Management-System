import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eps_mobile/survey_js_render/models/display_text_value.dart';
import 'package:eps_mobile/survey_js_render/models/survey_object.dart';

class Checkbox extends SurveyObject {
  String name;
  List<DisplayTextValue> choices;

  FormBuilderCheckboxGroup widget;
  List<FormBuilderFieldOption> options;

  Checkbox() {
    this.name = '';
    this.choices = new List<DisplayTextValue>();
  }

  @override
  List<Widget> getWidgets(String surveyResponseValue) {
    var list = new List<Widget>();
    if (this.widget == null) {
      options = new List<FormBuilderFieldOption>();
      for (var choice in choices) {
        options.add(FormBuilderFieldOption(
          value: choice.value,
        ));
      }
      widget = FormBuilderCheckboxGroup(
        decoration: InputDecoration(labelText: title),
        options: options,
        attribute: name,
      );
    }
    list.add(this.widget);
    return list;
  }

  @override
  String getResponse(Map formBuilderKeyValue) {
    var rtn = '"' + name + '": ';
    var selectedValues = new List<String>();
    if (formBuilderKeyValue.containsKey(name)) {
      for (var selected in formBuilderKeyValue[name]) {
        selectedValues.add('"' + selected + '"');
      }
    }
    rtn = rtn + selectedValues.toString();
    return rtn;
  }

  @override
  Map getResponseSubMap(Map formBuilderKeyValue) {
    var selectedValues = [];
    if (formBuilderKeyValue.containsKey(name)) {
      for (var selected in formBuilderKeyValue[name]) {
        selectedValues.add(selected);
      }
    }
    return {name: selectedValues};
  }
}
