import 'dart:core';
import 'package:eps_mobile/models/activity.dart';
import 'package:eps_mobile/models/activity_definition.dart';
import 'package:eps_mobile/models/activity_definition_document.dart';
import 'package:eps_mobile/models/activity_definition_survey.dart';
import 'package:eps_mobile/models/activity_file.dart';
import 'package:eps_mobile/models/activity_note.dart';
import 'package:eps_mobile/models/permission.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/case_definition.dart';
import 'package:eps_mobile/models/case_definition_document.dart';
import 'package:eps_mobile/models/case_definition_survey.dart';
import 'package:eps_mobile/models/case_file.dart';
import 'package:eps_mobile/models/case_note.dart';
import 'package:eps_mobile/models/case_status.dart';
import 'package:eps_mobile/models/error_code.dart';
import 'package:eps_mobile/models/project.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/survey_response.dart';
import 'package:eps_mobile/models/survey_response_status.dart';
import 'package:eps_mobile/models/user.dart';
import 'package:eps_mobile/models/user_role.dart';

class MepsDatabase {
  Database database;

  MepsDatabase() {
    openDatabase();
  }

  void openDatabase() async {
    database = await sqflite.openDatabase(
      join(
        await getDatabasesPath(),
        'meps.db',
      ),
      onCreate: (db, version) {
        return db.execute(
          User.getCreateTableStatement(),
        );
      },
      version: 1,
    );

    // lookups
    this.database.execute(
          CaseStatus.getCreateTableStatement(),
        );
    this.database.execute(
          ErrorCode.getCreateTableStatement(),
        );
    this.database.execute(
          UserRole.getCreateTableStatement(),
        );
    this.database.execute(
          SurveyResponseStatus.getCreateTableStatement(),
        );
    this.database.execute(
          Permission.getCreateTableStatement(
            Permission.getTableName(),
          ),
        );

    // data
    this.database.execute(
          Project.getCreateTableStatement(
            Project.getTableName(),
          ),
        );
    this.database.execute(
          Survey.getCreateTableStatement(),
        );
    this.database.execute(
          SurveyResponse.getCreateTableStatement(SurveyResponse.getTableName()),
        );
    this.database.execute(
          SurveyResponse.getCreateTableStatement(
              SurveyResponse.getAltTableName()),
        );
    this.database.execute(
          CaseDefinition.getCreateTableStatement(),
        );
    this.database.execute(CaseDefinitionDocument.getCreateTableStatement());
    this.database.execute(
          CaseDefinitionSurvey.getCreateTableStatement(),
        );
    this.database.execute(
          CaseInstance.getCreateTableStatement(CaseInstance.getTableName()),
        );
    this.database.execute(
          CaseInstance.getCreateTableStatement(CaseInstance.getAltTableName()),
        );
    this.database.execute(
          CaseNote.getCreateTableStatement(CaseNote.getTableName()),
        );
    this.database.execute(
          CaseNote.getCreateTableStatement(CaseNote.getAltTableName()),
        );
    this
        .database
        .execute(CaseFile.getCreateTableStatement(CaseFile.getTableName()));
    this
        .database
        .execute(CaseFile.getCreateTableStatement(CaseFile.getAltTableName()));

    // ========================
    // = activity definitions =
    // ========================
    // - Activity Definition
    // - Activity Definition Documents
    // - Activity Definition Surveys
    this.database.execute(
          ActivityDefinition.getCreateTableStatement(),
        );
    this.database.execute(
          ActivityDefinitionDocument.getCreateTableStatement(),
        );
    this.database.execute(
          ActivityDefinitionSurvey.getCreateTableStatement(),
        );

    // ==============
    // = activities =
    // ==============

    // activity server
    this.database.execute(
          Activity.getCreateTableStatement(
            Activity.getTableName(),
            CaseInstance.getTableName(),
          ),
        );

    // activity local
    this.database.execute(
          Activity.getCreateTableStatement(
            Activity.getLocalTableName(),
            CaseInstance.getAltTableName(),
          ),
        );

    // activity note server
    this.database.execute(
          ActivityNote.getCreateTableStatement(
            ActivityNote.getTableName(),
            Activity.getTableName(),
          ),
        );

    // activity note local
    this.database.execute(
          ActivityNote.getCreateTableStatement(
            ActivityNote.getLocalTableName(),
            Activity.getLocalTableName(),
          ),
        );

    // activity doc server
    this.database.execute(ActivityFile.getCreateTableStatement(
          ActivityFile.getTableName(),
          Activity.getTableName(),
          ActivityDefinitionDocument.getTableName(),
        ));

    // activity doc local
    this.database.execute(ActivityFile.getCreateTableStatement(
          ActivityFile.getAltTableName(),
          Activity.getLocalTableName(),
          ActivityDefinitionDocument.getTableName(),
        ));
  }
}
