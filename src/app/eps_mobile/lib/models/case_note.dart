import 'package:eps_mobile/models/case_instance.dart';

class CaseNote {
  int id;
  int caseId;
  String note;
  DateTime createdAt;
  DateTime updatedAt;
  int createdBy;
  int updatedBy;

  CaseNote() {
    this.id = -1;
    this.caseId = -1;
    this.note = '';
    this.createdAt = null;
    this.updatedAt = null;
    this.createdBy = -1;
    this.updatedBy = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caseId': caseId,
      'note': note,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'createdBy': createdBy.toString(),
      'updatedBy': updatedBy.toString(),
    };
  }

  static CaseNote fromMap(Map map) {
    var caseNote = new CaseNote();
    if (map.containsKey('id')) {
      caseNote.id = map['id'];
    }
    if (map.containsKey('caseId')) {
      caseNote.caseId = map['caseId'];
    }
    if (map.containsKey('note')) {
      caseNote.note = map['note'];
    }
    if (map.containsKey('createdAt')) {
      caseNote.createdAt = DateTime.parse(map['createdAt']);
    }
    if (map.containsKey('updatedAt')) {
      caseNote.updatedAt = DateTime.parse(map['updatedAt']);
    }
    if (map.containsKey('createdBy')) {
      caseNote.createdBy = map['createdBy'];
    }
    if (map.containsKey('updatedBy')) {
      caseNote.updatedBy = map['updatedBy'];
    }
    return caseNote;
  }

  @override
  String toString() {
    return 'Survey{id: $id, caseDefinitionId: $caseId, note: $note, createdAt: $createdAt, createdAt: $createdAt}';
  }

  static String getTableName() {
    return 'case_notes';
  }

  // new casenotes in a different table
  static String getAltTableName() {
    return 'local_case_notes';
  }

  static String getCreateTableStatement(String tableName) {
    return 'CREATE TABLE IF NOT EXISTS ' +
        tableName +
        '(id INTEGER PRIMARY KEY, ' +
        'note TEXT, ' +
        'caseId INTEGER, ' +
        'createdAt TEXT, ' + // SQLite "Datetime"
        'updatedAt TEXT, ' + // SQLite "Datetime"
        'createdBy INT, ' +
        'updatedBy INT, ' +
        'FOREIGN KEY(caseId) REFERENCES ' +
        CaseInstance.getTableName() +
        '(id));';
  }
}
