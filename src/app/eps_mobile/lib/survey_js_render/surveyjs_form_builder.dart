import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eps_mobile/survey_js_render/models/survey.dart';
import 'package:eps_mobile/survey_js_render/surveyjs_parser.dart';

class SurveyjsFormBuilder extends StatefulWidget {
  SurveyjsFormBuilder({Key key, this.surveyjsJson, this.surveyResponseJson})
      : super(key: key);

  final String surveyjsJson;
  final String surveyResponseJson;

  final _SurveyjsFormBuilderState surveyjsFormBuilderState =
      new _SurveyjsFormBuilderState();

  @override
  _SurveyjsFormBuilderState createState() {
    return getState();
  }

  _SurveyjsFormBuilderState getState() {
    return surveyjsFormBuilderState;
  }
}

class _SurveyjsFormBuilderState extends State<SurveyjsFormBuilder> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Survey survey;

  @override
  void initState() {
    super.initState();
    survey = SurveyJsParser.parseJson(widget.surveyjsJson);
  }

  @override
  Widget build(BuildContext context) {
    // fill in
    Map<String, dynamic> initialValue = {};
    if (widget.surveyResponseJson != '') {
      var decoded = json.decode(widget.surveyResponseJson);
      for (var key in decoded.keys) {
        initialValue[key] = decoded[key];
      }
    }

    return ListView(children: <Widget>[
      FormBuilder(
        key: _fbKey,
        initialValue: initialValue,
        //autovalidate: true,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          children: buildListView(context, initialValue),
        ),
      ),
    ]);
  }

  List<Widget> buildListView(
      BuildContext context, Map<String, dynamic> initialValue) {
    var children = new List<Widget>();
    for (var page in survey.pages) {
      for (var element in page.elements) {
        var value = '';
        if (initialValue.containsKey(element.name)) {
          value = initialValue[element.name].toString();
        }
        var elements = element.getWidgets(value);
        for (var elementWidget in elements) {
          children.add(elementWidget);
        }
      }
    }
    return children;
  }

  String getResponse() {
    _fbKey.currentState.save();
    var fbKeyValue = _fbKey.currentState.value;
    return survey.getResponse(fbKeyValue);
  }

  Map getResponseMap() {
    _fbKey.currentState.save();
    var fbKeyValue = _fbKey.currentState.value;
    return survey.getResponseMap(fbKeyValue);
  }
}
