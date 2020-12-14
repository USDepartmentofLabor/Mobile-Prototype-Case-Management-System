import 'package:sqflite/sqlite_api.dart';
import 'package:eps_mobile/models/permission.dart';
import 'package:eps_mobile/models/user.dart';
import 'package:eps_mobile/models/user_role.dart';
import 'package:eps_mobile/queries/user_role_queries.dart';

class PermissionsHelper {
  static bool roleHasPermission(
    UserRole userRole,
    Permission permission,
  ) {
    /*
    The list of permissions can be seen by looking at the /lookups endpoint.
    Each permission has a integer value property (they are increasing powers of two).
    Roles have a permissions property which is a value representing all the permission values the role has.
    To determine if a user has permission you bitwise AND the role’s permission value with the permission’s value
    and if you get the permission’s value the role (and therefore the user) has the permission.
    */
    return (userRole.permissions & permission.value) == permission.value;
  }

  static Future<bool> userHasPermission(
    Database database,
    User user,
    Permission permission,
  ) async {
    var userRole = await UserRoleQueries.getUserRoleById(
      database,
      user.userRoleId,
    );

    // if no role found, default to no
    if (userRole == null) {
      return false;
    }

    return roleHasPermission(
      userRole,
      permission,
    );
  }
}
