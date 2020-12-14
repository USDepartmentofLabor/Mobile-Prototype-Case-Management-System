import 'dart:convert';
import 'package:eps_mobile/helpers/connectivity_helper.dart';
import 'package:eps_mobile/custom_fields/helpers/custom_field_helper.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_check_box_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_date_time_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_number_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_radio_button_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_rank_list_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_select_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_text_area_widget.dart';
import 'package:eps_mobile/custom_fields/widgets/custom_text_widget.dart';
import 'package:eps_mobile/helpers/color_helper.dart';
import 'package:eps_mobile/helpers/datetime_helper.dart';
import 'package:eps_mobile/models/activity.dart';
import 'package:eps_mobile/models/activity_definition.dart';
import 'package:eps_mobile/models/activity_definition_document.dart';
import 'package:eps_mobile/models/activity_file.dart';
import 'package:eps_mobile/models/activity_note.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/custom_field.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/models/survey_response.dart';
import 'package:eps_mobile/models/user.dart';
import 'package:eps_mobile/queries/activity_definition_document_queries.dart';
import 'package:eps_mobile/queries/activity_file_queries.dart';
import 'package:eps_mobile/queries/activity_note_queries.dart';
import 'package:eps_mobile/queries/activity_queries.dart';
import 'package:eps_mobile/queries/user_queries.dart';
import 'package:eps_mobile/service_helpers/activity_add.dart';
import 'package:eps_mobile/service_helpers/activity_definitions_get_all.dart';
import 'package:eps_mobile/service_helpers/activity_edit.dart';
import 'package:eps_mobile/service_helpers/survey_response_get.dart';
import 'package:eps_mobile/service_helpers/surveys_get_all.dart';
import 'package:eps_mobile/views/add_file_view.dart';
import 'package:eps_mobile/views/case_note_edit_view.dart';
import 'package:eps_mobile/views/survey_edit_view.dart';
import 'package:eps_mobile/views/loading_widget.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:eps_mobile/views/survey_responses_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:tuple/tuple.dart';

class ActivityEditView extends StatefulWidget {
  ActivityEditView({
    Key key,
    this.title,
    this.buildMainDrawer,
    this.epsState,
    this.caseInstance,
    this.isNew,
    this.activityDefinition,
    this.activity,
  }) : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final EpsState epsState;

  final CaseInstance caseInstance;
  final bool isNew;
  final ActivityDefinition activityDefinition;
  final Activity activity;

  @override
  _ActivityEditViewState createState() => _ActivityEditViewState();
}

