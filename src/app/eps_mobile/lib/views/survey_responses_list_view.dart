import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/survey_response.dart';
import 'package:eps_mobile/service_helpers/survey_response_archive.dart';
import 'package:eps_mobile/views/survey_edit_view.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class SurveyResponsesListView extends StatefulWidget {
  SurveyResponsesListView({
    Key key,
    this.buildMainDrawer,
    this.epsState,
    this.survey,
    this.surveyResponses,
    this.caseInstance,
  }) : super(key: key);

  final bool buildMainDrawer;
  final EpsState epsState;
  final Survey survey;
  final List<SurveyResponse> surveyResponses;
  final CaseInstance caseInstance;

  @override
  _SurveyResponsesListViewState createState() =>
      _SurveyResponsesListViewState();
}

class _SurveyResponsesListViewState extends State<SurveyResponsesListView> {
  bool _userIsAdmin = false;
  bool _userCanAccessUpdateSurvey = false;
  //bool _userCanAccessDeleteSurvey = false;

  // localizations
  var localizationDismiss = '';
  var localizationOk = '';
  var localizationCancel = '';
  var localizationErrorArchivingResponse = '';
  var localizationArchiveResponseQuestionTitel = '';
  var localizationAreYouSureYouWantToArchiveThisResponse = '';
  var localizationUnauthorized = '';
  var localizationId = '';
  var localizationLastUpdatedAt = '';
  var localizationCreatedAt = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationDismiss =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DISMISS,
      );
      localizationOk = widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.OK,
      );
      localizationCancel =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CANCEL,
      );
      localizationErrorArchivingResponse =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ERROR_ARCHIVING_RESPONSE,
      );
      localizationArchiveResponseQuestionTitel =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ARCHIVE_RESPONSE_QUESTION_TITLE,
      );
      localizationAreYouSureYouWantToArchiveThisResponse =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ARE_YOU_SURE_YOU_WANT_TO_ARCHIVE_THIS_RESPONSE,
      );
      localizationUnauthorized =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.UNAUTHORIZED,
      );
      localizationId = widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ID,
      );
      localizationLastUpdatedAt =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.LAST_UPDATED_AT,
      );
      localizationCreatedAt =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CREATED_AT,
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
    getLoadData().then((_) {
      setState(() {
        this._userIsAdmin = _.item1;
        this._userCanAccessUpdateSurvey = _.item2;
        //this._userCanAccessDeleteSurvey = _.item3;
      });
    });
    refresh();
  }

  Future<Tuple3<bool, bool, bool>> getLoadData() async {
    return Tuple3<bool, bool, bool>(
      await widget.epsState.userIsAdmin(),
      await widget.epsState.userHasPermission(
        PermissionValues.UPDATE_SURVEY,
      ),
      await widget.epsState.userHasPermission(
        PermissionValues.DELETE_SURVEY,
      ),
    );
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
          title: Text(widget.survey.name),
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    var widgets = new List<Widget>();

    var idWidth = 0.1;
    var updatedWidth = 0.35;
    var createdWidth = 0.35;

    // headers
    widgets.add(
      Padding(
        padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * idWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                child: Text(localizationId),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * updatedWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                child: Text(localizationLastUpdatedAt),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * createdWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                child: Text(localizationCreatedAt),
              ),
            ),
          ],
        ),
      ),
    );

    // values
    for (var surveyResponse in widget.surveyResponses) {
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 20.0),
          child: Row(
            children: <Widget>[
              // Info (Id, updated, created)
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width * idWidth,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                        child: Text(surveyResponse.id.toString()),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * updatedWidth,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                        child: Text(getDateFormatted(
                                surveyResponse.updatedAt.toLocal()) +
                            ' - ' +
                            getTimeFormatted(
                                surveyResponse.updatedAt.toLocal())),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * createdWidth,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                        child: Text(getDateFormatted(
                                surveyResponse.createdAt.toLocal()) +
                            ' - ' +
                            getTimeFormatted(
                                surveyResponse.createdAt.toLocal())),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  if (_userIsAdmin | _userCanAccessUpdateSurvey) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => SurveyEditView(
                              title: widget.survey.name,
                              survey: widget.survey,
                              surveyResponseJson: surveyResponse.structure,
                              surveyResponse: surveyResponse,
                              caseInstance: widget.caseInstance,
                              epsState: widget.epsState,
                            )));
                  } else {
                    widget.epsState.showFlashBasic(
                      context,
                      localizationUnauthorized,
                    );
                  }
                },
              ),
              // Archive
              // SizedBox(
              //   width: 20.0,
              //   child: IconButton(
              //     icon: Icon(Icons.delete),
              //     onPressed: () {
              //       if (_userIsAdmin | _userCanAccessDeleteSurvey) {
              //         confirmArchiveDialog(context, surveyResponse);
              //       } else {
              //         widget.epsState.showFlashBasic(
              //           context,
              //           localizationUnauthorized,
              //         );
              //       }
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: widgets,
    );
  }

  String getDateFormatted(DateTime dateTime) {
    return new DateFormat("dd-MM-yyyy").format(dateTime);
  }

  String getTimeFormatted(DateTime dateTime) {
    return new DateFormat("hh:mm:ss").format(dateTime);
  }

  Future<void> confirmArchiveDialog(
      BuildContext context, SurveyResponse surveyResponse) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizationArchiveResponseQuestionTitel),
          content: Text(localizationAreYouSureYouWantToArchiveThisResponse),
          actions: <Widget>[
            FlatButton(
              child: Text(localizationCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(localizationOk),
              onPressed: () {
                archiveResponse(context, surveyResponse);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void archiveResponse(
    BuildContext context,
    SurveyResponse surveyResponse,
  ) async {
    var archiveResponse = new SurveyResponseArchive(widget.epsState);
    var result = await archiveResponse.archiveResponse(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
        widget.survey,
        surveyResponse,
        true);
    if (result.item1) {
      surveyResponse.isArchived = true;
      setState(() {
        widget.surveyResponses.remove(surveyResponse);
      });
    } else {
      // show error
      showFlashBasic(localizationErrorArchivingResponse);
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
