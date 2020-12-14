class UserRole {
  bool isDefault;
  int id;
  String name;
  int permissions;

  UserRole() {
    this.isDefault = false;
    this.id = -1;
    this.name = '';
    this.permissions = -1;
  }

  Map<String, dynamic> toMap() {
    return {
      'isDefault': isDefault,
      'id': id,
      'name': name,
      'permissions': permissions,
    };
  }

  static UserRole fromMap(Map map) {
    var userRole = new UserRole();
    if (map.containsKey('default')) {
      userRole.isDefault = map['default'] == 'true' ? true : false;
    }
    if (map.containsKey('id')) {
      userRole.id = map['id'];
    }
    if (map.containsKey('name')) {
      userRole.name = map['name'];
    }
    if (map.containsKey('permissions')) {
      userRole.permissions = map['permissions'];
    }
    return userRole;
  }

  @override
  String toString() {
    return 'UserRole{isDefault: $isDefault, id: $id, name: $name, permissions: $permissions}';
  }

  static String getTableName() {
    return 'user_roles';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(' +
        'isDefault INT,' +
        'id INTEGER PRIMARY KEY, ' +
        'name TEXT, ' +
        'permissions INT' +
        ');';
  }
}
