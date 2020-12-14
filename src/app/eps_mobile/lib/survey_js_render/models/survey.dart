import 'package:eps_mobile/survey_js_render/models/page.dart';

class Survey {
  String title;
  String description;
  List<Page> pages;

  Survey() {
    this.title = '';
    this.description = '';
    this.pages = new List<Page>();
  }

  String getResponse(Map formBuilderKeyValue) {
    var subresponses = new List<String>();
    for (var page in pages) {
      for (var element in page.elements) {
        subresponses.add(element.getResponse(formBuilderKeyValue));
      }
    }

    var response = '{';
    for (var i = 0; i < subresponses.length; i++) {
      response = response + subresponses[i];
      if (i != (subresponses.length - 1)) {
        response = response + ',';
      }
    }
    response = response + '}';
    return response;
  }

  Map getResponseMap(Map formBuilderKeyValue) {
    var rtn = {};
    for (var page in pages) {
      for (var element in page.elements) {
        rtn.addAll(element.getResponseSubMap(formBuilderKeyValue));
      }
    }
    return rtn;
  }
}
