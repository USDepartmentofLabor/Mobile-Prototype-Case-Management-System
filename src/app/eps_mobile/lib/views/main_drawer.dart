import 'package:connectivity/connectivity.dart';
import 'package:eps_mobile/helpers/color_helper.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/service_helpers/check_connectivity.dart';
import 'package:eps_mobile/sync/full_sync.dart';
import 'package:eps_mobile/views/case_definitions_view.dart';
import 'package:eps_mobile/views/project_view.dart';
import 'package:eps_mobile/views/settings_view.dart';
import 'package:eps_mobile/views/test_thing_view.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:eps_mobile/service_helpers/logout.dart';
import 'package:eps_mobile/views/profile_view.dart';
import 'package:eps_mobile/views/sign_in_view.dart';
import 'package:eps_mobile/views/surveys_view.dart';
import 'package:tuple/tuple.dart';

class MainDrawerView extends StatefulWidget {
  MainDrawerView(
      {Key key,
      this.title,
      this.contentMessage,
      this.buildMainDrawer,
      this.epsState})
      : super(key: key);

  final String title;
  final String contentMessage;
  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _MainDrawerViewState createState() => _MainDrawerViewState();
}

class _MainDrawerViewState extends State<MainDrawerView> {
  bool syncState = true;
  bool _userIsAdmin = false;
  bool _userCanAccessUserAccount = false;
  bool _userCanAccessSurveys = false;
  bool _userCanAccessCases = false;
  //bool _userCanAccessProject = false;

