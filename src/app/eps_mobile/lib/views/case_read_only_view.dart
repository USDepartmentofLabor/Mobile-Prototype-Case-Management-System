import 'dart:convert';
import 'package:eps_mobile/helpers/connectivity_helper.dart';
import 'package:eps_mobile/custom_fields/helpers/custom_field_helper.dart';
import 'package:eps_mobile/helpers/color_helper.dart';
import 'package:eps_mobile/helpers/datetime_helper.dart';
import 'package:eps_mobile/helpers/file_helper.dart';
import 'package:eps_mobile/models/activity.dart';
import 'package:eps_mobile/models/activity_definition.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/case_definition.dart';
import 'package:eps_mobile/models/case_definition_document.dart';
import 'package:eps_mobile/models/case_file.dart';
import 'package:eps_mobile/models/case_note.dart';
import 'package:eps_mobile/models/case_status.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/survey_response.dart';
import 'package:eps_mobile/models/user.dart';
import 'package:eps_mobile/queries/activity_queries.dart';
import 'package:eps_mobile/queries/case_definition_document_queries.dart';
import 'package:eps_mobile/queries/case_definition_survey_queries.dart';
import 'package:eps_mobile/queries/case_file_queries.dart';
import 'package:eps_mobile/queries/case_note_queries.dart';
import 'package:eps_mobile/queries/case_queries.dart';
import 'package:eps_mobile/queries/case_status_queries.dart';
import 'package:eps_mobile/queries/survey_queries.dart';
import 'package:eps_mobile/queries/survey_response_queries.dart';
import 'package:eps_mobile/queries/user_queries.dart';
import 'package:eps_mobile/service_helpers/activity_definitions_get_all.dart';
import 'package:eps_mobile/service_helpers/activity_get_all.dart';
import 'package:eps_mobile/service_helpers/case_definitions_get.dart';
import 'package:eps_mobile/service_helpers/cases_get_all.dart';
import 'package:eps_mobile/service_helpers/delete_file.dart';
import 'package:eps_mobile/service_helpers/survey_response_get.dart';
import 'package:eps_mobile/service_helpers/surveys_get_all.dart';
import 'package:eps_mobile/service_helpers/upload_document.dart';
import 'package:eps_mobile/service_helpers/users_get_all.dart';
import 'package:eps_mobile/views/activity_case_list_by_definition_view.dart';
import 'package:eps_mobile/views/activity_edit_view.dart';
import 'package:eps_mobile/views/add_file_view.dart';
import 'package:eps_mobile/views/case_edit_view.dart';
import 'package:eps_mobile/views/case_note_edit_view.dart';
import 'package:eps_mobile/views/survey_edit_view.dart';
import 'package:eps_mobile/views/loading_widget.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:eps_mobile/views/select_user_widget.dart';
import 'package:eps_mobile/views/survey_responses_list_view.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class CaseReadOnlyView extends StatefulWidget {
  CaseReadOnlyView(
      {Key key,
      this.title,
      this.contentMessage,
      this.caseDefinition,
      this.caseInstance,
      this.caseStatus,
      this.buildMainDrawer,
      this.epsState})
      : super(key: key);

  final String title;
  final String contentMessage;
  final CaseDefinition caseDefinition;
  final CaseInstance caseInstance;
  final CaseStatus caseStatus;
  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _CaseReadOnlyViewState createState() => _CaseReadOnlyViewState();
}

class _CaseReadOnlyViewState extends State<CaseReadOnlyView> {
  // UI
  bool loading = false;
  bool isOnline;
  bool apiIsReachable;

  // DATA
  var surveyData = new List<Tuple2<Survey, List<SurveyResponse>>>();
  var caseNotes = new List<CaseNote>();
  var userIdNameColors = new List<Tuple3<int, String, String>>();
  var definedDocuments = new List<Tuple2<CaseDefinitionDocument, CaseFile>>();
  var looseCaseFiles = new List<CaseFile>();
  var activityData =
      new Tuple2<List<ActivityDefinition>, List<Activity>>(null, null);

