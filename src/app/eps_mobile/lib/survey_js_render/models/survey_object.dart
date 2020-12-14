import 'package:flutter/material.dart';

abstract class SurveyObject {
  final String surveyJson;
  String name;
  String title;

  SurveyObject([this.surveyJson = '']);

  List<Widget> getWidgets(String surveyResponseValue);
  String getResponse(Map formBuilderKeyValue);
  Map getResponseSubMap(Map formBuilderKeyValue);
}
