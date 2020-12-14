class ActivityNote {
  int id;
  int activityId;
  String note;
  DateTime createdAt;
  DateTime updatedAt;
  int createdBy;
  int updatedBy;

  ActivityNote() {
    this.id = -1;
    this.activityId = -1;
    this.note = '';
    this.createdAt = null;
    this.updatedAt = null;
    this.createdBy = -1;
    this.updatedBy = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityId': activityId,
      'note': note,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'createdBy': createdBy.toString(),
      'updatedBy': updatedBy.toString(),
    };
  }

  static ActivityNote fromMap(Map map) {
    var object = new ActivityNote();
    if (map.containsKey('id')) {
      object.id = map['id'];
    }
    if (map.containsKey('activityId')) {
      object.activityId = map['activityId'];
    }
    if (map.containsKey('note')) {
      object.note = map['note'];
    }
    if (map.containsKey('createdAt')) {
      object.createdAt = DateTime.parse(map['createdAt']);
    }
    if (map.containsKey('updatedAt')) {
      object.updatedAt = DateTime.parse(map['updatedAt']);
    }
    if (map.containsKey('createdBy')) {
      object.createdBy = map['createdBy'];
    }
    if (map.containsKey('updatedBy')) {
      object.updatedBy = map['updatedBy'];
    }
    return object;
  }

  @override
  String toString() {
    return 'Survey{id: $id, activityId: $activityId, note: $note, createdAt: $createdAt, createdAt: $createdAt}';
  }

  static String getTableName() {
    return 'activity_notes';
  }

  static String getLocalTableName() {
    return 'local_activity_notes';
  }

  // new objects in 2 different tables
  static String getTableNameLocalRelLocalCases() {
    return 'local_activity_notes_rel_local_cases';
  }

  static String getTableNameLocalRelServerCases() {
    return 'local_activity_notes_rel_server_cases';
  }

  static String getCreateTableStatement(
    String tableName,
    String activityTableName,
  ) {
    return 'CREATE TABLE IF NOT EXISTS ' +
        tableName +
        '(id INTEGER PRIMARY KEY, ' +
        'note TEXT, ' +
        'activityId INTEGER, ' +
        'createdAt TEXT, ' + // SQLite "Datetime"
        'updatedAt TEXT, ' + // SQLite "Datetime"
        'createdBy INT, ' +
        'updatedBy INT, ' +
        'FOREIGN KEY(activityId) REFERENCES ' +
        activityTableName +
        '(id));';
  }
}
