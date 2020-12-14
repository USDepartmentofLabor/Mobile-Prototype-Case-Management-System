import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eps_mobile/survey_js_render/models/display_text_value.dart';
import 'package:eps_mobile/survey_js_render/models/survey_object.dart';

class Radiogroup extends SurveyObject {
  String name;
  List<DisplayTextValue> choices;

  FormBuilderRadioGroup widget;
  List<FormBuilderFieldOption> options;

  Radiogroup() {
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
          //label: choice.displayText,
          child: Text(choice.displayText),
          value: choice.value,
        ));
      }
      widget = FormBuilderRadioGroup(
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
