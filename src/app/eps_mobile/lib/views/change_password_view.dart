import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/service_helpers/change_password.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flash/flash.dart';

class ChangePasswordView extends StatefulWidget {
  ChangePasswordView({Key key, this.buildMainDrawer, this.epsState})
      : super(key: key);

  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool showErrorMsgs = false;
  List<String> errorMsgs = new List<String>();
  bool obscureText = true;
  List<String> specialCharacterList;

  // values
  String newPassword = '';
  String confirmNewPassword = '';

  // localizations
  var localizationChangePassword = '';
  var localizationNewPassword = '';
  var localizationShow = '';
  var localizationConfirmNewPassword = '';
  var localizationNewPasswordsMustMatch = '';
  var localizationCharacters = '';
  var localizationPasswordsCanNotBeMoreThan = '';
  var localizationPasswordsMustBeAtLeast = '';
  var localizationContainLower = '';
  var localizationContainUpper = '';
  var localizationContainNumber = '';
  var localizationContainSpecialCharacter = '';
  var localizationYourPasswordHasBeenChanged = '';
  var localizationError = '';
  var localizationDismiss = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationChangePassword =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHANGE_PASSWORD,
      );
      localizationNewPassword =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NEW_PASSWORD,
      );
      localizationShow =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SHOW,
      );
      localizationConfirmNewPassword =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CONFIRM_NEW_PASSWORD,
      );
      localizationNewPasswordsMustMatch =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NEW_PASSWORDS_MUST_MATCH,
      );
      localizationCharacters =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHARACTERS,
      );
      localizationPasswordsCanNotBeMoreThan =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.PASSWORDS_CAN_NOT_BE_MORE_THAN,
      );
      localizationPasswordsMustBeAtLeast =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.PASSWORDS_MUST_BE_AT_LEAST,
      );
      localizationContainLower =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.PASSWORD_CONTAIN_LOWER,
      );
      localizationContainUpper =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.PASSWORD_CONTAIN_UPPER,
      );
      localizationContainNumber =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.PASSWORD_CONTAIN_NUMBER,
      );
      localizationContainSpecialCharacter =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.PASSWORD_CONTAIN_SPECIAL,
      );
      localizationYourPasswordHasBeenChanged =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.YOUR_PASSWORD_HAS_BEEN_CHANGED,
      );
      localizationError =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ERROR,
      );
      localizationDismiss =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DISMISS,
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

    this.specialCharacterList = new List<String>();
    this.specialCharacterList.add('!');
    this.specialCharacterList.add('"');
    this.specialCharacterList.add('\$');
    this.specialCharacterList.add('%');
    this.specialCharacterList.add('&');
    this.specialCharacterList.add('\'');
    this.specialCharacterList.add('(');
    this.specialCharacterList.add(')');
    this.specialCharacterList.add('*');
    this.specialCharacterList.add('+');
    this.specialCharacterList.add(',');
    this.specialCharacterList.add('-');
    this.specialCharacterList.add('.');
    this.specialCharacterList.add('/');
    this.specialCharacterList.add(':');
    this.specialCharacterList.add(';');
    this.specialCharacterList.add('<');
    this.specialCharacterList.add('=');
    this.specialCharacterList.add('>');
    this.specialCharacterList.add('?');
    this.specialCharacterList.add('@');
    this.specialCharacterList.add('[');
    this.specialCharacterList.add(']');
    this.specialCharacterList.add('{');
    this.specialCharacterList.add('}');
    this.specialCharacterList.add('\\');
    this.specialCharacterList.add('|');
    this.specialCharacterList.add('^');
    this.specialCharacterList.add('_');
    this.specialCharacterList.add('`');
    this.specialCharacterList.add('~');
    this.specialCharacterList.add('#');
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
          title: Text(localizationChangePassword),
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    var widgets = new List<Widget>();

    // new password
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'new_password',
        decoration: InputDecoration(labelText: localizationNewPassword),
        obscureText: obscureText,
        maxLines: 1,
        onChanged: checkInputNewPassword,
      ),
    ));

    // confirm new password
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'confirm_new_password',
        decoration: InputDecoration(labelText: localizationConfirmNewPassword),
        obscureText: obscureText,
        maxLines: 1,
        onChanged: checkInputConfirmNewPassword,
      ),
    ));

    // show passwords
    widgets.add(
      Padding(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: FormBuilderCheckbox(
          label: Text(localizationShow),
          onChanged: setShowPasswordState,
          attribute: 'showPasswords',
          leadingInput: true,
        ),
      ),
    );

    // change password button
    widgets.add(
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 60.0,
        child: RaisedButton(
          child: Text(localizationChangePassword),
          onPressed: onChangePassword,
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

  void setShowPasswordState(dynamic value) {
    var newValue = false;
    if (value == false) {
      newValue = true;
    }
    setState(() {
      obscureText = newValue;
    });
  }

  void gatherValues() {
    _fbKey.currentState.save();
    var values = _fbKey.currentState.value;
    if (values.containsKey('new_password')) {
      newPassword = values['new_password'];
    }
    if (values.containsKey('confirm_new_password')) {
      confirmNewPassword = values['confirm_new_password'];
    }
  }

  void checkInputNewPassword(dynamic value) {
    gatherValues();
    this.newPassword = value;
    checkInputs();
  }

  void checkInputConfirmNewPassword(dynamic value) {
    gatherValues();
    this.confirmNewPassword = value;
    checkInputs();
  }

  void checkInputs() {
    this.errorMsgs.clear();

    // new passwords must match
    if (newPassword != confirmNewPassword) {
      errorMsgs.add(localizationNewPasswordsMustMatch);
    }

    // min length
    if (newPassword.length < 10) {
      errorMsgs.add(
          localizationPasswordsMustBeAtLeast + ' 10 ' + localizationCharacters);
    }

    // max length
    if (newPassword.length > 64) {
      errorMsgs.add(localizationPasswordsCanNotBeMoreThan +
          ' 64 ' +
          localizationCharacters);
    }

    // has at least 1 number
    // has at least 1 special char
    // mix upper and lower case alphas
    var hasNumber = false;
    var hasSpecialChar = false;
    var hasUpper = false;
    var hasLower = false;
    newPassword.runes.forEach((int rune) {
      var char = new String.fromCharCode(rune);

      if ((rune >= 97) & (rune <= 122)) {
        hasLower = true;
      }

      if ((rune >= 65) & (rune <= 90)) {
        hasUpper = true;
      }

      if ((rune >= 48) & (rune <= 57)) {
        hasNumber = true;
      }

      if (this.specialCharacterList.contains(char)) {
        hasSpecialChar = true;
      }
    });

    if (!hasUpper) {
      errorMsgs.add(localizationContainUpper);
    }

    if (!hasLower) {
      errorMsgs.add(localizationContainLower);
    }

    if (!hasNumber) {
      errorMsgs.add(localizationContainNumber);
    }

    if (!hasSpecialChar) {
      errorMsgs.add(localizationContainSpecialCharacter);
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
    var changePassword = new ChangePassword(widget.epsState);
    var successfullyChanged = await changePassword.changePassword(
      widget.epsState.serviceInfo.url,
      widget.epsState.serviceInfo.useHttps,
      newPassword,
      confirmNewPassword,
      widget.epsState.user.id,
    );
    if (successfullyChanged.item1) {
      showFlashBasic(localizationYourPasswordHasBeenChanged);
      Navigator.of(context).pop();
    } else {
      // TO DO: more specific error msgs
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