  // Permissions
  var userHasCanAssignCasePermission = true;

  // localizations
  var localizationEdit = '';
  var localizationName = '';
  var localizationStatus = '';
  var localizationDescription = '';
  var localizationSurveys = '';
  var localizationCaseDocuments = '';
  var localizationAttachments = '';
  var localizationAddFile = '';
  var localizationNotes = '';
  var localizationAddNote = '';
  var localizationRequired = '';
  var localizationEditCase = '';
  var localizationAddCaseNote = '';
  var localizationDeleteFileTitle = '';
  var localizationDeleteFileQuestion = '';
  var localizationOk = '';
  var localizationCancel = '';
  var localizationNoDeleteInOffline = '';
  var localizationLoading = '';
  var localizationAssignedTo = '';
  var localizationTapToChangeAssignment = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationEdit =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EDIT,
      );
      localizationName =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NAME,
      );
      localizationStatus =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.STATUS,
      );
      localizationDescription =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DESCRIPTION,
      );
      localizationSurveys =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SURVEYS,
      );
      localizationCaseDocuments =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CASE_DOCUMENTS,
      );
      localizationAttachments =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ATTACHMENTS,
      );
      localizationAddFile =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ADD_FILE,
      );
      localizationNotes =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NOTES,
      );
      localizationAddNote =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ADD_NOTE,
      );
      localizationRequired =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.REQUIRED,
      );
      localizationEditCase =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.EDIT_CASE,
      );
      localizationAddCaseNote =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ADD_CASE_NOTE,
      );
      localizationDeleteFileTitle =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DELETE_FILE_QUESTION_TITLE,
      );
      localizationDeleteFileQuestion =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DELETE_FILE_QUESTION,
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
      localizationNoDeleteInOffline =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CAN_NOT_DELETE_IN_OFFLINE_MODE,
      );
      localizationLoading =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.LOADING,
      );
      localizationAssignedTo =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ASSIGNED_TO,
      );
      localizationTapToChangeAssignment =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.TAP_TO_CHANGE_ASSIGNMENT,
      );
    });
  }

  Future<void> newRefresh() async {
    getLocalizations();

    var surveyData = new List<Tuple2<Survey, List<SurveyResponse>>>();
    var caseNotes = new List<CaseNote>();
    var userIdNameColors = new List<Tuple3<int, String, String>>();
    var definedDocuments = new List<Tuple2<CaseDefinitionDocument, CaseFile>>();
    var looseCaseFiles = new List<CaseFile>();
    var activityData =
        new Tuple2<List<ActivityDefinition>, List<Activity>>(null, null);

    // Permissions
    //var userHasCanAssignCasePermission = true;
    //var userIsAdmin = await widget.epsState.userIsAdmin();
    // var userHasCanAssignCasePermission =
    //     await widget.epsState.userHasPermission(
    //   PermissionValues.ASSIGN_TO_CASE,
    // );

    var isOnline = await ConnectivityHelper.isOnline();
    var apiIsReachable = await ConnectivityHelper.apiIsReachable(
      widget.epsState.serviceInfo,
    );

    setState(() {
      this.isOnline = isOnline;
      this.apiIsReachable = apiIsReachable;
    });

    var needToLoadFromLocal = true;

    if (isOnline && apiIsReachable) {
      // Online, check API

      // case
      //Case thisCaseInstance;
      List<CaseFile> caseFiles;
      var caseGet = await CasesGetAll(widget.epsState).getAllCases(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
        widget.caseInstance.caseDefinitionId,
      );
      if (caseGet.item1 == true) {
        for (var caseInstanceGet in caseGet.item2) {
          if (caseInstanceGet.item1.id == widget.caseInstance.id) {
            //thisCaseInstance = caseInstanceGet.item1;
            caseNotes = caseInstanceGet.item2;
            caseFiles = caseInstanceGet.item3;
          }
        }
      }

      // surveyData
      var surveyIds = List<int>();
      var surveysGet = await SurveysGetAll(
        widget.epsState,
      ).getAllSurveys(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
      );
      if (surveysGet.item1 == true) {
        for (var survey in surveysGet.item2) {
          if (surveyIds.contains(survey.id)) {
            var responses = List<SurveyResponse>();

            var responsesGet = await SurveyResponseGet.getAllBySurveyId(
              widget.epsState.user.jwtToken,
              widget.epsState.serviceInfo.url,
              widget.epsState.serviceInfo.useHttps,
              survey.id,
            );
            if (responsesGet.item1 == true) {
              surveyData.add(Tuple2<Survey, List<SurveyResponse>>(
                survey,
                responses,
              ));
            }
          }
        }
      }

      // userIdNameColors = new List<Tuple3<int, String, String>>();
      var usersGet = await UsersGetAll(widget.epsState).getAllUsers(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
      );
      if (usersGet.item1 == true) {
        for (var userGet in usersGet.item3) {
          userIdNameColors.add(
            Tuple3<int, String, String>(
              userGet.id,
              userGet.name,
              userGet.color,
            ),
          );
        }
      }

      // definedDocuments = new List<Tuple2<CaseDefinitionDocument, CaseFile>>();
      List<CaseDefinitionDocument> caseDefDocs = List<CaseDefinitionDocument>();
      var caseDefGet =
          await CaseDefinitionsGet(widget.epsState).getCaseDefinitions(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
      );
      if (caseDefGet.item1 == true) {
        for (var caseDef in caseDefGet.item2) {
          if (caseDef.id == widget.caseDefinition.id) {
            if (caseDef.documents != null) {
              caseDefDocs.addAll(caseDef.documents);
            }
          }
        }
      }

      // match up the files to the doc definitions
      var definedDocuments =
          new List<Tuple2<CaseDefinitionDocument, CaseFile>>();
      //var looseCaseFiles = new List<CaseFile>();
      for (var caseDefinitionDocument in caseDefDocs) {
        CaseFile caseFile;
        var searchResult =
            caseFiles.where((x) => x.documentId == caseDefinitionDocument.id);
        if (searchResult.length == 1) {
          caseFile = searchResult.first;
        }
        definedDocuments.add(new Tuple2<CaseDefinitionDocument, CaseFile>(
          caseDefinitionDocument,
          caseFile,
        ));
      }
      for (var caseFile in caseFiles) {
        if (caseFile.documentId == null) {
          looseCaseFiles.add(caseFile);
        }
      }

      // activityData
      // Tuple2<List<ActivityDefinition>, List<Activity>>
      List<ActivityDefinition> actDefs = List<ActivityDefinition>();
      var activityDefinitionsGet = await ActivityDefinitionsGetAll.getAll(
        widget.epsState.user.jwtToken,
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
      );
      if (activityDefinitionsGet.item1 == true) {
        for (var actDef in activityDefinitionsGet.item3) {
          if (actDef.caseDefinitionId == widget.caseDefinition.id) {
            actDefs.add(actDef);
          }
        }
      }
      List<Activity> acts = List<Activity>();
      var activitiesGet = await ActivityGetAll.getAll(
        widget.epsState.user.jwtToken,
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
      );
      if (activitiesGet.item1 == true) {
        for (var actGet in activitiesGet.item3) {
          if (actGet.item1.caseId == widget.caseInstance.id) {
            acts.add(actGet.item1);
          }
        }
      }

      activityData = Tuple2<List<ActivityDefinition>, List<Activity>>(
        actDefs,
        acts,
      );

      needToLoadFromLocal = false;
    }

    if (needToLoadFromLocal) {
      refresh();
    }

    setState(() {
      this.userHasCanAssignCasePermission = true;
      this.surveyData = surveyData;
      this.caseNotes = caseNotes;
      this.userIdNameColors = userIdNameColors;
      this.definedDocuments = definedDocuments;
      this.looseCaseFiles = looseCaseFiles;
      this.activityData = activityData;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    if (widget.epsState != null) {
      newRefresh().then((value) {
        setState(() {
          loading = false;
        });
      });
    }
  }

  void refresh() {
    setState(() {
      getLocalizations();
    });
    getData();
  }

  void getData() {
    this.getLoadData().then((result) {
      setState(() {
        this.caseNotes = result.item1;
        this.surveyData = result.item2;
        this.userIdNameColors = result.item3;
        this.definedDocuments = result.item4;
        this.looseCaseFiles = result.item5;
        this.activityData = result.item6.first;
      });
    });
  }

  Future<
          Tuple6<
              List<CaseNote>,
              List<Tuple2<Survey, List<SurveyResponse>>>,
              List<Tuple3<int, String, String>>,
              List<Tuple2<CaseDefinitionDocument, CaseFile>>,
              List<CaseFile>,
              List<Tuple2<List<ActivityDefinition>, List<Activity>>>>>
      getLoadData() async {
    var rtn = new Tuple6<
        List<CaseNote>,
        List<Tuple2<Survey, List<SurveyResponse>>>,
        List<Tuple3<int, String, String>>,
        List<Tuple2<CaseDefinitionDocument, CaseFile>>,
        List<CaseFile>,
        List<Tuple2<List<ActivityDefinition>, List<Activity>>>>(
      List<CaseNote>(),
      List<Tuple2<Survey, List<SurveyResponse>>>(),
      List<Tuple3<int, String, String>>(),
      List<Tuple2<CaseDefinitionDocument, CaseFile>>(),
      List<CaseFile>(),
      List<Tuple2<List<ActivityDefinition>, List<Activity>>>(),
    );

    // get survey data
    var caseDefinitionSurveys = await CaseDefinitionSurveyQueries
        .getCaseDefinitionSurveysByCaseDefinition(
      widget.epsState.database.database,
      widget.caseDefinition,
    );
    for (var caseDefinitionSurvey in caseDefinitionSurveys) {
      var survey = await SurveyQueries.getSurveyBySurveyId(
        widget.epsState.database.database,
        caseDefinitionSurvey.surveyId,
      );
      var surveyResponses =
          await SurveyResponseQueries.getSurveyResponsesBySurveyIdByCaseId(
        widget.epsState.database.database,
        survey.id,
        widget.caseInstance.id,
      );
      rtn.item2.add(
          new Tuple2<Survey, List<SurveyResponse>>(survey, surveyResponses));
    }

    // get case notes
    var caseNotesServer = await CaseNoteQueries.getCaseNotesByCase(
      widget.epsState.database.database,
      widget.caseInstance,
    );
    var caseNotesLocal = await CaseNoteQueries.getLocalCaseNotesByCase(
      widget.epsState.database.database,
      widget.caseInstance,
    );
    rtn.item1.addAll(caseNotesServer);
    rtn.item1.addAll(caseNotesLocal);

    // get case files
    var caseFiles = new List<CaseFile>();
    var caseFilesServer = await CaseFileQueries.getCaseFilesByCase(
      widget.epsState.database.database,
      widget.caseInstance,
    );
    var caseFilesLocal = await CaseFileQueries.getLocalCaseFilesByCase(
      widget.epsState.database.database,
      widget.caseInstance,
    );
    caseFiles.addAll(caseFilesServer);
    caseFiles.addAll(caseFilesLocal);

    // get usernames
    var users = await UserQueries.getAllUsers(
      widget.epsState.database.database,
    );
    for (var user in users) {
      rtn.item3.add(
        new Tuple3<int, String, String>(
          user.id,
          user.username,
          user.color,
        ),
      );
    }

    // case definition documents
    var caseDefinitionDocuments = await CaseDefinitionDocumentQueries
        .getCaseDefinitionDocumentsByCaseDefinitionId(
      widget.epsState.database.database,
      widget.caseDefinition.id,
    );

    // match up the files to the doc definitions
    var definedDocuments = new List<Tuple2<CaseDefinitionDocument, CaseFile>>();
    var looseCaseFiles = new List<CaseFile>();
    for (var caseDefinitionDocument in caseDefinitionDocuments) {
      CaseFile caseFile;
      var searchResult =
          caseFiles.where((x) => x.documentId == caseDefinitionDocument.id);
      if (searchResult.length == 1) {
        caseFile = searchResult.first;
      }
      definedDocuments.add(new Tuple2<CaseDefinitionDocument, CaseFile>(
        caseDefinitionDocument,
        caseFile,
      ));
    }
    for (var caseFile in caseFiles) {
      if (caseFile.documentId == null) {
        looseCaseFiles.add(caseFile);
      }
    }
    rtn.item4.addAll(definedDocuments);
    rtn.item5.addAll(looseCaseFiles);

    // acivity
    var activityData =
        await ActivityQueries.getActivitiesAndDefinitionsByCaseIdIncludeZero(
      widget.epsState.database.database,
      widget.caseInstance.id,
      widget.caseDefinition.id,
    );

    rtn.item6.add(activityData);

    return rtn;
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
        //body: buildBody(context),
        body: this.loading
            ? LoadingWidget.buildLoading(
                context,
                '',
              )
            : buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    // survey list widget
    var surveyListTiles = new List<Widget>(surveyData.length);
    int i = 0;
    for (var survey in surveyData) {
      surveyListTiles[i] = ListTile(
        title: Text(
            '(' + survey.item2.length.toString() + ')   ' + survey.item1.name),
        leading: Icon(Icons.list),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => SurveyEditView(
                        title: survey.item1.name,
                        survey: survey.item1,
                        surveyResponseJson: {},
                        surveyResponse: null,
                        caseInstance: widget.caseInstance,
                        epsState: widget.epsState,
                      )))
              // .then((value) {
              //   this.getData();
              // })
              ;
        },
        onLongPress: () {
          Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => SurveyResponsesListView(
                        buildMainDrawer: false,
                        epsState: widget.epsState,
                        survey: survey.item1,
                        surveyResponses: survey.item2,
                      )))
              // .then((value) {
              //   this.getData();
              // })
              ;
        },
      );
      i++;
    }
    var surveyListTileWidget = Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: surveyListTiles,
        ).toList(),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );

    // activity definitions list
    var activityListTiles = new List<Widget>(activityData.item1.length);
    // TO DO: get count in query
    i = 0;
    for (var object in activityData.item1) {
      var count = 0;
      for (var item in activityData.item2) {
        if (item.activityDefinitionId == object.id) {
          count++;
        }
      }
      activityListTiles[i] = ListTile(
        title: Text('(' + count.toString() + ')   ' + object.name),
        leading: Icon(Icons.list),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (BuildContext context) => ActivityEditView(
                        title: object.name,
                        buildMainDrawer: false,
                        epsState: widget.epsState,
                        caseInstance: widget.caseInstance,
                        isNew: true,
                        activityDefinition: object,
                        activity: null,
                      )))
              .then((value) {
            newRefresh().then((value) {
              setState(() {
                loading = false;
              });
            });
          });
        },
        onLongPress: () {
          Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ActivityCaseListByDefinitionView(
                        title: object.name + ' Activities',
                        buildMainDrawer: false,
                        epsState: widget.epsState,
                        caseInstance: widget.caseInstance,
                        activityDefinition: object,
                      )))
              // .then((value) {
              //   this.getData();
              // })
              ;
        },
      );
      i++;
    }
    var activityListTileWidget = Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: activityListTiles,
        ).toList(),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );

    var widgets = List<Widget>();

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: RaisedButton(
        child: Text(localizationEdit),
        onPressed: () async {
          var caseStatus = await CaseStatusQueries.getCaseStatusById(
            widget.epsState.database.database,
            widget.caseInstance.caseStatusId,
          );
          this.showCaseEditInDialog(context, caseStatus);
        },
      ),
    ));

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        widget.caseInstance.key,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 18.0,
        ),
      ),
    ));

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        localizationName + ':',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    ));

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        widget.caseInstance.name,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 26.0,
        ),
      ),
    ));

    // description
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        localizationDescription + ':',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    ));

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        widget.caseInstance.description == null
            ? ''
            : widget.caseInstance.description,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
    ));

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        localizationStatus + ':',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    ));

    widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: Padding(
          padding: EdgeInsets.only(
            left: 0.0,
            right: 0.0,
          ),
          child: Container(
            margin: EdgeInsets.all(0),
            width: MediaQuery.of(context).size.width * 0.8,
            height: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20)),
              child: Container(
                color:
                    ColorHelper.getColorFromHexString(widget.caseStatus.color),
                child: Text(widget.caseStatus.name),
                alignment: Alignment.center,
              ),
            ),
          ),
        )));

    // assigned user
    Tuple3<int, String, String> assignedUser = Tuple3<int, String, String>(
      -1,
      'Unassigned',
      'grey',
    );
    if (widget.caseInstance.assignedTo != -1) {
      assignedUser = userIdNameColors
          .where((element) => element.item1 == widget.caseInstance.assignedTo)
          .first;
    }

    var assignedToText = localizationAssignedTo;
    if (this.userHasCanAssignCasePermission) {
      assignedToText += ' (' + localizationTapToChangeAssignment + ')';
    }
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        //'Assigned To' + ': (tap to change assignment)',
        assignedToText,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    ));

    widgets.add(
      GestureDetector(
        child: Row(
          children: [
            Icon(
              Icons.account_circle,
              color: ColorHelper.getColor(assignedUser.item3),
            ),
            Text(' ' + assignedUser.item2.toString()),
          ],
        ),
        onTap: () async {
          if (this.userHasCanAssignCasePermission) {
            var user = await showSelectUserDialog(context);
            if (user != null) {
              if (widget.caseInstance.assignedTo != user.id) {
                widget.caseInstance.assignedTo = user.id;
                widget.caseInstance.updatedBy = widget.epsState.user.id;
                widget.caseInstance.updatedAt = DateTime.now().toUtc();
                CaseQueries.insertCase(
                  widget.epsState.database.database,
                  widget.caseInstance,
                );
                newRefresh().then((value) {
                  setState(() {
                    loading = false;
                  });
                });
              }
            }
          }
        },
      ),
    );

    // creator
    var createdUser = userIdNameColors
        .where((element) => element.item1 == widget.caseInstance.createdBy)
        .first;

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        'Created By' + ':',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    ));

    widgets.add(
      Row(
        children: [
          Icon(
            Icons.account_circle,
            color: ColorHelper.getColor(createdUser.item3),
          ),
          Text(' ' + createdUser.item2.toString()),
        ],
      ),
    );

    // Custom Fields
    var customFieldDatas = json.decode(widget.caseInstance.customFieldData);
    for (var customFieldData in customFieldDatas['data']) {
      widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: Text(
          customFieldData['name'] + ':',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ));
      var value = customFieldData['value'];
      if (value != null) {
        var value = CustomFieldHelper.getDisplayValue(
          customFieldData['field_type'],
          customFieldData['value'],
          customFieldData['selections'],
        );
        widgets.add(Padding(
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ));
      }
    }

    if (activityListTiles.length > 0) {
      widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: Text(
          'Activities' + ':',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ));

      widgets.add(activityListTileWidget);
    }

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        'Forms' + ':',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    ));

    widgets.add(surveyListTileWidget);

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        localizationCaseDocuments + ':',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    ));

    widgets.add(buildCaseFiles(
      context,
    ));

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        localizationAttachments + ':',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    ));

    widgets.add(buildLooseCaseFiles(
      context,
    ));

    if (isOnline && apiIsReachable) {
      widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: RaisedButton(
          child: Text(localizationAddFile),
          onPressed: () async {
            await showAddFileDialog(
              context,
              widget.caseInstance,
              null,
            );
          },
        ),
      ));
    }

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Text(
        localizationNotes + ':',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    ));

    widgets.add(buildCaseNotes(context));

    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: RaisedButton(
        child: Text(localizationAddNote),
        onPressed: () async {
          showAddCaseNoteDialog(context);
        },
      ),
    ));

    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: ListView(
        children: widgets,
      ),
    );
  }

  Widget buildCaseNotes(BuildContext context) {
    var caseNoteTiles = new List<Widget>(caseNotes.length);
    int i = 0;
    for (var caseNote in caseNotes) {
      var user =
          userIdNameColors.where((x) => x.item1 == caseNote.createdBy).first;
      var username = user.item2;
      var color = user.item3;

      caseNoteTiles[i] = ListTile(
        title: RichText(
          text: TextSpan(
              text: caseNote.note + '\n\n',
              style: TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text: '\n' +
                      DateTimeHelper.getUpdatedAtDisplay(caseNote.updatedAt),
                ),
              ]),
        ),
        leading: Icon(
          Icons.account_circle,
          color: ColorHelper.getColor(color),
        ),
      );
      i++;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: caseNoteTiles,
        ).toList(),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  Widget buildCaseFiles(BuildContext context) {
    var caseFileTiles = new List<Widget>(definedDocuments.length);
    int i = 0;
    for (var data in definedDocuments) {
      // defined case document
      if (data.item2 != null) {
        // has file already
        var requiredText = '';
        if (data.item1.isRequired) {
          requiredText = ' (' + localizationRequired + ')';
        }
        caseFileTiles[i] = ListTile(
          title: RichText(
            text: TextSpan(
                text: data.item1.name +
                    requiredText +
                    '\n' +
                    data.item2.originalFileName,
                style: TextStyle(
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: '', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: '',
                  ),
                ]),
          ),
          trailing: RaisedButton(
            child: Icon(Icons.delete),
            onPressed: () async {
              await confirmDeleteFile(
                context,
                widget.caseInstance,
                data.item1,
                data.item2,
              );
            },
          ),
          leading: Icon(Icons.check_box),
        );
      } else {
        // no document provided yet
        var requiredText = '';
        if (data.item1.isRequired) {
          requiredText = ' (' + localizationRequired + ')';
        }
        caseFileTiles[i] = ListTile(
          title: RichText(
            text: TextSpan(
                text: data.item1.name + requiredText,
                style: TextStyle(
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: '', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: '',
                  ),
                ]),
          ),
          trailing: RaisedButton(
            child: Icon(Icons.file_upload),
            onPressed: () async {
              await showAddFileDialog(
                context,
                widget.caseInstance,
                data.item1,
              );
            },
          ),
          leading: Icon(Icons.check_box_outline_blank),
        );
      }
      i++;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: caseFileTiles,
        ).toList(),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  Widget buildLooseCaseFiles(BuildContext context) {
    var caseFileTiles = new List<Widget>(looseCaseFiles.length);
    int i = 0;
    for (var data in looseCaseFiles) {
      caseFileTiles[i] = ListTile(
        title: RichText(
          text: TextSpan(
              text: data.originalFileName,
              style: TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: '', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text: '',
                ),
              ]),
        ),
        trailing: RaisedButton(
          child: Icon(Icons.delete),
          onPressed: () async {
            await confirmDeleteFile(
              context,
              widget.caseInstance,
              null,
              data,
            );
          },
        ),
        leading: Icon(Icons.attach_file),
      );
      i++;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: caseFileTiles,
        ).toList(),
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );
  }

  Future<User> showSelectUserDialog(
    BuildContext context,
  ) async {
    var selectWidget = SelectUserWidget(
      epsState: widget.epsState,
      getUserWithThesePermissions: [
        PermissionValues.ASSIGNABLE_TO_CASE,
        PermissionValues.ADMIN,
      ],
      allowUnassigned: true,
    );

    await showDialog(
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
              child: selectWidget,
            );
          },
        ),
      ),
    );
    return selectWidget.getState().selectedUser;
  }

  void showCaseEditInDialog(BuildContext context, CaseStatus caseStatus) {
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
                    child: CaseEditView(
                      title: localizationEditCase,
                      buildMainDrawer: false,
                      epsState: widget.epsState,
                      caseDefinition: null,
                      caseInstance: widget.caseInstance,
                      caseStatus: caseStatus,
                      isNew: false,
                    ),
                  );
                },
              ),
            ));
  }

  void showAddCaseNoteDialog(
    BuildContext context,
  ) {
    var noteWidget = CaseNoteEditView(
      title: localizationAddCaseNote,
      buildMainDrawer: false,
      epsState: widget.epsState,
      isNew: true,
      caseInstance: widget.caseInstance,
      caseNote: null,
    );

    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(1.0),
          ),
        ),
        content: Builder(
          builder: (context) {
            var height = MediaQuery.of(context).size.height;
            var width = MediaQuery.of(context).size.width;
            return Container(
              height: height * 0.95,
              width: width * 0.95,
              child: noteWidget,
            );
          },
        ),
      ),
    ).then((_) async {
      if (noteWidget.getWasAddOrEditChange()) {
        newRefresh().then((value) {
          setState(() {
            loading = false;
          });
        });
      }
    });
  }

  Future<void> showAddFileDialog(
    BuildContext context,
    CaseInstance caseInstance,
    CaseDefinitionDocument caseDefinitionDocument,
  ) async {
    var addFileView = AddFileView(
      title: localizationAddFile,
      buildMainDrawer: false,
      epsState: widget.epsState,
    );

    var result = await showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(1.0),
          ),
        ),
        content: Builder(
          builder: (context) {
            var height = MediaQuery.of(context).size.height;
            var width = MediaQuery.of(context).size.width;
            return Container(
              height: height * 0.95,
              width: width * 0.95,
              child: addFileView,
            );
          },
        ),
      ),
    );

    if (result == null) {
      return;
    }

    if (widget.epsState.syncData == true) {
      // online
      var apiCall = await UploadDocument.uploadDocumentAsync(
        widget.epsState,
        caseInstance,
        caseDefinitionDocument,
        result,
      );

      if (apiCall.item1 == true) {
        // add to db
        CaseFileQueries.insertCaseFile(
          widget.epsState.database.database,
          apiCall.item2,
        );
      } else {
        // error in api call
      }
    } else {
      // offline
      // save local

      // object
      var caseFile = CaseFile();
      caseFile.id = -1;
      caseFile.caseId = widget.caseInstance.id;
      caseFile.documentId =
          caseDefinitionDocument == null ? -1 : caseDefinitionDocument.id;
      caseFile.originalFileName = FileHelper.getFileNameFull(result);
      caseFile.remoteFileName = '';
      caseFile.createdAt = DateTime.now().toUtc();
      caseFile.createdBy = widget.epsState.user.id;

      var filename = await FileHelper.writeFile(result);
      caseFile.remoteFileName = filename;

      CaseFileQueries.insertLocalCaseFile(
        widget.epsState.database.database,
        caseFile,
      );
    }

    newRefresh().then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  Future<void> confirmDeleteFile(
    BuildContext context,
    CaseInstance caseInstance,
    CaseDefinitionDocument caseDefinitionDocument,
    CaseFile caseFile,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizationDeleteFileTitle),
          content: Text(localizationDeleteFileQuestion),
          actions: <Widget>[
            FlatButton(
              child: Text(localizationCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(localizationOk),
              onPressed: () async {
                await deleteFile(
                  context,
                  caseInstance,
                  caseDefinitionDocument,
                  caseFile,
                );
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> deleteFile(
    BuildContext context,
    CaseInstance caseInstance,
    CaseDefinitionDocument caseDefinitionDocument,
    CaseFile caseFile,
  ) async {
    if (widget.epsState.syncData == true) {
      // delete
      var apiCall = await DeleteFile.deleteFileAsync(
        widget.epsState,
        caseFile,
      );
      if (apiCall == true) {
        //CaseFileQueries
        CaseFileQueries.delete(
          widget.epsState.database.database,
          caseFile.id,
        );
        newRefresh().then((value) {
          setState(() {
            loading = false;
          });
        });
      } else {
        // error
      }
    } else {
      widget.epsState.showFlashBasic(
        context,
        localizationNoDeleteInOffline,
      );
    }
  }
}
