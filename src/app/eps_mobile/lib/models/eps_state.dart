import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:eps_mobile/custom_fields/helpers/secure_store_helper.dart';
import 'package:eps_mobile/helpers/enum_helper.dart';
import 'package:eps_mobile/helpers/geolocation_helper.dart';
import 'package:eps_mobile/helpers/permissions_helper.dart';
import 'package:eps_mobile/helpers/shared_prefs_helper.dart';
import 'package:eps_mobile/localizations/localization_value_helper.dart';
import 'package:eps_mobile/models/database.dart';
import 'package:eps_mobile/models/localization.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/models/service_info.dart';
import 'package:eps_mobile/models/user.dart';
import 'package:eps_mobile/queries/permission_queries.dart';
import 'package:eps_mobile/service_helpers/check_connectivity.dart';
import 'package:eps_mobile/service_helpers/login.dart';
import 'package:eps_mobile/sync/full_sync.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

class EpsState {
  User user;
  MepsDatabase database;
  ServiceInfo serviceInfo;
  bool syncData;
  Localization localization;
  LocalizationValueHelper localizationValueHelper = LocalizationValueHelper();
  GeolocationHelper geolocationHelper = GeolocationHelper();
  bool useLocation = false;

  StreamSubscription<ConnectivityResult> connectivitySubscription;
  BuildContext currentContext;

  EpsState() {
    this.user = null;
    this.database = new MepsDatabase();
    this.serviceInfo = new ServiceInfo();
    this.syncData = true;
    this.localization = localizationValueHelper.getEnglishLocalization();
    //this.localization = localizationValueHelper.getEspanolLocalization();
    //this.localization = localizationValueHelper.getFrancaisLocalization();

    // monitor connection state subscription
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult connectivityResult) {
      var previous = this.syncData;
      var isOnlne = CheckConnectivity.isOnline(connectivityResult);
      if (this.syncData != isOnlne) {
        // change state here
        this.syncData = isOnlne;
        showSyncStateMessage(this.currentContext, previous, this.syncData);
      }
      showSyncStateMessage(this.currentContext, previous, this.syncData);
    });
  }

  void dispose() {
    connectivitySubscription.cancel();
  }

  Future<bool> isOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      return true;
    }

    return false;
  }

  Future<bool> userIsAdmin() async {
    return PermissionsHelper.userHasPermission(
      database.database,
      user,
      await PermissionQueries.getPermissionByCode(
        database.database,
        EnumHelper.enumToString(
          PermissionValues.ADMIN,
        ),
      ),
    );
  }

  Future<bool> userHasPermission(
    PermissionValues permissionsValues,
  ) async {
    return PermissionsHelper.userHasPermission(
      database.database,
      user,
      await PermissionQueries.getPermissionByCode(
        database.database,
        EnumHelper.enumToString(
          permissionsValues,
        ),
      ),
    );
  }

  void changeLocalization(
    Localization localization,
  ) {
    var search = localizationValueHelper
        .getAllLocalizations()
        .where((x) => x.code == localization.code)
        .first;
    this.localization = search;
    var prefs = SharedPrefsHelper();
    prefs.setLocalizationPreference(search).whenComplete(() {});
  }

  Future<void> sync() async {
    var result = await FullSync.fullSync(this).then((value) => null);
    if (result.item1 == false) {
      for (var msg in result.item2) {
        // error messages
        print(msg);
      }
    }
  }

  Future<void> authenticateUser() async {
    // refresh jwt
    var localUser = await SecureStoreHelper.getUserById(this.user.id);
    if (localUser != null) {
      var login = Login(this.user.username);
      var result = await login.signIn(
        localUser.item4,
        this.serviceInfo.url,
        this.serviceInfo.useHttps,
      );
      if (result.item1 == true) {
        this.user = result.item2.user;
      }
    }
  }

  void showSyncStateMessage(BuildContext context, bool previous, bool current) {
    if (previous != current) {
      if (current == true) {
        showFlashBasic(
            context,
            this.localizationValueHelper.getValueFromEnum(
                  this.localization,
                  LocalizationKeyValues.YOU_ARE_NOW_IN_ONLINE_MODE,
                ));
      } else {
        showFlashBasic(
            context,
            this.localizationValueHelper.getValueFromEnum(
                  this.localization,
                  LocalizationKeyValues.YOU_ARE_NOW_IN_OFFLINE_MODE,
                ));
      }
    }
  }

  void showFlashBasic(BuildContext context, String msg) {
    showFlash(
      context: context,
      duration: Duration(seconds: 5),
      builder: (context, controller) {
        return Flash(
          controller: controller,
          style: FlashStyle.floating,
          boxShadows: kElevationToShadow[4],
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            message: Text(msg),
            primaryAction: FlatButton(
              onPressed: () => controller.dismiss(),
              child: Text(this.localizationValueHelper.getValueFromEnum(
                    this.localization,
                    LocalizationKeyValues.DISMISS,
                  )),
            ),
          ),
        );
      },
    );
  }

  Future<bool> booleanDialog(
    BuildContext context,
    String title,
    String content,
    String falseText,
    String trueText,
  ) async {
    bool result;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text(falseText),
              onPressed: () {
                result = false;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(trueText),
              onPressed: () {
                result = true;
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
    return result;
  }
}
