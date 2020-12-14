import 'dart:convert';
import 'package:eps_mobile/survey_js_render/models/boolean_control.dart';
import 'package:eps_mobile/survey_js_render/models/comment.dart';
import 'package:eps_mobile/survey_js_render/models/display_text_value.dart';
import 'package:eps_mobile/survey_js_render/models/dropdown.dart';
import 'package:eps_mobile/survey_js_render/models/radiogroup.dart';
import 'package:eps_mobile/survey_js_render/models/rating.dart';
import 'package:eps_mobile/survey_js_render/models/survey.dart';
import 'package:eps_mobile/survey_js_render/models/page.dart';
import 'package:eps_mobile/survey_js_render/models/survey_object.dart';
import 'package:eps_mobile/survey_js_render/models/single_input.dart';
import 'package:eps_mobile/survey_js_render/models/checkbox.dart';

class SurveyJsParser {
  String surveyJsJson;

  SurveyJsParser() {
    this.surveyJsJson = '';
  }

  static Survey parseJson(String surveyJson) {
    var survey = new Survey();

    // empty json means nothing
    if (surveyJson.isEmpty) return null;
    var decoded = json.decode(surveyJson);

    // survey
    if (decoded.containsKey('title')) {
      survey.title = decoded['title'];
    }

    if (decoded.containsKey('description')) {
      survey.description = decoded['description'];
    }

    // pages
    if (decoded.containsKey('pages')) {
      var pageArray = decoded['pages'];
      for (var page in pageArray) {
        var parsedPage = parsePage(page);
        if (page != null) {
          survey.pages.add(parsedPage);
        }
      }
    }

    return survey;
  }

  static Page parsePage(Map pageJson) {
    var page = new Page();

    if (pageJson.containsKey('name')) {
      page.name = pageJson['name'];
    }

    if (pageJson.containsKey('title')) {
      page.title = pageJson['title'];
    }

    if (pageJson.containsKey('description')) {
      page.description = pageJson['description'];
    }

    // elements
    if (pageJson.containsKey('elements')) {
      var elements = pageJson['elements'];
      for (var element in elements) {
        if (element.containsKey('type')) {
          var elementType = element['type'];

          if (elementType == 'text') {
            var text = parseSingleInput(element);
            if (text != null) {
              page.elements.add(text);
            }
          }

          if (elementType == 'checkbox') {
            var checkbox = parseCheckbox(element);
            if (checkbox != null) {
              page.elements.add(checkbox);
            }
          }

          if (elementType == 'radiogroup') {
            var checkbox = parseRadioGroup(element);
            if (checkbox != null) {
              page.elements.add(checkbox);
            }
          }

          if (elementType == 'dropdown') {
            var checkbox = parseDropdown(element);
            if (checkbox != null) {
              page.elements.add(checkbox);
            }
          }

          if (elementType == 'comment') {
            var comment = parseComment(element);
            if (comment != null) {
              page.elements.add(comment);
            }
          }

          if (elementType == 'rating') {
            var rating = parseRating(element);
            if (rating != null) {
              page.elements.add(rating);
            }
          }

          if (elementType == 'boolean') {
            var boolean = parseBoolean(element);
            if (boolean != null) {
              page.elements.add(boolean);
            }
          }

          // ...
        }
      }
    }

    return page;
  }

  static SurveyObject parseSingleInput(Map json) {
    var text = new SingleInput();

    if (json.containsKey('name')) {
      text.name = json['name'];
    }

    if (json.containsKey('title')) {
      text.name = json['title'];
    }

    // inputType

    if (json.containsKey('inputPlaceHolder')) {
      text.name = json['inputPlaceHolder'];
    }

    return text;
  }

  static SurveyObject parseCheckbox(Map json) {
    var checkbox = new Checkbox();

    if (json.containsKey('name')) {
      checkbox.name = json['name'];
    }

    if (json.containsKey('title')) {
      checkbox..title = json['title'];
    }

    if (json.containsKey('choices')) {
      for (var choice in json['choices']) {
        var choiceObj = new DisplayTextValue(choice['text'], choice['value']);
        checkbox.choices.add(choiceObj);
      }
    }

    return checkbox;
  }

  static SurveyObject parseRadioGroup(Map json) {
    var radiogroup = new Radiogroup();

    if (json.containsKey('name')) {
      radiogroup.name = json['name'];
    }

    if (json.containsKey('title')) {
      radiogroup..title = json['title'];
    }

    if (json.containsKey('choices')) {
      var choices = json['choices'] as List;

      for (var choice in choices) {
        var text = '';
        var value = '';

        if (choice is Map) {
          text = choice['text'];
          value = choice['value'];
        } else {
          text = choice.toString();
          value = choice.toString();
        }

        var choiceObj = new DisplayTextValue(text, value);
        radiogroup.choices.add(choiceObj);
      }
    }

    return radiogroup;
  }

  static SurveyObject parseDropdown(Map json) {
    var dropdown = new Dropdown();

    if (json.containsKey('name')) {
      dropdown.name = json['name'];
    }

    if (json.containsKey('title')) {
      dropdown..title = json['title'];
    }

    if (json.containsKey('choices')) {
      for (var choice in json['choices']) {
        var choiceObj = new DisplayTextValue(choice['text'], choice['value']);
        dropdown.choices.add(choiceObj);
      }
    }

    return dropdown;
  }

  static SurveyObject parseComment(Map json) {
    var comment = new Comment();

    if (json.containsKey('name')) {
      comment.name = json['name'];
    }

    if (json.containsKey('title')) {
      comment.title = json['title'];
    }

    return comment;
  }

  static SurveyObject parseRating(Map json) {
    var rating = new Rating();

    if (json.containsKey('name')) {
      rating.name = json['name'];
    }

    if (json.containsKey('title')) {
      rating..title = json['title'];
    }

    if (json.containsKey('rateMin')) {
      rating.min = json['rateMin'];
    }

    if (json.containsKey('rateMax')) {
      rating.max = json['rateMax'];
    }

    if (json.containsKey('rateStep')) {
      rating.step = json['rateStep'];
    }

    return rating;
  }

  static SurveyObject parseBoolean(Map json) {
    var boolean = BooleanControl();

    if (json.containsKey('name')) {
      boolean.name = json['name'];
    }

    if (json.containsKey('title')) {
      boolean.title = json['title'];
    }

    return boolean;
  }
}