  // localizations
  var localizationProjectInfo = '';
  var localizationCases = '';
  var localizationCaseTypes = '';
  var localizationSurveys = '';
  var localizationSync = '';
  var localizationDismiss = '';
  var localizationUnableToGoOnlinePleaseCheckYourInternetConnection = '';
  var localizationYouAreNowInOnlineMode = '';
  var localizationYouAreNotInOfflineMode = '';
  var localizationOnline = '';
  var localizationOffline = '';
  var localizationSettings = '';
  var localizationSignOut = '';
  var localizationAppName = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationProjectInfo =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.PROJECT_INFO,
      );
      localizationCases =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CASES,
      );
      localizationCaseTypes =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CASE_TYPES,
      );
      localizationSurveys =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SURVEYS,
      );
      localizationSync =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SYNC,
      );
      localizationDismiss =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DISMISS,
      );
      localizationUnableToGoOnlinePleaseCheckYourInternetConnection =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues
            .UNABLE_TO_GO_ONLINE_PLEASE_CHECK_YOUR_INTERNET_CONNECTION,
      );
      localizationYouAreNowInOnlineMode =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.YOU_ARE_NOW_IN_ONLINE_MODE,
      );
      localizationYouAreNotInOfflineMode =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.YOU_ARE_NOW_IN_OFFLINE_MODE,
      );
      localizationOnline =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ONLINE,
      );
      localizationOffline =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.OFFLINE,
      );
      localizationSettings = widget.epsState.localizationValueHelper
          .getValueFromEnum(
              widget.epsState.localization, LocalizationKeyValues.SETTINGS);
      localizationSignOut =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SIGN_OUT,
      );
      localizationAppName =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.APP_NAME,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    getLoadData().then((_) {
      setState(() {
        this._userIsAdmin = _.item1;
        this._userCanAccessUserAccount = _.item2;
        this._userCanAccessSurveys = _.item3;
        this._userCanAccessCases = _.item4;
        //this._userCanAccessProject = _.item5;
      });
    });

    refresh();
  }

  void refresh() {
    setState(() {
      getLocalizations();
    });
  }

  // async - get permissions
  Future<Tuple5<bool, bool, bool, bool, bool>> getLoadData() async {
    return Tuple5<bool, bool, bool, bool, bool>(
      await widget.epsState.userIsAdmin(),
      await widget.epsState.userHasPermission(
        PermissionValues.READ_ACCOUNT,
      ),
      await widget.epsState.userHasPermission(PermissionValues.READ_SURVEY),
      await widget.epsState
          .userHasPermission(PermissionValues.READ_CASE_DEFINITION),
      await widget.epsState.userHasPermission(PermissionValues.READ_PROJECT),
    );
  }

  Widget drawerBuild(BuildContext context) {
    return this.build(context);
  }

  @override
  Widget build(BuildContext context) {
    var widgets = List<Widget>();

    if (_userIsAdmin | _userCanAccessUserAccount) {
      widgets.add(
        getUserAccount(context, widget.epsState),
      );
    }

    if (_userIsAdmin | _userCanAccessSurveys) {
      widgets.add(
        getSurveys(context, widget.epsState),
      );
    }

    if (_userIsAdmin | _userCanAccessCases) {
      widgets.add(
        getCases(context, widget.epsState),
      );
    }

    // if (_userIsAdmin | _userCanAccessProject) {
    //   widgets.add(
    //     getProject(context, widget.epsState),
    //   );
    // }

    // no restrictions on settings, sync state, sign out
    widgets.add(
      getSettings(context, widget.epsState),
    );
    //widgets.add(getTestThing(context, widget.epsState));
    widgets.add(
      Padding(
        padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
        child: getSyncState(context, widget.epsState),
      ),
    );
    widgets.add(
      Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: getSignOut(context, widget.epsState),
        ),
      ),
    );

    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: widgets,
      ),
    );
  }

  Widget getProject(BuildContext buildContext, EpsState epsState) {
    return ListTile(
      title: Text(localizationProjectInfo),
      trailing: Icon(Icons.supervised_user_circle),
      onTap: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => ProjectView(
                  title: localizationProjectInfo,
                  buildMainDrawer: true,
                  epsState: epsState,
                )));
      },
    );
  }

  //
  Widget getTestThing(BuildContext context, EpsState epsState) {
    return ListTile(
      title: Text('TEST'),
      trailing: Icon(Icons.text_fields),
      onTap: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => TestThingView(
                  title: 'TEST',
                  buildMainDrawer: true,
                  epsState: epsState,
                )));
      },
    );
  }
  //

  Widget getUserAccount(BuildContext context, EpsState epsState) {
    var initial = '';
    if (epsState.user.name.length > 0) {
      initial = '${epsState.user.name[0]}';
    }

    return GestureDetector(
      child: UserAccountsDrawerHeader(
        accountEmail: Text(epsState.user.email),
        accountName: Text(epsState.user.name),
        currentAccountPicture: CircleAvatar(
          backgroundColor: ColorHelper.getColor(epsState.user.color),
          child: Text(initial),
        ),
      ),
      onTap: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => ProfileView(
                  buildMainDrawer: true,
                  epsState: epsState,
                )));
      },
    );
  }

  Widget getCases(BuildContext context, EpsState epsState) {
    return ListTile(
      title: Text(localizationCases),
      trailing: Icon(Icons.assignment),
      onTap: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => CaseDefinitionsView(
                  buildMainDrawer: true,
                  epsState: epsState,
                )));
      },
    );
  }

  Widget getSurveys(BuildContext context, EpsState epsState) {
    return ListTile(
      title: Text(localizationSurveys),
      trailing: Icon(Icons.assignment),
      onTap: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => SurveysView(
                  title: localizationSurveys,
                  buildMainDrawer: true,
                  epsState: epsState,
                )));
      },
    );
  }

  Widget getSyncState(BuildContext context, EpsState epsState) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: <Widget>[
          Text(localizationSync),
          Switch(
            value: epsState.syncData,
            onChanged: (bool value) {
              // check that online is available
              if (value == true) {
                if (widget.epsState.syncData == false) {
                  Connectivity().checkConnectivity().then((connectivityResult) {
                    var isOnlineCapable =
                        CheckConnectivity.isOnline(connectivityResult);
                    if (isOnlineCapable == false) {
                      // warn
                      showFlash(
                        context: context,
                        duration: Duration(seconds: 5),
                        builder: (context, controller) {
                          return Flash(
                            controller: controller,
                            style: FlashStyle.floating,
                            boxShadows: kElevationToShadow[4],
                            horizontalDismissDirection:
                                HorizontalDismissDirection.horizontal,
                            child: FlashBar(
                              message: Text(
                                  localizationUnableToGoOnlinePleaseCheckYourInternetConnection),
                              primaryAction: FlatButton(
                                onPressed: () => controller.dismiss(),
                                child: Text(localizationDismiss),
                              ),
                            ),
                          );
                        },
                      );
                      // cancel change
                    } else /* online capable */ {
                      setState(() {
                        widget.epsState.syncData = value;
                        widget.epsState.showFlashBasic(
                            context, localizationYouAreNowInOnlineMode);
                        if (widget.epsState.syncData == true) {
                          // if sign in offline, get jwt
                          if (widget.epsState.user.jwtToken == null) {
                            widget.epsState
                                .authenticateUser()
                                .then((authValue) => {});
                          }
                          // sync
                          //widget.epsState.sync().then((x) {});
                          FullSync.fullSync(widget.epsState).then((value) {
                            widget.epsState.showFlashBasic(
                              context,
                              value.boolValue ? 'Sync Complete' : 'Sync Error',
                            );
                          });
                        }
                      });
                    }
                  });
                } else {
                  setState(() {
                    widget.epsState.syncData = value;
                    if (widget.epsState.syncData == true) {
                      //widget.epsState.sync().then((x) {});
                      FullSync.fullSync(widget.epsState).then((value) {
                        widget.epsState.showFlashBasic(
                          context,
                          value.boolValue ? 'Sync Complete' : 'Sync Error',
                        );
                      });
                    }
                  });
                }
              } else /* false */ {
                setState(() {
                  widget.epsState.syncData = value;
                  widget.epsState.showFlashBasic(
                      context, localizationYouAreNotInOfflineMode);
                });
              }
            },
          ),
          Text(widget.epsState.syncData
              ? localizationOnline
              : localizationOffline),
        ],
      ),
    );
  }

  Widget getSettings(BuildContext context, EpsState epsState) {
    return ListTile(
      title: Text(localizationSettings),
      trailing: Icon(Icons.settings),
      onTap: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => SettingsView(
                  title: localizationSettings,
                  buildMainDrawer: true,
                  epsState: epsState,
                )));
      },
    );
  }

  Widget getSignOut(BuildContext context, EpsState epsState) {
    return ListTile(
      title: Text(localizationSignOut),
      trailing: Icon(Icons.exit_to_app),
      onTap: () async {
        var logout = new Logout(epsState);
        var logoutResult = await logout.signOut(
            epsState.serviceInfo.url, epsState.serviceInfo.useHttps);
        var successfullyLoggedOut = logoutResult.item1;
        if (!successfullyLoggedOut) {
          epsState.user.jwtToken = '';
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => SignInView(
                  title: localizationAppName,
                )));
      },
    );
  }
}
