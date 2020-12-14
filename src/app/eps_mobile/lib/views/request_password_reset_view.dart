import 'package:connectivity/connectivity.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/service_helpers/check_connectivity.dart';
import 'package:eps_mobile/service_helpers/request_password_reset.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class RequestPasswordResetView extends StatefulWidget {
  RequestPasswordResetView(
      {Key key, this.title, this.buildMainDrawer, this.epsState})
      : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _RequestPasswordResetViewState createState() =>
      _RequestPasswordResetViewState();
}

class _RequestPasswordResetViewState extends State<RequestPasswordResetView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool showErrorMsgs = false;
  List<String> errorMsgs = new List<String>();

  String email;

  // localizations
  List<Localization> localizations;
  //var _selectedLocalization = 0;
  var localizationEmail = '';
  var localizationRequest = '';
  var localizationEmailCanNotContainSpaces = '';
  var localizationEmailCanNotBeBlank = '';
  var localizationMustBeAValidEmail = '';
  var localizationNoConnectivityPleaseTryAgainLater = '';
  var localizationAnEmailWithInstructionsToResetYourPasswordHasBeenSentToYou =
      '';
  var localizationAnErrorOccurredPleaseTryAgainLater = '';
  var localizationDismiss = '';

  void getLocalizations() {
    setState(() {
      // all localizations available
      localizations =
          widget.epsState.localizationValueHelper.getAllLocalizations();

      // currently selected from the state
      //_selectedLocalization =
      //    localizations.indexOf(widget.epsState.localization);

      // values for this view
      localizationEmail =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EMAIL,
      );
      localizationRequest =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.REQUEST,
      );
      localizationEmailCanNotContainSpaces =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EMAIL_CAN_NOT_CONTAIN_SPACES,
      );
      localizationEmailCanNotBeBlank =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EMAIL_CAN_NOT_BE_BLANK,
      );
      localizationMustBeAValidEmail =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.MUST_BE_A_VALID_EMAIL,
      );
      localizationNoConnectivityPleaseTryAgainLater =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NO_CONNECTIVITY_PLEASE_TRY_AGAIN_LATER,
      );
      localizationAnEmailWithInstructionsToResetYourPasswordHasBeenSentToYou =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues
            .AN_EMAIL_WITH_INSTRUCTIONS_TO_RESET_YOUR_PASSWORD_HAS_BEEN_SENT_TO_YOU,
      );
      localizationAnErrorOccurredPleaseTryAgainLater =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.AN_ERROR_OCCURRED_PLEASE_TRY_AGAIN_LATER,
      );
      localizationDismiss =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DISMISS,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {
      getLocalizations();
    });
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
          title: Text(this.widget.title),
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    var widgets = new List<Widget>();

    // email
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'email',
        decoration: InputDecoration(labelText: localizationEmail),
        keyboardType: TextInputType.text,
        autofocus: true,
        onChanged: checkInputEmail,
      ),
    ));

    // request button
    widgets.add(
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 60.0,
        child: RaisedButton(
          child: Text(localizationRequest),
          onPressed: sendRequestOnPressed(),
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

  Function sendRequestOnPressed() {
    if (errorMsgs.length == 0) {
      return onRequest;
    } else {
      return null;
    }
  }

  void gatherValues() {
    _fbKey.currentState.save();
    var values = _fbKey.currentState.value;
    if (values.containsKey('email')) {
      email = values['email'];
    }
  }

  void checkInputEmail(dynamic value) {
    gatherValues();
    this.email = value;
    checkInputs();
  }

  void checkInputs() {
    this.errorMsgs.clear();

    // no spaces
    var charCountNonSpace = 0;
    var charCountSpace = 0;
    for (var char in email.runes) {
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
    if (email.length == 0 || charCountNonSpace == 0) {
      errorMsgs.add(localizationEmailCanNotBeBlank);
    }

    // regex valid email
    RegExp validEmail = new RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
      caseSensitive: false,
    );
    if (!validEmail.hasMatch(email)) {
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

  void onRequest() async {
    gatherValues();

    // check connectivity
    if (CheckConnectivity.isOnline(await Connectivity().checkConnectivity()) ==
        false) {
      showFlashBasic(localizationNoConnectivityPleaseTryAgainLater);
      return;
    }

    // attempt request
    var requestPasswordReset = new RequestPasswordReset(widget.epsState);
    var successfullySent = await requestPasswordReset.sendRequestPasswordReset(
        email,
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps);

    if (successfullySent) {
      showFlashBasic(
          localizationAnEmailWithInstructionsToResetYourPasswordHasBeenSentToYou);
      Navigator.of(context).pop();
    } else {
      showFlashBasic(localizationAnErrorOccurredPleaseTryAgainLater);
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
