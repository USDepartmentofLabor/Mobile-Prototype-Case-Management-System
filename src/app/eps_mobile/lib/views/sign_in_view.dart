import 'package:eps_mobile/custom_fields/helpers/password_helper.dart';
import 'package:eps_mobile/custom_fields/helpers/secure_store_helper.dart';
//import 'package:eps_mobile/helpers/flutter_permissions_helper.dart';
//import 'package:eps_mobile/helpers/geolocation_helper.dart';
import 'package:eps_mobile/helpers/shared_prefs_helper.dart';
import 'package:eps_mobile/localizations/localization_value_helper.dart';
import 'package:eps_mobile/models/database.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/queries/user_queries.dart';
import 'package:eps_mobile/service_helpers/login.dart';
import 'package:eps_mobile/sync/full_sync.dart';
import 'package:eps_mobile/views/case_definitions_view.dart';
import 'package:eps_mobile/views/loading_widget.dart';
import 'package:eps_mobile/views/placeholder_view.dart';
import 'package:eps_mobile/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:eps_mobile/views/request_password_reset_view.dart';
import 'package:loading/indicator/line_scale_indicator.dart';
import 'package:loading/loading.dart';
import 'package:tuple/tuple.dart';

class SignInView extends StatefulWidget {
  SignInView({
    Key key,
    this.title,
  }) : super(key: key);

  final String title;

  @override
  _SignInViewState createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool showAuthErrorMsg = false;
  bool loading = false;
  EpsState epsState;

  // prefs
  Localization loadedLocalizationPref;
  bool loadedUseLocationPref;

  // localizations
  List<Localization> localizations;
  //var _selectedLocalization = 0;
  var localizationSignIn = '';
  var localizationUsername = '';
  var localizationPassword = '';
  var localizationRequestPasswordReset = '';
  var localizationSettings = '';
  var localizationIncorrectUsernameEmailOrPassword = '';
  var localizationSyncing = '';
  var localizationUnauthorized = '';
  var localizationYouAreNotAuthorizedToAccessThisView = '';
  var localizationCaseTypes = '';

