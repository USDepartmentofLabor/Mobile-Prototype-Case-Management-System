import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/service_helpers/user_change_username.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flash/flash.dart';

class ChangeUsernameView extends StatefulWidget {
  ChangeUsernameView({Key key, this.buildMainDrawer, this.epsState})
      : super(key: key);

  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _ChangeUsernameViewState createState() => _ChangeUsernameViewState();
}

class _ChangeUsernameViewState extends State<ChangeUsernameView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool showErrorMsgs = false;
  List<String> errorMsgs = new List<String>();

  // values
  String newUsername = '';

  // localizations
  var localizationChangeUsername = '';
  var localizationOldUsername = '';
  var localizationNewUsername = '';
  var localizationChange = '';
  var localizationCanNotBeOldUsername = '';
  var localizationUsernameCanNotContainSpaces = '';
  var localizationUsernameCanNotBeBlank = '';
  var localizationCharacters = '';
  var localizationUsernameCanNotBeMoreThan = '';
  var localizationUsernameMustBeAtLeast = '';
  var localizationYourUsernameHasBeenChanged = '';
  var localizationError = '';
  var localizationDismiss = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationChangeUsername =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHANGE_USERNAME,
      );
      localizationOldUsername =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.OLD_USERNAME,
      );
      localizationNewUsername =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NEW_USERNAME,
      );
      localizationChange =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHANGE,
      );
      localizationCanNotBeOldUsername = widget.epsState.localizationValueHelper
          .getValueFromEnum(widget.epsState.localization,
              LocalizationKeyValues.CAN_NOT_BE_OLD_USERNAME);
      localizationUsernameCanNotContainSpaces =
          widget.epsState.localizationValueHelper.getValueFromEnum(
              widget.epsState.localization,
              LocalizationKeyValues.USERNAME_CAN_NOT_CONTAIN_SPACES);
      localizationUsernameCanNotBeBlank =
          widget.epsState.localizationValueHelper.getValueFromEnum(
              widget.epsState.localization,
              LocalizationKeyValues.USERNAME_CAN_NOT_BE_BLANK);
      localizationCharacters = widget.epsState.localizationValueHelper
          .getValueFromEnum(
              widget.epsState.localization, LocalizationKeyValues.CHARACTERS);
      localizationUsernameCanNotBeMoreThan =
          widget.epsState.localizationValueHelper.getValueFromEnum(
              widget.epsState.localization,
              LocalizationKeyValues.USERNAME_CAN_NOT_BE_MORE_THAN);
      localizationUsernameMustBeAtLeast =
          widget.epsState.localizationValueHelper.getValueFromEnum(
              widget.epsState.localization,
              LocalizationKeyValues.USERNAME_MUST_BE_AT_LEAST);
      localizationYourUsernameHasBeenChanged =
          widget.epsState.localizationValueHelper.getValueFromEnum(
              widget.epsState.localization,
              LocalizationKeyValues.YOUR_USERNAME_HAS_BEEN_CHANGED);
      localizationError = widget.epsState.localizationValueHelper
          .getValueFromEnum(
              widget.epsState.localization, LocalizationKeyValues.ERROR);
      localizationDismiss = widget.epsState.localizationValueHelper
          .getValueFromEnum(
              widget.epsState.localization, LocalizationKeyValues.DISMISS);
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
          title: Text(localizationChangeUsername),
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    var widgets = new List<Widget>();

    // old username
    widgets.add(
      Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
            child: Text(
              localizationOldUsername + ':',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
            child: Text(
              widget.epsState.user.username,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );

    // new username
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'new_username',
        decoration: InputDecoration(labelText: localizationNewUsername),
        onChanged: checkInputNewEmail,
        initialValue: widget.epsState.user.username,
        autofocus: true,
      ),
    ));

    // change username button
    widgets.add(
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 60.0,
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          child: RaisedButton(
            child: Text(localizationChange),
            //onPressed: onChangePassword,
            onPressed: changeUsernameOnPressed(),
          ),
        ),
      ),
    );

    // show if: error messages
    if (showErrorMsgs == true) {
      for (var msg in errorMsgs) {
        widgets.add(
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              msg,
              style: TextStyle(fontSize: 16, color: Colors.deepOrange),
            ),
          ),
        );
      }
    }

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

  Function changeUsernameOnPressed() {
    if (errorMsgs.length == 0) {
      return onChangePassword;
    } else {
      return null;
    }
  }

  void gatherValues() {
    _fbKey.currentState.save();
    var values = _fbKey.currentState.value;
    if (values.containsKey('new_username')) {
      newUsername = values['new_username'];
    }
  }

  void checkInputNewEmail(dynamic value) {
    gatherValues();
    this.newUsername = value;
    checkInputs();
  }

  void checkInputs() {
    this.errorMsgs.clear();

    // new passwords must match
    if (widget.epsState.user.username == newUsername) {
      errorMsgs.add(localizationCanNotBeOldUsername);
    }

    // no spaces
    var charCountNonSpace = 0;
    var charCountSpace = 0;
    for (var char in newUsername.runes) {
      if (char == 32) {
        charCountSpace++;
      } else {
        charCountNonSpace++;
      }
    }
    if (charCountSpace > 0) {
      errorMsgs.add(localizationUsernameCanNotContainSpaces);
    }

    // non blank
    if (newUsername.length == 0 || charCountNonSpace == 0) {
      errorMsgs.add(localizationUsernameCanNotBeBlank);
    }

    // min length
    int minLength = 5;
    if (newUsername.length < 5) {
      errorMsgs.add(localizationUsernameMustBeAtLeast +
          ' ' +
          minLength.toString() +
          ' ' +
          localizationCharacters);
    }

    // max length
    int maxLength = 50;
    if (newUsername.length > 50) {
      errorMsgs.add(localizationUsernameCanNotBeMoreThan +
          ' ' +
          maxLength.toString() +
          ' ' +
          localizationCharacters);
    }

    setShowErrorMsgs();
  }

  void setShowErrorMsgs() {
    var show = false;
    if (errorMsgs.length > 0) {
      show = true;
    } else {
      show = false;
    }
    setState(() {
      showErrorMsgs = show;
    });
  }

  void onChangePassword() async {
    gatherValues();
    var userChangeUsername = new UserChangeUsername(widget.epsState);
    var successfullyChanged = await userChangeUsername.changeUsername(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
        newUsername,
        widget.epsState.user.id);
    if (successfullyChanged.item1) {
      showFlashBasic(localizationYourUsernameHasBeenChanged);
      Navigator.of(context).pop();
    } else {
      checkInputs();
      errorMsgs.add(localizationError);
      setShowErrorMsgs();
    }
  }

  void showFlashBasic(String msg) {
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
              child: Text(localizationDismiss),
            ),
          ),
        );
      },
    );
  }
}
