import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eps_mobile/survey_js_render/models/survey_object.dart';

class BooleanControl extends SurveyObject {
  String title;
  FormBuilderCheckbox widget;

  BooleanControl() {
    this.name = '';
    this.title = '';
  }

  @override
  List<Widget> getWidgets(String surveyResponseValue) {
    var widgets = new List<Widget>();
    if (this.widget == null) {
      // title is optional, display name if blank
      if (title == '') {
        title = name;
      }
      var value = false;
      if (surveyResponseValue != '') {
        if (surveyResponseValue == 'true') {
          value = true;
        }
      }
      this.widget = FormBuilderCheckbox(
        attribute: this.name,
        label: Text(this.title),
        leadingInput: true,
        tristate: value,
      );
    }
    widgets.add(this.widget);
    return widgets;
  }

  @override
  String getResponse(Map formBuilderKeyValue) {
    var value;
    if (formBuilderKeyValue.containsKey(this.name)) {
      value =
          formBuilderKeyValue[this.name].toString() == "true" ? true : false;
    }
    if (value == 'null') {
      return '';
    }
    return '"' + this.name + '": ' + value;
  }

  @override
  Map getResponseSubMap(Map formBuilderKeyValue) {
    var value;
    if (formBuilderKeyValue.containsKey(this.name)) {
      value =
          formBuilderKeyValue[this.name].toString() == "true" ? true : false;
    }
    return {this.name: value};
  }
}
