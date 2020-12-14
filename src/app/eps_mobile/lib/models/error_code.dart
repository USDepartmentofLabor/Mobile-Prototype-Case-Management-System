class ErrorCode {
  int code;
  String message;
  String name;

  ErrorCode() {
    this.code = -1;
    this.message = '';
    this.name = '';
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'name': name,
    };
  }

  static ErrorCode fromMap(Map map) {
    var errorCode = new ErrorCode();
    if (map.containsKey('code')) {
      errorCode.code = map['code'];
    }
    if (map.containsKey('message')) {
      errorCode.message = map['message'];
    }
    if (map.containsKey('name')) {
      errorCode.name = map['name'];
    }
    return errorCode;
  }

  @override
  String toString() {
    return 'ErrorCode{code: $code , message: $message, name: $name}';
  }

  static String getTableName() {
    return 'error_codes';
  }

  static String getCreateTableStatement() {
    return 'CREATE TABLE IF NOT EXISTS ' +
        getTableName() +
        '(' +
        'code INTEGER PRIMARY KEY, ' +
        'message TEXT, ' +
        'name TEXT' +
        ');';
  }
}
