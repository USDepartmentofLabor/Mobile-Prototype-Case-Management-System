import 'package:password/password.dart';

class PasswordHelper {
  static String hashPassword(
    String password,
  ) {
    return Password.hash(
      password,
      new PBKDF2(),
    );
  }

  static bool verifyPassword(
    String password,
    String hash,
  ) {
    return Password.verify(
      password,
      hash,
    );
  }
}
