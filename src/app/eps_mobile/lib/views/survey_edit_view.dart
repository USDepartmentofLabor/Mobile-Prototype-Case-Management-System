import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:eps_mobile/helpers/connectivity_helper.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/survey_response.dart';
import 'package:eps_mobile/queries/survey_response_queries.dart';
import 'package:eps_mobile/service_helpers/check_connectivity.dart';
import 'package:eps_mobile/service_helpers/survey_response_edit.dart';
import 'package:eps_mobile/service_helpers/survey_response_post.dart';
import 'package:flutter/material.dart';
import 'package:eps_mobile/survey_js_render/surveyjs_form_builder.dart';

class SurveyEditView extends StatefulWidget {
  SurveyEditView(
      {Key key,
      this.title,
      this.survey,
      this.surveyResponseJson,
      this.surveyResponse,
      this.caseInstance,
      this.epsState})
      : super(key: key);

  final String title;
  final Survey survey;
  final Map surveyResponseJson;
  final SurveyResponse surveyResponse;
  final CaseInstance caseInstance;
  final EpsState epsState;

  @override
  _SurveyEditViewState createState() => _SurveyEditViewState();
}

class _SurveyEditViewState extends State<SurveyEditView> {
  SurveyjsFormBuilder surveyjsFormBuilder;
  Map initialResponse;
  bool isFirstBuild = true;

  bool isOnline;
  bool apiIsReachable;

  // localizations
  var localizationSubmit = '';
  var localizationSaveChangesQuestionTitle = '';
  var localizationChangesMadeMayNotBeSaved = '';
  var localizationExit = '';
  var localizationSave = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationSubmit =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SUBMIT,
      );
      localizationSaveChangesQuestionTitle =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SAVE_CHANGES_QUESTION_TITLE,
      );
      localizationChangesMadeMayNotBeSaved =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CHANGES_MADE_MAY_NOT_BE_SAVED,
      );
      localizationExit =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EXIT,
      );
      localizationSave =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SAVE,
      );
    });
  }

  Future<void> refresh() async {
    var isOnline = await ConnectivityHelper.isOnline();
    var apiIsReachable = await ConnectivityHelper.apiIsReachable(
      widget.epsState.serviceInfo,
    );

    setState(() {
      this.isOnline = isOnline;
      this.apiIsReachable = apiIsReachable;
    });

    setState(() {
      getLocalizations();
    });
  }

  @override
  void initState() {
    super.initState();

    widget.epsState.currentContext = context;

    surveyjsFormBuilder = new SurveyjsFormBuilder(
      surveyjsJson: json.encode(widget.survey.structure).toString(),
      surveyResponseJson: json.encode(widget.surveyResponseJson).toString(),
    );

    refresh().then((value) => null);
  }

  void afterBuild() {
    if (isFirstBuild) {
      initialResponse = surveyjsFormBuilder.getState().getResponseMap();
    }

    if (isFirstBuild) {
      isFirstBuild = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild());
    return WillPopScope(
      onWillPop: () => onEvent(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(this.widget.title),
          ),
          body: surveyjsFormBuilder,
          bottomSheet: SizedBox(
            width: MediaQuery.of(context).size.width * 0.96,
            child: Padding(
              padding: EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
              child: RaisedButton(
                child: Text(localizationSubmit),
                onPressed: () =>
                    submit(context, widget.survey, widget.surveyResponse, true),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> onEvent() async {
    if (initialResponse == null) {
      return true;
    }

    // if no change go, else warn
    var isChange = true;
    // change detection
    isChange = !(initialResponse.toString() ==
        surveyjsFormBuilder.getState().getResponseMap().toString());

    if (isChange) {
      await _asyncConfirmDialog(context);
    }
    return true;
  }

  Future<void> _asyncConfirmDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizationSaveChangesQuestionTitle),
          content: Text(localizationChangesMadeMayNotBeSaved),
          actions: <Widget>[
            FlatButton(
              child: Text(localizationExit),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(localizationSave),
              onPressed: () {
                submit(context, widget.survey, widget.surveyResponse, false);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void submit(BuildContext context, Survey survey,
      SurveyResponse surveyResponse, bool pop) {
    if (widget.surveyResponse == null) {
      submitForm(context, widget.survey, pop);
    } else {
      editResponse(context, widget.survey, widget.surveyResponse, pop);
    }
  }

  Future<Null> submitForm(
    BuildContext context,
    Survey survey,
    bool pop,
  ) async {
    var response = this.surveyjsFormBuilder.getState().getResponseMap();
    SurveyResponse surveyResponse = new SurveyResponse();
    surveyResponse.surveyId = survey.id;
    surveyResponse.structure = response;
    surveyResponse.createdAt = DateTime.now().toUtc();
    surveyResponse.updatedAt = surveyResponse.createdAt;

    var isOnline = false;
    if (widget.epsState.syncData == true) {
      var connectivityResult = await Connectivity().checkConnectivity();
      isOnline = CheckConnectivity.isOnline(connectivityResult);
    }

    if (isOnline && apiIsReachable) {
      // send it
      var send = new SurveyResponsePost(widget.epsState);
      var success = await send.postResponse(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
        survey,
        surveyResponse,
        widget.caseInstance,
      );

      if (success.item1) {
        // add it
        await SurveyResponseQueries.insertSurveyResponse(
          widget.epsState.database.database,
          surveyResponse,
        );
      } else {
        return;
      }
    } else {
      // offline submit
      surveyResponse.id = null;
      await SurveyResponseQueries.insertSurveyResponseLocal(
        widget.epsState.database.database,
        surveyResponse,
      );
    }

    if (pop) {
      Navigator.of(context).pop();
    }
  }

  Future<Null> editResponse(
    BuildContext context,
    Survey survey,
    SurveyResponse surveyResponse,
    bool pop,
  ) async {
    var response = this.surveyjsFormBuilder.getState().getResponseMap();
    surveyResponse.structure = response;
    surveyResponse.updatedAt = DateTime.now().toUtc();

    var isOnline = false;
    if (widget.epsState.syncData == true) {
      var connectivityResult = await Connectivity().checkConnectivity();
      isOnline = CheckConnectivity.isOnline(connectivityResult);
    }

    if (isOnline && apiIsReachable) {
      // send it
      var send = new SurveyResponseEdit(widget.epsState);
      var success = await send.editResponse(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
        survey,
        surveyResponse,
        widget.caseInstance,
      );

      if (success.item1) {
        // add it
        await SurveyResponseQueries.insertSurveyResponse(
          widget.epsState.database.database,
          surveyResponse,
        );
      } else {
        return;
      }
    } else {
      // off line submit
      await SurveyResponseQueries.insertSurveyResponseLocal(
        widget.epsState.database.database,
        surveyResponse,
      );
    }

    if (pop) {
      Navigator.of(context).pop();
    }
  }
}
