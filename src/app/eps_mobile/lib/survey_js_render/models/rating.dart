import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eps_mobile/survey_js_render/models/survey_object.dart';

class Rating extends SurveyObject {
  num min;
  num max;
  num step;

  Rating() {
    this.min = 1;
    this.max = 5;
    this.step = 1;
  }

  @override
  List<Widget> getWidgets(String surveyResponseValue) {
    var widgets = new List<Widget>();

    // generate list to mimic surveyjs behavior
    var numbers = new List<FormBuilderFieldOption>();
    var current = min;
    numbers.add(FormBuilderFieldOption(value: current));
    while (current <= max) {
      current += step;
      if (current <= max) {
        numbers.add(FormBuilderFieldOption(value: current));
      }
    }

    widgets.add(FormBuilderSegmentedControl(
      decoration: InputDecoration(labelText: title),
      attribute: name,
      options: numbers,
    ));

    return widgets;
  }

  @override
  String getResponse(Map formBuilderKeyValue) {
    var rtn = '"' + name + '": ';
    if (formBuilderKeyValue.containsKey(name)) {
      rtn = rtn + '"' + formBuilderKeyValue[name].toString() + '"';
    }
    return rtn;
  }

  @override
  Map getResponseSubMap(Map formBuilderKeyValue) {
    var value;
    if (formBuilderKeyValue.containsKey(name)) {
      value = formBuilderKeyValue[name];
    }
    return {name: value};
  }
}