class _ActivityEditViewState extends State<ActivityEditView> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  // UI
  bool loading = false;

  bool isOnline;
  bool apiIsReachable;

  // localizations
  var localizationName = '';
  var localizationDescription = '';
  var localizationSubmit = '';
  var localizationMustSelectAtLeastOne = '';
  var localizationClear = '';
  var localizationPickdate = '';
  var localizationThisIsNotANumber = '';
  var localizationMustMakeASelection = '';
  var localizationAddFile = '';

  // values
  String name = '';
  String description = '';

  ActivityDefinition activityDefinition;
  List<Tuple2<Survey, List<SurveyResponse>>> surveysAndResponses;

  List<Tuple2<CustomField, Widget>> customFields =
      List<Tuple2<CustomField, Widget>>();

  List<User> users = List<User>();

  List<ActivityNote> notes = List<ActivityNote>();
  var definedDocuments =
      new List<Tuple2<ActivityDefinitionDocument, ActivityFile>>();
  var looseCaseFiles = new List<ActivityFile>();

  List<Tuple2<Survey, SurveyResponse>> forms =
      List<Tuple2<Survey, SurveyResponse>>();

  Map newValue;

  void getLocalizations() {
    setState(() {
      localizationName =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NAME,
      );
      localizationDescription =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DESCRIPTION,
      );
      localizationSubmit =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.SUBMIT,
      );
      localizationMustSelectAtLeastOne =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.MUST_SELECT_AT_LEAST_ONE,
      );
      localizationClear =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CLEAR,
      );
      localizationPickdate =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.PICK_DATE,
      );
      localizationThisIsNotANumber =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.THIS_IS_NOT_A_NUMBER,
      );
      localizationMustMakeASelection =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.MUST_MAKE_A_SELECTION,
      );
      localizationAddFile =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ADD_FILE,
      );
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

  Future<void> newRefresh() async {
    getLocalizations();

    // LOCAL SCOPE DATA
    ActivityDefinition activityDefinition;
    List<Tuple2<Survey, List<SurveyResponse>>> surveysAndResponses =
        List<Tuple2<Survey, List<SurveyResponse>>>();

    // Permissions
    //var userIsAdmin = await widget.epsState.userIsAdmin();

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
      // get activity definition
      var activityDefinitionsGet = await ActivityDefinitionsGetAll.getAll(
        widget.epsState.user.jwtToken,
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
      );

      var surveyIds = List<int>();

      if (activityDefinitionsGet.item1 == true) {
        for (var actDef in activityDefinitionsGet.item3) {
          if (actDef.id == widget.activityDefinition.id) {
            activityDefinition = actDef;
            for (var survey in activityDefinition.surveys) {
              surveyIds.add(survey.id);
            }
          }
        }

        // get surveys and responses
        var surveysGet = await SurveysGetAll(
          widget.epsState,
        ).getAllSurveys(
          widget.epsState.serviceInfo.url,
          widget.epsState.serviceInfo.useHttps,
        );
        if (surveysGet.item1 == true) {
          for (var survey in surveysGet.item2) {
            if (surveyIds.contains(survey.id)) {
              if (widget.isNew) {
                surveysAndResponses.add(Tuple2<Survey, List<SurveyResponse>>(
                  survey,
                  List<SurveyResponse>(),
                ));
              } else {
                var responses = List<SurveyResponse>();

                var responsesGet = await SurveyResponseGet.getAllBySurveyId(
                  widget.epsState.user.jwtToken,
                  widget.epsState.serviceInfo.url,
                  widget.epsState.serviceInfo.useHttps,
                  survey.id,
                );
                if (responsesGet.item1 == true) {
                  surveysAndResponses.add(Tuple2<Survey, List<SurveyResponse>>(
                    survey,
                    responses,
                  ));
                }
              }
            }
          }
        }
      }

      needToLoadFromLocal = false;
    }

    if (needToLoadFromLocal) {
      oldRefresh();
    }

    setState(() {
      //this._userIsAdmin = userIsAdmin;
      this.activityDefinition = activityDefinition;
      this.surveysAndResponses = surveysAndResponses;
    });
  }

  void oldRefresh() {
    getLocalizations();

    ActivityNoteQueries.getActivityNotesByActivityServer(
      widget.epsState.database.database,
      widget.activity,
    ).then((value) {
      setState(() {
        notes.addAll(value);
        //serverNotes = value;
      });
    });

    ActivityNoteQueries.getActivityNotesByActivityLocal(
      widget.epsState.database.database,
      widget.activity,
    ).then((value) {
      setState(() {
        notes.addAll(value);
      });
    });

    UserQueries.getAllUsers(widget.epsState.database.database).then((value) {
      setState(() {
        print(value.length.toString());
        this.users = value;
      });
    });

    // files
    ActivityDefinitionDocumentQueries
        .getActivityDefinitionDocumentsByActivityDefinitionId(
      widget.epsState.database.database,
      widget.activityDefinition.id,
    ).then((value) {
      setState(() {
        for (var def in value) {
          this
              .definedDocuments
              .add(Tuple2<ActivityDefinitionDocument, ActivityFile>(
                def,
                null,
              ));
        }
      });
    });

    ActivityFileQueries.getActivityFilesByActivity(
      widget.epsState.database.database,
      widget.activity.id,
    ).then((value) {
      setState(() {
        this.looseCaseFiles = value;
      });
    });

    setState(() {
      customFields = CustomFieldHelper.initCustomFields(
        //widget.activityDefinition.customFieldData,
        widget.isNew
            ? widget.activityDefinition.customFieldData
            : widget.activity.customFieldData,
        localizationMustMakeASelection,
        localizationMustSelectAtLeastOne,
        localizationClear,
        localizationThisIsNotANumber,
        localizationPickdate,
      );
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
          title: Text(widget.title),
        ),
        body: this.loading
            ? LoadingWidget.buildLoading(
                context,
                '',
              )
            : buildBody(context),
        bottomSheet: buildBottomSheet(context),
      ),
    );
  }

  Widget buildBody(
    BuildContext context,
  ) {
    var widgets = new List<Widget>();

    // Title
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Activity - ' + widget.activityDefinition.name,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    ));

    // Name
    var nameInitialValue = '';
    if (widget.activity != null) {
      if (widget.activity.name != null) {
        nameInitialValue = widget.activity.name;
      }
    }
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'name',
        decoration: InputDecoration(labelText: localizationName),
        initialValue: nameInitialValue,
        keyboardType: TextInputType.text,
        autofocus: true,
        onChanged: null,
      ),
    ));

    // Description
    var descriptionInitialValue = '';
    if (widget.activity != null) {
      if (widget.activity.description != null) {
        descriptionInitialValue = widget.activity.description;
      }
    }
    widgets.add(Padding(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: FormBuilderTextField(
        attribute: 'description',
        decoration: InputDecoration(labelText: localizationDescription),
        initialValue: descriptionInitialValue,
        keyboardType: TextInputType.text,
        maxLines: 4,
        onChanged: null,
      ),
    ));

    // Custom Fields
    for (var item in customFields) {
      widgets.add(item.item2);
      widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 25.0),
      ));
    }

    if (!widget.isNew) {
      // Surveys
      widgets.add(Padding(
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          child: Align(
            alignment: Alignment.centerLeft,
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
          )));

      var surveyListTiles = new List<Widget>(this.surveysAndResponses.length);
      int i = 0;
      for (var survey in surveysAndResponses) {
        surveyListTiles[i] = ListTile(
          title: Text('(' +
              survey.item2.length.toString() +
              ')   ' +
              survey.item1.name),
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
                    )));
          },
          onLongPress: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => SurveyResponsesListView(
                      buildMainDrawer: false,
                      epsState: widget.epsState,
                      survey: survey.item1,
                      surveyResponses: survey.item2,
                    )));
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
      widgets.add(
        surveyListTileWidget,
      );

      if (isOnline && apiIsReachable) {
        // Case Documents
        widgets.add(Padding(
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Case Documents' + ':',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        ));

        widgets.add(buildFiles(context));

        // Attachments
        widgets.add(Padding(
            padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Attachments' + ':',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            )));

        // Add File Button
        widgets.add(Padding(
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: RaisedButton(
              child: Text(localizationAddFile),
              onPressed: () async {
                await showAddFileDialog(
                  context,
                  //widget.caseInstance,
                );
              },
            ),
          ),
        ));
      }

      // Notes
      widgets.add(Padding(
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Notes' + ':',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          )));

      if (this.notes != null || this.notes.length > 0) {
        widgets.add(buildNotes(context));
      }

      // Add Note Button
      widgets.add(Padding(
        padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: RaisedButton(
            child: Text('Add Note'),
            onPressed: () async {
              showAddCaseNoteDialog(context);
            },
          ),
        ),
      ));
    }

    // bottom padding
    widgets.add(
      Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 60.0),
        child: null,
      ),
    );

    return ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
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

  Widget buildBottomSheet(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1.0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(5.0, 1.0, 5.0, 1.0),
        child: RaisedButton(
          child: Text(localizationSubmit),
          //onPressed: () => null,
          onPressed: () => onSubmit(context),
        ),
      ),
    );
  }

  void gatherValues() {
    _fbKey.currentState.save();
    var values = _fbKey.currentState.value;
    if (values.containsKey('name')) {
      name = values['name'];
    }
    if (values.containsKey('description')) {
      description = values['description'];
    }
    gatherCustomValues();
  }

  void gatherCustomValues() {
    var customFieldsList = List<CustomField>();
    for (var item in customFields) {
      customFieldsList.add(item.item1);
      switch (item.item1.fieldType) {
        case 'text':
          {
            CustomTextWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'textarea':
          {
            CustomTextAreaWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'select':
          {
            CustomSelectWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'check_box':
          {
            CustomCheckBoxWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'radio_button':
          {
            CustomRadioButtonWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'number':
          {
            CustomNumberWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
        case 'date':
          {
            CustomDateTimeWidget widget = item.item2;
            try {
              item.item1.value =
                  DateTimeHelper.getDateTimeAsYYYYMMDDString(widget.getValue());
            } catch (e) {
              //
            }
          }
          break;
        case 'rank_list':
          {
            CustomRankListWidget widget = item.item2;
            try {
              item.item1.value = widget.getValue();
            } catch (e) {
              //
            }
          }
          break;
      }
    }
    var data = CustomFieldHelper.customFieldToJson(
      customFieldsList,
    );
    newValue = data;
  }

  // SUBMIT
  Future<void> onSubmit(
    BuildContext context,
  ) async {
    gatherValues();

    var success = false;
    if (widget.isNew) {
      success = await addNew();
    } else {
      // EDIT
      success = await editExisting();
    }
    if (success) {
      // close
      Navigator.of(context).pop();
    } else {
      // show error
      widget.epsState.showFlashBasic(
        context,
        'Error',
      );
    }
  }

  Future<void> showAddFileDialog(
    BuildContext context,
  ) async {
    var addFileView = AddFileView(
      title: localizationAddFile,
      buildMainDrawer: false,
      epsState: widget.epsState,
    );

    //var result =
    await showDialog(
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
  }

  void showAddCaseNoteDialog(
    BuildContext context,
  ) {
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
              child: CaseNoteEditView(
                title: 'Add Note',
                buildMainDrawer: false,
                epsState: widget.epsState,
                isNew: true,
                caseInstance: widget.caseInstance,
                caseNote: null,
              ),
            );
          },
        ),
      ),
    ).then((_) async {
      newRefresh().then((value) {
        setState(() {
          loading = false;
        });
      });
    });
  }

  Future<bool> addNew() async {
    var newActivity = Activity();
    newActivity.name = this.name;
    newActivity.description = this.description;
    newActivity.customFieldData = json.encode(newValue);
    newActivity.updatedAt = DateTime.now().toUtc();
    newActivity.updatedBy = widget.epsState.user.id;

    var isOnline = await ConnectivityHelper.isOnline();
    var apiIsReachable = await ConnectivityHelper.apiIsReachable(
      widget.epsState.serviceInfo,
    );

    if (isOnline && apiIsReachable) {
      // online
      var success = await ActivityAdd.add(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
        widget.epsState,
        widget.caseInstance.id,
        widget.activityDefinition.id,
        newActivity,
      );
      if (success.item1 == true) {
        ActivityQueries.insertActivity(
          widget.epsState.database.database,
          newActivity,
        );
        return true;
      } else {
        widget.epsState.showFlashBasic(
          context,
          'error',
        );
      }
    } else {
      // offline
      try {
        newActivity.id = null;
        await ActivityQueries.insertActivityLocal(
          widget.epsState.database.database,
          newActivity,
        );
        return true;
      } catch (e) {
        widget.epsState.showFlashBasic(
          context,
          'error',
        );
      }
    }

    return false;
  }

  Future<bool> editExisting() async {
    widget.activity.name = this.name;
    widget.activity.description = this.description;
    widget.activity.customFieldData = json.encode(newValue);
    widget.activity.updatedAt = DateTime.now().toUtc();
    widget.activity.updatedBy = widget.epsState.user.id;

    var isOnline = await ConnectivityHelper.isOnline();
    var apiIsReachable = await ConnectivityHelper.apiIsReachable(
      widget.epsState.serviceInfo,
    );

    if (isOnline && apiIsReachable) {
      // online
      var success = await ActivityEdit.add(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
        widget.epsState,
        widget.caseInstance,
        widget.activityDefinition,
        widget.activity,
      );
      if (success.item1 == true) {
        ActivityQueries.insertActivity(
          widget.epsState.database.database,
          widget.activity,
        );
        return true;
      } else {
        widget.epsState.showFlashBasic(
          context,
          'error',
        );
      }
    } else {
      // offline
      try {
        await ActivityQueries.insertActivityLocal(
          widget.epsState.database.database,
          widget.activity,
        );
        return true;
      } catch (e) {
        widget.epsState.showFlashBasic(
          context,
          'error',
        );
      }
    }

    return false;
  }

  Widget buildNotes(BuildContext context) {
    var caseNoteTiles = new List<Widget>(notes.length);
    int i = 0;
    for (var note in notes) {
      //var user = User();
      var username = 'UNKN';
      var color = 'Red';
      if (this.users.where((x) => x.id == note.createdBy).first != null) {
        var user = this.users.where((x) => x.id == note.createdBy).first;
        username = user.username;
        color = user.color;
      }

      caseNoteTiles[i] = ListTile(
        title: RichText(
          text: TextSpan(
              text: note.note + '\n\n',
              style: TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: username,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text:
                      '\n' + DateTimeHelper.getUpdatedAtDisplay(note.updatedAt),
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

  Widget buildFiles(BuildContext context) {
    var caseFileTiles = new List<Widget>(definedDocuments.length);
    int i = 0;
    for (var data in definedDocuments) {
      // defined case document
      if (data.item2 != null) {
        // has file already
        var requiredText = '';
        if (data.item1.isRequired) {
          requiredText = ' (' + 'Required' + ')';
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
              // await confirmDeleteFile(
              //   context,
              //   widget.caseInstance,
              //   data.item1,
              //   data.item2,
              // );
            },
          ),
          leading: Icon(Icons.check_box),
        );
      } else {
        // no document provided yet
        var requiredText = '';
        if (data.item1.isRequired) {
          requiredText = ' (' + 'localizationRequired' + ')';
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
              // await showAddFileDialog(
              //   context,
              //   widget.caseInstance,
              //   data.item1,
              // );
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
}