  void getLocalizations() {
    setState(() {
      // all localizations available
      localizations = epsState.localizationValueHelper.getAllLocalizations();

      // currently selected from the state
      // var search = epsState.localizationValueHelper
      //     .getAllLocalizations()
      //     .where((x) => x.code == epsState.localization.code)
      //     .first;
      //_selectedLocalization = localizations.indexOf(search);

      // values for this view
      localizationSignIn = epsState.localizationValueHelper.getValueFromEnum(
        epsState.localization,
        LocalizationKeyValues.SIGN_IN,
      );
      localizationUsername = epsState.localizationValueHelper.getValueFromEnum(
        epsState.localization,
        LocalizationKeyValues.USERNAME,
      );
      localizationPassword = epsState.localizationValueHelper.getValueFromEnum(
        epsState.localization,
        LocalizationKeyValues.PASSWORD,
      );
      localizationRequestPasswordReset =
          epsState.localizationValueHelper.getValueFromEnum(
        epsState.localization,
        LocalizationKeyValues.REQUEST_PASSWORD_RESET,
      );
      localizationSettings = epsState.localizationValueHelper.getValueFromEnum(
        epsState.localization,
        LocalizationKeyValues.SETTINGS,
      );
      localizationIncorrectUsernameEmailOrPassword =
          epsState.localizationValueHelper.getValueFromEnum(
        epsState.localization,
        LocalizationKeyValues.INCORRECT_USERNAME_EMAIL_OR_PASSWORD,
      );
      localizationSyncing = epsState.localizationValueHelper.getValueFromEnum(
        epsState.localization,
        LocalizationKeyValues.SYNCING,
      );
      localizationUnauthorized =
          epsState.localizationValueHelper.getValueFromEnum(
        epsState.localization,
        LocalizationKeyValues.UNAUTHORIZED,
      );
      localizationYouAreNotAuthorizedToAccessThisView =
          epsState.localizationValueHelper.getValueFromEnum(
        epsState.localization,
        LocalizationKeyValues.YOU_ARE_NOT_AUTHORIZED_TO_ACCESS_THIS_VIEW,
      );
      localizationCaseTypes = epsState.localizationValueHelper.getValueFromEnum(
        epsState.localization,
        LocalizationKeyValues.CASE_TYPES,
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
    if (epsState == null) {
      epsState = new EpsState();
      epsState.database = new MepsDatabase();
    }

    initSharedPrefs().then((_) {
      setState(() {
        loadedLocalizationPref = _.item1;
        loadedUseLocationPref = _.item2;
        print(loadedLocalizationPref.toString());
        epsState.changeLocalization(_.item1);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSharedPrefs().then((_) {
        setState(() {
          loadedLocalizationPref = _.item1;
          loadedUseLocationPref = _.item2;
          print(loadedLocalizationPref.toString());
          epsState.changeLocalization(_.item1);
        });
      }).then((_) {
        refresh();
      });
    });

    // ask permissions if not match
    // GeolocationHelper()
    //     .getHasLocationPermissions()
    //     .then((hasLocationPermissions) {
    //   if (loadedUseLocationPref == true && hasLocationPermissions == false) {
    //     epsState
    //         .booleanDialog(
    //       context,
    //       'Location Permissions',
    //       'Currently you do not allow location access, would you like to change that?',
    //       'No',
    //       'Yes',
    //     )
    //         .then((userAnswer) {
    //       if (userAnswer) {
    //         FlutterPermissionsHelper.requestLocationPermissions();
    //       }
    //     });
    //   }
    // });

    refresh();
  }

  Future<Tuple2<Localization, bool>> initSharedPrefs() async {
    var prefs = SharedPrefsHelper();
    Localization localization;
    bool useLocation;

    // localization
    // if pref is null set to default, else use stored pref
    var storedLocalizationPreference = await prefs.getLocalizationPreference();
    if (storedLocalizationPreference == null) {
      var defaultPref = LocalizationValueHelper().getEnglishLocalization();
      await prefs.setLocalizationPreference(
        defaultPref,
      );
      localization = defaultPref;
    } else {
      localization = storedLocalizationPreference;
    }

    // use location
    // if pref is null set to default, else use stored pref
    var storedUseLocationPreference = await prefs.getUseLocationPreference();
    if (storedUseLocationPreference == null) {
      var defaultPref = true;
      prefs.setUseLocationPreference(
        defaultPref,
      );
      useLocation = defaultPref;
    } else {
      useLocation = storedUseLocationPreference;
    }

    return Tuple2<Localization, bool>(
      localization,
      useLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        //body: !loading ? buildBody(context) : buildLoading(context),
        body: !loading
            ? buildBody(context)
            : LoadingWidget.buildLoading(context, this.localizationSyncing),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    var widgets = new List<Widget>();

    // Sign-In Text
    widgets.add(Center(
        child: Padding(
      padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: Text(
        localizationSignIn,
        style: TextStyle(
          fontSize: 32,
        ),
      ),
    )));

    // email
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'username',
        decoration: InputDecoration(
          labelText: localizationUsername,
        ),
        keyboardType: TextInputType.text,
      ),
    ));

    // password
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'password',
        decoration: InputDecoration(
          labelText: localizationPassword,
        ),
        obscureText: true,
        maxLines: 1,
      ),
    ));

    // Show if : Error Message
    if (showAuthErrorMsg == true) {
      widgets.add(
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            localizationIncorrectUsernameEmailOrPassword,
            style: TextStyle(fontSize: 16, color: Colors.orange),
          ),
        ),
      );
    }

    // sign in button
    widgets.add(
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 60.0,
        child: RaisedButton(
          child: Text(
            localizationSignIn,
          ),
          onPressed: onSignIn,
        ),
      ),
    );

    // Reset Password
    widgets.add(
      Padding(
        padding: EdgeInsets.fromLTRB(5.0, 50.0, 5.0, 5.0),
        child: GestureDetector(
          child: Text(
            localizationRequestPasswordReset,
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => RequestPasswordResetView(
                  title: localizationRequestPasswordReset,
                  buildMainDrawer: false,
                  epsState: epsState,
                ),
              ),
            );
          },
        ),
      ),
    );

    // settings dialog
    widgets.add(
      Padding(
        padding: EdgeInsets.fromLTRB(5.0, 50.0, 5.0, 5.0),
        child: GestureDetector(
          child: Text(
            localizationSettings,
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
          onTap: () {
            showSettingsInDialog(context);
          },
        ),
      ),
    );

    return ListView(
      children: <Widget>[
        FormBuilder(
          key: _fbKey,
          child: Column(
            children: widgets,
          ),
        ),
      ],
    );
  }

  Widget buildLoading(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Loading(
                indicator: LineScaleIndicator(),
                size: 100.0,
                color: Colors.blue),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Text(localizationSyncing),
            ),
          ],
        ),
      ),
    );
  }

  void onSignIn() async {
    setState(() {
      loading = true;
    });
    var successfullyAuthenticated = false;

    // get the current values
    _fbKey.currentState.save();
    var values = _fbKey.currentState.value;
    var email = '';
    if (values.containsKey('username')) {
      email = values['username'];
    }
    var password = '';
    if (values.containsKey('password')) {
      password = values['password'];
    }

    // validate user input before attempt
    // TO DO

    // if online vs offline
    EpsState thisEpsState = EpsState();
    if (await epsState.isOnline()) {
      // online
      // call service
      var login = new Login(email);
      var signInResult = await login.signIn(
          password, epsState.serviceInfo.url, epsState.serviceInfo.useHttps);
      successfullyAuthenticated = signInResult.item1;
      thisEpsState = signInResult.item2;

      if (successfullyAuthenticated) {
        // add to db
        UserQueries.insertUser(
          epsState.database.database,
          thisEpsState.user,
        );

        // store creds for offline login
        SecureStoreHelper.storeUserCredentials(
          thisEpsState.user.id,
          thisEpsState.user.username,
          PasswordHelper.hashPassword(
            password,
          ),
          password,
        );

        // sync
        await FullSync.fullSync(thisEpsState);
      }
    } else {
      // offline

      var localUserCreds = await SecureStoreHelper.getUserByUserName(
        email,
      );

      // verify
      var hashedPassword = PasswordHelper.hashPassword(
        password,
      );
      if (localUserCreds.item3 == hashedPassword) {
        // good
        successfullyAuthenticated = true;

        // set eps state properties
        var user = await UserQueries.getUserById(
          thisEpsState.database.database,
          localUserCreds.item1,
        );
        if (user == null) {
          successfullyAuthenticated = false;
        } else {
          user.jwtToken = null;
          // TO DO: role?
          thisEpsState.user = user;
        }
      } else {
        // bad
        successfullyAuthenticated = false;
      }
    }

    if (successfullyAuthenticated) {
      thisEpsState.changeLocalization(epsState.localization);

      // nav to content

      // get permissions
      var userIsAdmin = await thisEpsState.userIsAdmin();
      var userCanAccessCaseDefinitionsView =
          await thisEpsState.userHasPermission(
        PermissionValues.READ_CASE_DEFINITION,
      );

      // Navigate based on permissions
      if (userIsAdmin | userCanAccessCaseDefinitionsView) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => CaseDefinitionsView(
                  buildMainDrawer: true,
                  epsState: thisEpsState,
                )));
      } else {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => PlaceholderView(
                  title: localizationUnauthorized,
                  contentMessage:
                      localizationYouAreNotAuthorizedToAccessThisView,
                  buildMainDrawer: true,
                  epsState: thisEpsState,
                )));
      }
    } else {
      // show error
      setState(() {
        loading = false;
      });
      setState(() {
        showAuthErrorMsg = !successfullyAuthenticated;
      });
    }
  }

  // show settings dialog
  void showSettingsInDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(1.0))),
        content: Builder(
          builder: (context) {
            var height = MediaQuery.of(context).size.height;
            var width = MediaQuery.of(context).size.width;
            return Container(
              height: height * 0.95,
              width: width * 0.95,
              child: SettingsView(
                title: localizationSettings,
                buildMainDrawer: false,
                epsState: epsState,
              ),
            );
          },
        ),
      ),
    ).then((_) {
      refresh();
    });
  }
}
