import 'package:eps_mobile/survey_js_render/models/survey_object.dart';

class Page {
  String name;
  String title;
  String description;
  List<SurveyObject> elements;

  Page() {
    this.name = '';
    this.title = '';
    this.description = '';
    this.elements = new List<SurveyObject>();
  }
}
