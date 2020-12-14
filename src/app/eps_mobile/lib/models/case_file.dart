import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/case_definition_document.dart';
import 'package:eps_mobile/models/user.dart';

class CaseFile {
  int id;
  int caseId;
  int documentId;
  String originalFileName;
  String remoteFileName;
  DateTime createdAt;
  int createdBy;

  CaseFile() {
    this.id = -1;
    this.caseId = -1;
    this.documentId = -1;
    this.originalFileName = '';
    this.remoteFileName = '';
    this.createdAt = null;
    this.createdBy = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caseId': caseId,
      'documentId': documentId,
      'originalFileName': originalFileName,
      'remoteFileName': remoteFileName,
      'createdAt': createdAt.toString(),
      'createdBy': createdBy,
    };
  }

  static CaseFile fromMap(Map map) {
    var caseFile = CaseFile();

    var idKey = 'id';
    if (map.containsKey(idKey)) {
      caseFile.id = map[idKey];
    }

    var caseIdKey = 'caseId';
    if (map.containsKey(caseIdKey)) {
      caseFile.caseId = map[caseIdKey];
    }

    var documentIdKey = 'documentId';
    if (map.containsKey(documentIdKey)) {
      caseFile.documentId = map[documentIdKey];
    }

    var originalFileNameKey = 'originalFileName';
    if (map.containsKey(originalFileNameKey)) {
      caseFile.originalFileName = map[originalFileNameKey];
    }

    var remoteFileNameKey = 'remoteFileName';
    if (map.containsKey(remoteFileNameKey)) {
      caseFile.remoteFileName = map[remoteFileNameKey];
    }

    return caseFile;
  }

  @override
  String toString() {
    return 'CaseFile{' +
        'id: $id, ' +
        'caseId: $caseId, ' +
        'documentId: $documentId, ' +
        'originalFileName: $originalFileName, ' +
        'remoteFileName: $remoteFileName, ' +
        'remoteFileName: $createdAt, ' +
        'createdBy: $createdBy' +
        '}';
  }

  static String getTableName() {
    return 'case_files';
  }

  static String getAltTableName() {
    return 'local_case_files';
  }

  static String getCreateTableStatement(String tableName) {
    return 'CREATE TABLE IF NOT EXISTS ' +
        tableName +
        '(' +
        'id INTEGER PRIMARY KEY' +
        ', ' +
        'caseId INTEGER' +
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
        'FOREIGN KEY(caseId) REFERENCES ' +
        CaseInstance.getTableName() +
        '(id)' +
        ', ' +
        'FOREIGN KEY(documentId) REFERENCES ' +
        CaseDefinitionDocument.getTableName() +
        '(id)' +
        ', ' +
        'FOREIGN KEY(createdBy) REFERENCES ' +
        User.getTableName() +
        '(id)' +
        ');';
  }
}
