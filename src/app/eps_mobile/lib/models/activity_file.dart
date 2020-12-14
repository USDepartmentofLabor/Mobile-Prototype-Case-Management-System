import 'package:eps_mobile/models/user.dart';

class ActivityFile {
  int id;
  int activityId;
  int documentId;
  String originalFileName;
  String remoteFileName;
  DateTime createdAt;
  int createdBy;

  ActivityFile() {
    this.id = -1;
    this.activityId = -1;
    this.documentId = -1;
    this.originalFileName = '';
    this.remoteFileName = '';
    this.createdAt = null;
    this.createdBy = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'documentId': documentId,
      'originalFileName': originalFileName,
      'remoteFileName': remoteFileName,
      'createdAt': createdAt.toString(),
      'createdBy': createdBy,
    };
  }

  static ActivityFile fromMap(Map map) {
    var file = ActivityFile();

    var idKey = 'id';
    if (map.containsKey(idKey)) {
      file.id = map[idKey];
    }

    var caseIdKey = 'activityId';
    if (map.containsKey(caseIdKey)) {
      file.activityId = map[caseIdKey];
    }

    var documentIdKey = 'documentId';
    if (map.containsKey(documentIdKey)) {
      file.documentId = map[documentIdKey];
    }

    var originalFileNameKey = 'originalFileName';
    if (map.containsKey(originalFileNameKey)) {
      file.originalFileName = map[originalFileNameKey];
    }

    var remoteFileNameKey = 'remoteFileName';
    if (map.containsKey(remoteFileNameKey)) {
      file.remoteFileName = map[remoteFileNameKey];
    }

    return file;
  }

  @override
  String toString() {
    return 'ActivityFile{' +
        'id: $id, ' +
        'activityId: $activityId, ' +
        'documentId: $documentId, ' +
        'originalFileName: $originalFileName, ' +
        'remoteFileName: $remoteFileName, ' +
        'remoteFileName: $createdAt, ' +
        'createdBy: $createdBy' +
        '}';
  }

  static String getTableName() {
    return 'activity_files';
  }

  static String getAltTableName() {
    return 'local_activity_files';
  }

  static String getCreateTableStatement(
    String tableName,
    String activityTableName,
    String definitionDocumentTableName,
  ) {
    return 'CREATE TABLE IF NOT EXISTS ' +
        tableName +
        '(' +
        'id INTEGER PRIMARY KEY' +
        ', ' +
        'activityId INTEGER' +
        ', ' +
        'documentId INTEGER' +
        ', ' +
        'originalFileName TEXT' +
        ', ' +
        'remoteFileName'
            ', ' +
        'createdAt TEXT' + // SQLite "Datetime"
        ', ' +
        'createdBy INT' +
        ', ' +
        'FOREIGN KEY(activityId) REFERENCES ' +
        activityTableName +
        '(id)' +
        ', ' +
        'FOREIGN KEY(documentId) REFERENCES ' +
        definitionDocumentTableName +
        '(id)' +
        ', ' +
        'FOREIGN KEY(createdBy) REFERENCES ' +
        User.getTableName() +
        '(id)' +
        ');';
  }
}
