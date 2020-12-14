import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/service_helpers/user_change_email.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flash/flash.dart';

class ChangeEmailView extends StatefulWidget {
  ChangeEmailView({Key key, this.buildMainDrawer, this.epsState})
      : super(key: key);

  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _ChangeEmailViewState createState() => _ChangeEmailViewState();
}

class _ChangeEmailViewState extends State<ChangeEmailView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool showErrorMsgs = false;
  List<String> errorMsgs = new List<String>();

  // values
  String newEmail = '';

  // localizations
  var localizationChangeEmail = '';
  var localizationOldEmail = '';
  var localizationNewEmail = '';
  var localizationChange = '';
  var localizationCanNotBeOldEmail = '';
  var localizationEmailCanNotContainSpaces = '';
  var localizationEmaiCanNotBeBlank = '';
  var localizationCharacters = '';
  var localizationEmailCanNotBeMoreThan = '';
  var localizationEmailMustBeAtLeast = '';
  var localizationMustBeAValidEmail = '';
  var localizationYourEmailHasBeenChanged = '';
  var localizationError = '';
  var localizationDismiss = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationChangeEmail =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHANGE_EMAIL,
      );
      localizationOldEmail =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.OLD_EMAIL,
      );
      localizationNewEmail =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NEW_EMAIL,
      );
      localizationChange =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHANGE,
      );
      localizationCanNotBeOldEmail =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CAN_NOT_BE_OLD_EMAIL,
      );
      localizationEmailCanNotContainSpaces =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EMAIL_CAN_NOT_CONTAIN_SPACES,
      );
      localizationEmaiCanNotBeBlank =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EMAIL_CAN_NOT_BE_BLANK,
      );
      localizationCharacters =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHARACTERS,
      );
      localizationEmailCanNotBeMoreThan =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EMAIL_CAN_NOT_BE_MORE_THAN,
      );
      localizationEmailMustBeAtLeast =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EMAIL_MUST_BE_AT_LEAST,
      );
      localizationMustBeAValidEmail =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.MUST_BE_A_VALID_EMAIL,
      );
      localizationYourEmailHasBeenChanged =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.YOUR_EMAIL_HAS_BEEN_CHANGED,
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
          title: Text(localizationChangeEmail),
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    var widgets = new List<Widget>();

    // old email
    widgets.add(
      Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
            child: Text(
              localizationOldEmail + ':',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
            child: Text(
              widget.epsState.user.email,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );

    // new email
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'new_email',
        decoration: InputDecoration(labelText: localizationNewEmail),
        onChanged: checkInputNewEmail,
        initialValue: widget.epsState.user.email,
        autofocus: true,
      ),
    ));

    // change password button
    widgets.add(
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 60.0,
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          child: RaisedButton(
            child: Text(localizationChange),
            //onPressed: onChangePassword,
            onPressed: changeEmailOnPressed(),
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

  Function changeEmailOnPressed() {
    if (errorMsgs.length == 0) {
      return onChangePassword;
    } else {
      return null;
    }
  }

  void gatherValues() {
    _fbKey.currentState.save();
    var values = _fbKey.currentState.value;
    if (values.containsKey('new_email')) {
      newEmail = values['new_email'];
    }
  }

  void checkInputNewEmail(dynamic value) {
    gatherValues();
    this.newEmail = value;
    checkInputs();
  }

  void checkInputs() {
    this.errorMsgs.clear();

    // new passwords must match
    if (widget.epsState.user.email == newEmail) {
      errorMsgs.add(localizationCanNotBeOldEmail);
    }

    // no spaces
    var charCountNonSpace = 0;
    var charCountSpace = 0;
    for (var char in newEmail.runes) {
      if (char == 32) {
        charCountSpace++;
      } else {
        charCountNonSpace++;
      }
    }
    if (charCountSpace > 0) {
      errorMsgs.add(localizationEmailCanNotContainSpaces);
    }

    // non blank
    if (newEmail.length == 0 || charCountNonSpace == 0) {
      errorMsgs.add(localizationEmaiCanNotBeBlank);
    }

    // min length
    int minLength = 5;
    if (newEmail.length < 5) {
      errorMsgs.add(localizationEmailMustBeAtLeast +
          ' ' +
          minLength.toString() +
          ' ' +
          localizationCharacters);
    }

    // max length
    int maxLength = 50;
    if (newEmail.length > 50) {
      errorMsgs.add(localizationEmailCanNotBeMoreThan +
          ' ' +
          maxLength.toString() +
          ' ' +
          localizationCharacters);
    }

    // regex valid email
    RegExp validEmail = new RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
      caseSensitive: false,
    );
    if (!validEmail.hasMatch(newEmail)) {
      errorMsgs.add(localizationMustBeAValidEmail);
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
    var userChangeEmail = new UserChangeEmail(widget.epsState);
    var successfullyChanged = await userChangeEmail.changeEmail(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
        newEmail,
        widget.epsState.user.id);
    if (successfullyChanged.item1) {
      showFlashBasic(localizationYourEmailHasBeenChanged);
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
