import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eps_mobile/survey_js_render/models/survey_object.dart';

class Comment extends SurveyObject {
  String name;

  FormBuilderTextField widget;
  TextEditingController textEditingController;

  Comment() {
    this.name = '';
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
        maxLines: 5,
      );
    }
    list.add(widget);
    return list;
  }

  @override
  String getResponse(Map formBuilderKeyValue) {
    return '"' +
        name +
        '": "' +
        widget.controller.text.replaceAll('\n', '\\n') +
        '"';
  }

  @override
  Map getResponseSubMap(Map formBuilderKeyValue) {
    return {name: widget.controller.text.replaceAll('\n', '\\n')};
  }
}
