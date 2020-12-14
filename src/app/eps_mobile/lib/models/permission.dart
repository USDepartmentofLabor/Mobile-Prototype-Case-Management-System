class Permission {
  String code;
  String name;
  int value; // use as PK

  Permission() {
    this.code = '';
    this.name = '';
    this.value = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'value': value,
    };
  }

  static Permission fromMap(Map map) {
    var permission = Permission();

    var codeKey = 'code';
    if (map.containsKey(codeKey)) {
      permission.code = map[codeKey];
    }

    var nameKey = 'name';
    if (map.containsKey(nameKey)) {
      permission.name = map[nameKey];
    }

    var valueKey = 'value';
    if (map.containsKey(valueKey)) {
      permission.value = map[valueKey];
    }

    return permission;
  }

  @override
  String toString() {
    return 'Permission{' +
        'code: $code, ' +
        'name: $name, ' +
        'value: $value, ' +
        '}';
  }

  static String getTableName() {
    return 'permissions';
  }

  static String getCreateTableStatement(String tableName) {
    return 'CREATE TABLE IF NOT EXISTS ' +
        tableName +
        '(' +
        'value INTEGER ' +
        'PRIMARY KEY' +
        ', ' +
        'code TEXT' +
        ', ' +
        'name TEXT' +
        ');';
  }
}
