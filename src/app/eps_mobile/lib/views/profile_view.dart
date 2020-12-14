import 'dart:async';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/service_helpers/check_connectivity.dart';
import 'package:eps_mobile/views/change_username_view.dart';
import 'package:eps_mobile/views/change_email_view.dart';
import 'package:eps_mobile/views/change_password_view.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:tuple/tuple.dart';

class ProfileView extends StatefulWidget {
  ProfileView({Key key, this.buildMainDrawer, this.epsState}) : super(key: key);

  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  StreamSubscription<ConnectivityResult> connectivitySubscription;
  bool enableConnectionFunctionality = true;

  bool _userIsAdmin = false;
  //bool _userCanAccessProfile = false;
  bool _userCanAccessUpdateAccount = false;

  // localizations
  var localizationProfile = '';
  var localizationName = '';
  var localizationUsername = '';
  var localizationEmail = '';
  var localizationChangeUsername = '';
  var localizationChangeEmail = '';
  var localizationChangePassword = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationProfile =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.PROFILE,
      );
      localizationName =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NAME,
      );
      localizationUsername =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.USERNAME,
      );
      localizationEmail =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EMAIL,
      );
      localizationChangeUsername =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHANGE_USERNAME,
      );
      localizationChangeEmail =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHANGE_EMAIL,
      );
      localizationChangePassword =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHANGE_PASSWORD,
      );
    });
  }

  void refresh() {
    setState(() {
      getLocalizations();
    });
  }

  @override
  void initState() {
    super.initState();

    widget.epsState.currentContext = context;

    refresh();

    getLoadData().then((_) {
      setState(() {
        this._userIsAdmin = _.item1;
        //this._userCanAccessProfile = _.item2;
        this._userCanAccessUpdateAccount = _.item3;
      });
    });

    // set intial connection state
    setState(() {
      Connectivity().checkConnectivity().then((result) {
        enableConnectionFunctionality = CheckConnectivity.isOnline(result);
      });
    });

    // monitor connection state subscription
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult connectivityResult) {
      setState(() {
        enableConnectionFunctionality =
            CheckConnectivity.isOnline(connectivityResult);
      });
    });
  }

  Future<Tuple3<bool, bool, bool>> getLoadData() async {
    return Tuple3<bool, bool, bool>(
      await widget.epsState.userIsAdmin(),
      await widget.epsState.userHasPermission(
        PermissionValues.READ_ACCOUNT,
      ),
      await widget.epsState.userHasPermission(
        PermissionValues.UPDATE_ACCOUNT,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: this.widget.buildMainDrawer
            ? MainDrawerView(
                epsState: this.widget.epsState,
              )
            : null,
        appBar: AppBar(
          title: Text(localizationProfile),
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    var widgets = new List<Widget>();

    widgets
        .add(createTextPair(localizationName + ':', widget.epsState.user.name));
    widgets.add(createTextPair(
        localizationUsername + ':', widget.epsState.user.username));
    widgets.add(
        createTextPair(localizationEmail + ':', widget.epsState.user.email));

    if (_userIsAdmin | _userCanAccessUpdateAccount) {
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
          child: RaisedButton(
            child: Text(localizationChangeUsername),
            onPressed: !enableConnectionFunctionality
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => ChangeUsernameView(
                          buildMainDrawer: false,
                          epsState: widget.epsState,
                        ),
                      ),
                    );
                  },
          ),
        ),
      );

      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
          child: RaisedButton(
            child: Text(localizationChangeEmail),
            onPressed: !enableConnectionFunctionality
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => ChangeEmailView(
                          buildMainDrawer: false,
                          epsState: widget.epsState,
                        ),
                      ),
                    );
                  },
          ),
        ),
      );

      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
          child: RaisedButton(
            child: Text(localizationChangePassword),
            onPressed: !enableConnectionFunctionality
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => ChangePasswordView(
                          buildMainDrawer: false,
                          epsState: widget.epsState,
                        ),
                      ),
                    );
                  },
          ),
        ),
      );
    }

    return ListView(
      children: widgets,
    );
  }

  Widget createTextPair(String title, String value) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.25,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
