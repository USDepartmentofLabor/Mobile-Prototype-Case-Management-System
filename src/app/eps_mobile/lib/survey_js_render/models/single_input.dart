import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eps_mobile/survey_js_render/models/survey_object.dart';

class SingleInput extends SurveyObject {
  String name;
  String title;
  // inputType
  String inputPlaceholder;

  FormBuilderTextField widget;
  TextEditingController textEditingController;

  SingleInput() {
    this.name = '';
    this.title = '';
    // inputType
    this.inputPlaceholder = '';
  }

  @override
  List<Widget> getWidgets(String surveyResponseValue) {
    var list = new List<Widget>();
    if (widget == null) {
      textEditingController = new TextEditingController();
      if (surveyResponseValue != '') {
        textEditingController.text = surveyResponseValue;
      }
      widget = FormBuilderTextField(
        attribute: name,
        decoration: InputDecoration(labelText: title),
        controller: textEditingController,
      );
    }
    list.add(widget);
    return list;
  }

  @override
  String getResponse(Map formBuilderKeyValue) {
    return '"' + name + '": "' + widget.controller.text + '"';
  }

  @override
  Map getResponseSubMap(Map formBuilderKeyValue) {
    return {name: widget.controller.text};
  }
}
