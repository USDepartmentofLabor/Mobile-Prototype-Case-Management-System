import 'dart:convert';
import 'package:eps_mobile/models/activity.dart';
import 'package:eps_mobile/models/activity_file.dart';
import 'package:eps_mobile/models/activity_note.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;

class ActivityGetAll {
  String getClassName() {
    return this.runtimeType.toString();
  }

  static Future<
          Tuple3<bool, List<String>,
              List<Tuple3<Activity, List<ActivityNote>, List<ActivityFile>>>>>
      getAll(
    String jwtToken,
    String serviceUrl,
    bool useHttps,
  ) async {
    var errors = List<String>();

    Uri logInUri;

    String url = '/activities';

    if (useHttps) {
      logInUri = Uri.https(serviceUrl, url);
    } else {
      logInUri = Uri.http(serviceUrl, url);
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer " + jwtToken
    };

    final response = await http.get(logInUri, headers: headers);

    var data = List<Tuple3<Activity, List<ActivityNote>, List<ActivityFile>>>();

    if (response.statusCode == 200) {
      for (var objectData in json.decode(response.body)) {
        var object = Activity();
        var activityNotes = List<ActivityNote>();
        var activityFiles = List<ActivityFile>();

        // id
        var idKey = 'id';
        if (objectData.containsKey(idKey)) {
          object.id = objectData[idKey];
        }

        // name
        var nameKey = 'name';
        if (objectData.containsKey(nameKey)) {
          object.name = objectData[nameKey];
        }

        // description
        var descriptionKey = 'description';
        if (objectData.containsKey(descriptionKey)) {
          object.description = objectData[descriptionKey];
        }

        // custom field data
        var customFieldsKey = 'custom_fields';
        if (objectData.containsKey(customFieldsKey)) {
          var data = objectData[customFieldsKey];
          Map<String, List> customFieldMap = {'data': []};
          var list = [];
          for (var customField in data) {
            list.add(customField);
          }
          customFieldMap['data'] = list;
          object.customFieldData = jsonEncode(customFieldMap);
        }

        // activity definition id
        var activityDefinitionKey = 'activity_definition';
        if (objectData.containsKey(activityDefinitionKey)) {
          var activityDefinitionIdKey = 'id';
          if (objectData[activityDefinitionKey]
              .containsKey(activityDefinitionIdKey)) {
            object.activityDefinitionId =
                objectData[activityDefinitionKey][activityDefinitionIdKey];
          }
        }

        // case id
        var caseKey = 'case';
        if (objectData.containsKey(caseKey)) {
          var caseIdKey = 'id';
          if (objectData[caseKey].containsKey(caseIdKey)) {
            object.caseId = objectData[caseKey][caseIdKey];
          }
        }

        // createdAt
        var createdAtKey = 'created_at';
        if (objectData.containsKey(createdAtKey)) {
          object.createdAt = DateTime.parse(objectData[createdAtKey]);
        }

        // createdBy
        var createdByKey = 'created_by';
        if (objectData.containsKey(createdByKey)) {
          var createdByIdKey = 'id';
          if (objectData[createdByKey].containsKey(createdByIdKey)) {
            object.createdBy = objectData[createdByKey][createdByIdKey];
          }
        }

        // created location
        var createdLocationKey = 'created_location2';
        if (objectData.containsKey(createdLocationKey)) {
          var createdLatitudeKey = 'latitude';
          if (objectData[createdLocationKey].containsKey(createdLatitudeKey)) {
            if (objectData[createdByKey][createdLatitudeKey] != null) {
              object.createdLatitude =
                  double.parse(objectData[createdByKey][createdLatitudeKey]);
            }
          }

          var createdLongitudeKey = 'longitude';
          if (objectData[createdLocationKey].containsKey(createdLongitudeKey)) {
            object.createdlongitude =
                double.parse(objectData[createdByKey][createdLongitudeKey]);
          }

          var createdAltitudeKey = 'altitude';
          if (objectData[createdLocationKey].containsKey(createdAltitudeKey)) {
            object.createdAltitude =
                double.parse(objectData[createdByKey][createdAltitudeKey]);
          }

          var createdAltitudeAccuracyKey = 'altitude_accuracy';
          if (objectData[createdLocationKey]
              .containsKey(createdAltitudeAccuracyKey)) {
            object.createdAltitudeAccuracy = double.parse(
                objectData[createdByKey][createdAltitudeAccuracyKey]);
          }

          var createdPositionAccuracyKey = 'position_accuracy';
          if (objectData[createdLocationKey]
              .containsKey(createdPositionAccuracyKey)) {
            object.createdPositionAccuracy = double.parse(
                objectData[createdByKey][createdPositionAccuracyKey]);
          }

          var createdHeadingKey = 'heading';
          if (objectData[createdLocationKey].containsKey(createdHeadingKey)) {
            object.createdHeading =
                double.parse(objectData[createdByKey][createdHeadingKey]);
          }

          var createdSpeedKey = 'speed';
          if (objectData[createdLocationKey].containsKey(createdSpeedKey)) {
            object.createdSpeed =
                double.parse(objectData[createdByKey][createdSpeedKey]);
          }

          var createdLocationRecordedDtKey = 'location_recorded_dt';
          if (objectData[createdLocationKey]
              .containsKey(createdLocationRecordedDtKey)) {
            object.createdRecordedDateTime = DateTime.parse(
                objectData[createdByKey][createdLocationRecordedDtKey]);
          }
        }

        // updatedAt
        var updatedAtKey = 'updated_at';
        if (objectData.containsKey(updatedAtKey)) {
          object.updatedAt = DateTime.parse(objectData[updatedAtKey]);
        }

        // updatedBy
        var updatedByKey = 'updated_by';
        if (objectData.containsKey(updatedByKey)) {
          var updatedByIdKey = 'id';
          if (objectData[updatedByKey].containsKey(updatedByIdKey)) {
            object.updatedBy = objectData[updatedByKey][updatedByIdKey];
          }
        }

        // updated location
        var updatedLocationKey = 'updated_location2';
        if (objectData.containsKey(updatedLocationKey)) {
          var updatedLatitudeKey = 'latitude';
          if (objectData[updatedLocationKey].containsKey(updatedLatitudeKey)) {
            object.updatedLatitude =
                double.parse(objectData[updatedByKey][updatedLatitudeKey]);
          }

          var updatedLongitudeKey = 'longitude';
          if (objectData[updatedLocationKey].containsKey(updatedLongitudeKey)) {
            object.updatedlongitude =
                double.parse(objectData[updatedByKey][updatedLongitudeKey]);
          }

          var updatedAltitudeKey = 'altitude';
          if (objectData[updatedLocationKey].containsKey(updatedAltitudeKey)) {
            object.updatedAltitude =
                double.parse(objectData[updatedByKey][updatedAltitudeKey]);
          }

          var updatedAltitudeAccuracyKey = 'altitude_accuracy';
          if (objectData[createdLocationKey]
              .containsKey(updatedAltitudeAccuracyKey)) {
            object.updatedAltitudeAccuracy = double.parse(
                objectData[updatedByKey][updatedAltitudeAccuracyKey]);
          }

          var updatedPositionAccuracyKey = 'position_accuracy';
          if (objectData[updatedLocationKey]
              .containsKey(updatedPositionAccuracyKey)) {
            object.updatedPositionAccuracy = double.parse(
                objectData[updatedByKey][updatedPositionAccuracyKey]);
          }

          var updatedHeadingKey = 'heading';
          if (objectData[updatedLocationKey].containsKey(updatedHeadingKey)) {
            object.updatedHeading =
                double.parse(objectData[updatedByKey][updatedHeadingKey]);
          }

          var updatedSpeedKey = 'speed';
          if (objectData[updatedLocationKey].containsKey(updatedSpeedKey)) {
            object.updatedSpeed =
                double.parse(objectData[updatedByKey][updatedSpeedKey]);
          }

          var updatedLocationRecordedDtKey = 'location_recorded_dt';
          if (objectData[updatedLocationKey]
              .containsKey(updatedLocationRecordedDtKey)) {
            object.updatedRecordedDateTime = DateTime.parse(
                objectData[updatedByKey][updatedLocationRecordedDtKey]);
          }
        }

        // notes
        if (objectData.containsKey('notes')) {
          var actNotesData = objectData['notes'];
          for (var actNoteData in actNotesData) {
            var actNote = new ActivityNote();
            actNote.activityId = object.id;
            if (actNoteData.containsKey('id')) {
              actNote.id = actNoteData['id'];
            }
            if (actNoteData.containsKey('note')) {
              actNote.note = actNoteData['note'];
            }
            if (actNoteData.containsKey('created_at')) {
              actNote.createdAt = DateTime.parse(actNoteData['created_at']);
            }
            if (actNoteData.containsKey('updated_at')) {
              actNote.updatedAt = DateTime.parse(actNoteData['updated_at']);
            }
            if (actNoteData.containsKey('created_by')) {
              var createdByData = actNoteData['created_by'];
              if (createdByData.containsKey('id')) {
                actNote.createdBy = createdByData['id'];
              }
            }
            if (actNoteData.containsKey('updated_by')) {
              var updatedByData = actNoteData['updated_by'];
              if (updatedByData.containsKey('id')) {
                actNote.updatedBy = updatedByData['id'];
              }
            }
            activityNotes.add(actNote);
          }
        }

        // files
        if (objectData.containsKey('documents')) {
          var filesData = objectData['documents'];
          for (var fileData in filesData) {
            var file = ActivityFile();

            if (fileData.containsKey('id')) {
              file.id = fileData['id'];
            }

            file.activityId = object.id;

            if (fileData.containsKey('document_id')) {
              file.documentId = fileData['document_id'];
            }

            if (fileData.containsKey('original_filename')) {
              file.originalFileName = fileData['original_filename'];
            }

            if (fileData.containsKey('remote_filename')) {
              file.remoteFileName = fileData['remote_filename'];
            }

            // created_at -> id

            // created_by -> id

            activityFiles.add(file);
          }
        }

        data.add(Tuple3<Activity, List<ActivityNote>, List<ActivityFile>>(
          object,
          activityNotes,
          activityFiles,
        ));
      }

      return Tuple3<bool, List<String>,
          List<Tuple3<Activity, List<ActivityNote>, List<ActivityFile>>>>(
        true,
        errors,
        data,
      );
    } else {
      // get the error code and string
      print(response.bodyBytes.toString());
      errors.add(
        response.statusCode.toString(),
      );
      errors.add(
        response.body,
      );
    }

    return Tuple3<bool, List<String>,
        List<Tuple3<Activity, List<ActivityNote>, List<ActivityFile>>>>(
      false,
      errors,
      null,
    );
  }
}
