import 'dart:convert';
import 'package:eps_mobile/custom_fields/widgets/custom_check_box_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_date_time_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_number_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_radio_button_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_rank_list_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_select_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_text_area_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:eps_mobile/helpers/datetime_helper.dart';
import 'package:eps_mobile/models/case_definition.dart';
import 'package:eps_mobile/models/custom_field.dart';

class CustomFieldHelper {
  static String getDisplayValue(
    String fieldType,
    dynamic value,
    dynamic selections,
  ) {
    switch (fieldType) {
      case 'text':
        {
          return value.toString();
        }
        break;

      case 'textarea':
        {
          return value.toString();
        }
        break;

      case 'check_box':
        {
          var values = [];
          var selectionIds = [];
          for (var selection in selections) {
            selectionIds.add(selection['id']);
          }
          for (var item in value) {
            if (selectionIds.contains(item)) {
              values.add(selections[item - 1]['value']);
            }
          }
          var returnValue = '';
          if (values.length > 0) {
            for (int i = 0; i < values.length; i++) {
              returnValue += values[i];
              if (i < values.length - 1) {
                returnValue += '\n';
              }
            }
          }
          return returnValue;
        }
        break;

      case 'radio_button':
        {
          for (var item in selections) {
            if (item['id'] == value) {
              return item['value'];
            }
          }
          return '';
        }
        break;

      case 'select':
        {
          for (var item in selections) {
            if (item['id'] == value) {
              return item['value'];
            }
          }
          return '';
        }
        break;

      case 'number':
        {
          return value.toString();
        }
        break;

      case 'date':
        {
          return DateTimeHelper.getDateTimeAsYYYYMMDDString(
            DateTime.parse(value),
          );
        }
        break;

      case 'rank_list':
        {
          var returnValue = '';
          var values = List<Tuple2<int, int>>();
          for (var item in value) {
            values.add(Tuple2<int, int>(
              item['id'],
              item['rank'],
            ));
          }
          values.sort((a, b) => a.item2.compareTo(b.item2));
          var selectionItems = List<Tuple2<int, String>>();
          for (var item in selections) {
            selectionItems.add(Tuple2<int, String>(
              item['id'],
              item['value'],
            ));
          }
          var i = 0;
          for (var item in values) {
            if (selectionItems.where((a) => a.item1 == item.item1).length > 0) {
              returnValue += selectionItems
                  .where((a) => a.item1 == item.item1)
                  .first
                  .item2;
            }
            if (i < values.length - 1) {
              returnValue += '\n';
            }
            i++;
          }
          return returnValue;
        }
        break;

      default:
        {
          return value.toString();
        }
        break;
    }
  }

  static Map customFieldToJson(
    List<CustomField> customFields,
  ) {
    var rtn = {};
    rtn['data'] = [];
    for (var item in customFields) {
      rtn['data'].add({
        "case_definition_custom_field_id": item.caseDefinitionCustomFieldId,
        "created_at": item.createdAt.toString(),
        "created_by": item.createdBy,
        "custom_section_id": item.customSectionId,
        "field_type": item.fieldType,
        "help_text": item.helpText,
        "id": item.id,
        "model_type": item.modelType,
        "name": item.name,
        "selections": item.selections,
        "sort_order": item.sortOrder,
        "updated_at": item.updatedAt.toString(),
        "updated_by": item.updatedBy,
        "validation_rules": item.validationRules,
        "value": item.value
      });
    }
    return rtn;
  }

  static Map copyCustomFieldsFromCaseDefinition(
    CaseDefinition caseDefinition,
    int currentUserId,
  ) {
    var rtn = {};
    rtn['data'] = [];

    var template = json.decode(caseDefinition.customFieldData);

    for (var item in template['data']) {
      rtn['data'].add({
        'case_definition_custom_field_id': item['id'],
        'created_at': DateTime.now().toUtc().toString(),
        'created_by_id': currentUserId,
        'custom_section_id': null,
        'field_type': item['field_type'],
        'help_text': item['help_text'],
        'id': Uuid().v4(),
        'model_type': item['model_type'],
        'name': item['name'],
        'selections': item['selections'],
        'sort_order': item['sort_order'],
        'updated_at': DateTime.now().toUtc().toString(),
        'updated_by_id': currentUserId,
        'validation_rules': [],
        'value': null
      });
    }

    return rtn;
  }

