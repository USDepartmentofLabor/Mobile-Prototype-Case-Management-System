import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tuple/tuple.dart';

class SecureStoreHelper {
  static String userNameKey = 'username';
  static String passwordHashKey = 'passwordHash';
  static String passwordKey = 'password';

  static Future<Map<String, String>> readAllSecureValues() async {
    final storage = new FlutterSecureStorage();
    Map<String, String> allValues;
    try {
      allValues = await storage.readAll();
    } on Exception {
      // log error
    }
    return allValues;
  }

  static Future<void> storeUserCredentials(
    int userId,
    String userName,
    String hashedPassword,
    String password,
  ) async {
    await storeMap(
      userId.toString(),
      {
        userNameKey: userName,
        passwordHashKey: hashedPassword,
        passwordKey: password,
      },
    );
  }

  static Future<Tuple4<int, String, String, String>> getUserById(
    int userId,
  ) async {
    // get all values
    var allValues = await readAllSecureValues();

    // search
    if (allValues.containsKey(userId.toString())) {
      var data = allValues[userId.toString()];
      var decoded = json.decode(data);
      return Tuple4<int, String, String, String>(
        userId,
        decoded[userNameKey],
        decoded[passwordHashKey],
        decoded[passwordKey],
      );
    }

    // no user found
    return null;
  }

  static Future<Tuple4<int, String, String, String>> getUserByUserName(
    String userName,
  ) async {
    // get all values
    var allValues = await readAllSecureValues();

    // search
    for (var item in allValues.entries) {
      var decoded = json.decode(item.value.toString());
      if (userName.toUpperCase() ==
          decoded[userNameKey].toString().toUpperCase()) {
        return Tuple4<int, String, String, String>(
          int.parse(item.key),
          decoded[userNameKey],
          decoded[passwordHashKey],
          decoded[passwordKey],
        );
      }
    }

    // no user found
    return null;
  }

  // static Future<void> storeValue(
  //   String key,
  //   String value,
  // ) async {
  //   final storage = new FlutterSecureStorage();
  //   await storage.write(
  //     key: key,
  //     value: value,
  //   );
  // }

  static Future<void> storeMap(
    String key,
    Map value,
  ) async {
    final storage = new FlutterSecureStorage();
    await storage.write(
      key: key,
      value: json.encode(value),
    );
  }
}