  static List<Tuple2<CustomField, Widget>> initCustomFields(
    String customFieldData,
    String localizationMustMakeASelection,
    String localizationMustSelectAtLeastOne,
    String localizationClear,
    String localizationThisIsNotANumber,
    String localizationPickdate,
  ) {
    var customFields = List<Tuple2<CustomField, Widget>>();
    dynamic customFieldDatas;
    customFieldDatas = json.decode(customFieldData);
    if (customFieldDatas != null) {
      customFields = List<Tuple2<CustomField, Widget>>();
      for (var customFieldData in customFieldDatas['data']) {
        var type = customFieldData['field_type'];
        Widget widget;
        switch (type) {
          case 'text':
            {
              String value = customFieldData['value'];
              widget = CustomTextWidget(
                initialValue: value == null ? '' : value,
                labelText: customFieldData['name'],
                padding: EdgeInsets.all(10.0),
                enforcesValidationCanNotBeBlank: false,
                enforcesCheckForAllSpaces: false,
              );
            }
            break;

          case 'textarea':
            {
              String value = customFieldData['value'];
              widget = CustomTextAreaWidget(
                initialValue: value == null ? '' : value,
                labelText: customFieldData['name'],
                padding: EdgeInsets.all(10.0),
                enforcesValidationCanNotBeBlank: false,
                enforcesCheckForAllSpaces: false,
              );
            }
            break;

          case 'select':
            {
              // selection values
              List<Tuple2<int, String>> values = List<Tuple2<int, String>>();
              for (var choice in customFieldData['selections']) {
                values.add(Tuple2<int, String>(
                  choice['id'],
                  choice['value'],
                ));
              }

              // initial value
              var valueData = customFieldData['value'];
              var selectedValue = valueData;
              var initialValue;
              if (selectedValue != null) {
                for (var item in values) {
                  if (item.item1 == selectedValue) {
                    initialValue = item;
                  }
                }
              }

              // widget
              widget = CustomSelectWidget(
                initialValue: initialValue,
                labelText: customFieldData['name'],
                padding: EdgeInsets.all(10.0),
                values: values,
                //enforcesValidationMustMakeSelection: false,
                localizationMustMakeASelection: localizationMustMakeASelection,
              );
            }
            break;

          case 'check_box':
            {
              // values
              List<Tuple2<int, String>> values = List<Tuple2<int, String>>();
              for (var choice in customFieldData['selections']) {
                values.add(Tuple2<int, String>(
                  choice['id'],
                  choice['value'],
                ));
              }
              // initial value
              var valueData = customFieldData['value'];
              var initialValues = List<Tuple2<int, String>>();
              if (valueData != null) {
                for (var item in valueData) {
                  int itemValue = item;
                  for (var valueItem in values) {
                    if (valueItem.item1 == itemValue) {
                      initialValues.add(valueItem);
                    }
                  }
                }
              }

              // widget
              widget = CustomCheckBoxWidget(
                initialValues: initialValues,
                labelText: customFieldData['name'],
                padding: EdgeInsets.all(10.0),
                choices: values,
                enforcesValidationAtLeastOneMustBeSelected: false,
                localizationMustSelectAtLeastOne:
                    localizationMustSelectAtLeastOne,
              );
            }
            break;

          case 'radio_button':
            {
              // radio values
              List<Tuple2<int, String>> values = List<Tuple2<int, String>>();
              for (var choice in customFieldData['selections']) {
                values.add(Tuple2<int, String>(
                  choice['id'],
                  choice['value'],
                ));
              }

              // initial value
              var valueData = customFieldData['value'];
              Tuple2<int, String> initialValue;
              for (var item in values) {
                if (item.item1 == valueData) {
                  initialValue = item;
                }
              }

              // widget
              widget = CustomRadioButtonWidget(
                initialValue: initialValue,
                labelText: customFieldData['name'],
                padding: EdgeInsets.all(10.0),
                choices: values,
                enforcesValidationMustMakeSelection: false,
                localizationClearSelection: localizationClear,
                localizationMustMakeASelection: localizationMustMakeASelection,
              );
            }
            break;

          case 'number':
            {
              var valueData;
              if (customFieldData['value'] == null) {
                valueData = 0.0;
              } else {
                valueData = double.parse(customFieldData['value'].toString());
                if (valueData != null) {
                  valueData = valueData + 0.0; // HACK
                }
              }

              double value = valueData;
              widget = CustomNumberWidget(
                initialValue: value == null ? null : value,
                labelText: customFieldData['name'],
                padding: EdgeInsets.all(10.0),
                localizationThisIsNotANumber: localizationThisIsNotANumber,
              );
            }
            break;

          case 'date':
            {
              var valueData = customFieldData['value'];
              DateTime value;
              if (valueData != null) {
                value = DateTime.parse(valueData);
              }
              widget = CustomDateTimeWidget(
                initialValue: value == null ? null : value,
                labelText: customFieldData['name'],
                padding: EdgeInsets.all(10.0),
                localizationClear: localizationClear,
                localizationPickDate: localizationPickdate,
              );
            }
            break;

          case 'rank_list':
            {
              // rank list values
              List<Tuple2<int, String>> values = List<Tuple2<int, String>>();
              for (var choice in customFieldData['selections']) {
                values.add(Tuple2<int, String>(
                  choice['id'],
                  choice['value'],
                ));
              }

              // initial value
              List<Tuple2<int, String>> valuesOrdered =
                  List<Tuple2<int, String>>();
              var valueData = customFieldData['value'];
              var valueDataOrdered = List<Tuple2<int, int>>();
              if (valueData != null) {
                for (var item in valueData) {
                  valueDataOrdered.add(Tuple2<int, int>(
                    item['id'],
                    item['rank'],
                  ));
                }
                valueDataOrdered.sort((a, b) => a.item2.compareTo(b.item2));
                for (var item in valueDataOrdered) {
                  var search = values.where((a) => a.item1 == item.item1);
                  if (search.length > 0) {
                    valuesOrdered.add(search.first);
                  }
                }
              } else {
                // no value, put selections in order of id
                values.sort((a, b) => a.item1.compareTo(b.item1));
                for (var item in values) {
                  valuesOrdered.add(Tuple2<int, String>(
                    item.item1,
                    item.item2,
                  ));
                }
              }

              // widget
              widget = CustomRankListWidget(
                labelText: 'Rank Items',
                padding: EdgeInsets.all(10.0),
                height: 300.0,
                choices: valuesOrdered,
              );
            }
            break;
        }

        // hold in array to get values
        var customField = CustomField();
        if (customFieldData.containsKey('case_definition_custom_field_id')) {
          customField.caseDefinitionCustomFieldId =
              customFieldData['case_definition_custom_field_id'];
        }
        if (customFieldData
            .containsKey('activity_definition_custom_field_id')) {
          customField.activityDefinitionCustomFieldId =
              customFieldData['activity_definition_custom_field_id'];
        }
        customField.createdAt = DateTime.parse(customFieldData['created_at']);
        customField.createdBy = customFieldData['created_by'];
        customField.customSectionId = customFieldData['custom_section_id'];
        customField.fieldType = customFieldData['field_type'];
        customField.helpText = customFieldData['help_text'];
        customField.id = customFieldData['id'];
        customField.modelType = customFieldData['model_type'];
        customField.name = customFieldData['name'];
        customField.selections = customFieldData['selections'];
        customField.sortOrder = customFieldData['sort_order'];
        customField.updatedAt = DateTime.parse(customFieldData['updated_at']);
        customField.updatedBy = customFieldData['updated_by'];
        customField.validationRules = customFieldData['validation_rules'];
        customField.value = customFieldData['value'];

        customFields.add(Tuple2<CustomField, Widget>(
          customField,
          widget,
        ));
      }
    }

    return customFields;
  }
}
