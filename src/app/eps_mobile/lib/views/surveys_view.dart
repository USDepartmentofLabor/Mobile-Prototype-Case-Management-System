import 'package:connectivity/connectivity.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/models/survey.dart';
import 'package:eps_mobile/queries/survey_queries.dart';
import 'package:eps_mobile/queries/survey_response_queries.dart';
import 'package:eps_mobile/service_helpers/check_connectivity.dart';
import 'package:eps_mobile/sync/full_sync.dart';
import 'package:eps_mobile/views/survey_edit_view.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:eps_mobile/views/survey_responses_list_view.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SurveysView extends StatefulWidget {
  SurveysView({Key key, this.title, this.buildMainDrawer, this.epsState})
      : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _SurveysViewState createState() => _SurveysViewState();
}

class _SurveysViewState extends State<SurveysView> {
  List<Survey> surveys;
  bool _userIsAdmin = false;
  bool _userCanAccessReadSurvey = false;
  bool _userCanAccessSubmitSurvey = false;

  // localizations
  var localizationUnauthorized = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationUnauthorized =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.UNAUTHORIZED,
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
        this._userCanAccessReadSurvey = _.item2;
        this._userCanAccessSubmitSurvey = _.item3;
      });
    });

    refresh();

    // get surveys
    surveys = new List<Survey>();

    var isOnline = false;

    if (widget.epsState.syncData == true) {
      Connectivity().checkConnectivity().then((result) {
        isOnline = CheckConnectivity.isOnline(result);
      });
    }

    if (isOnline) {
      FullSync.fullSync(widget.epsState).then((result) {
        //if (result.item1 == true) {
        if (result.boolValue == true) {
          SurveyQueries.getAllSurveys(widget.epsState.database.database)
              .then((surveysResult) {
            surveys = surveysResult;
            setState(() {
              surveys = surveysResult;
            });
          });
        } else {
          // TO DO: handle error on sync in this view
        }
      });
    }

    // pull from database
    SurveyQueries.getAllSurveysWithResponseCounts(
      widget.epsState.database.database,
    ).then((surveysResult) {
      setState(() {
        surveys = surveysResult;
      });
    });
  }

  Future<Tuple3<bool, bool, bool>> getLoadData() async {
    return Tuple3<bool, bool, bool>(
      await widget.epsState.userIsAdmin(),
      await widget.epsState.userHasPermission(
        PermissionValues.READ_SURVEY,
      ),
      await widget.epsState.userHasPermission(
        PermissionValues.SUBMIT_SURVEY,
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
          title: Text(this.widget.title),
        ),
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    var widgets = new List<Widget>();

    for (var survey in surveys) {
      widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
          child: Row(
            children: <Widget>[
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(Icons.assignment),
                    ),
                    SizedBox(
                      child: Text(
                        survey.name,
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.55,
                    ),
                  ],
                ),
                onTap: () async {
                  await showSurveyResponsesList(context, survey);
                },
              ),

              // count
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      child: Text(
                        '( ' + survey.responseCount.toString() + ' )',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.15,
                    ),
                  ],
                ),
                onTap: () async {
                  if (_userIsAdmin | _userCanAccessReadSurvey) {
                    await showSurveyResponsesList(context, survey);
                  } else {
                    widget.epsState.showFlashBasic(
                      context,
                      localizationUnauthorized,
                    );
                  }
                  //await showSurveyResponsesList(context, survey);
                },
              ),

              // Add
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(Icons.add),
                    ),
                  ],
                ),
                onTap: () {
                  if (_userIsAdmin | _userCanAccessSubmitSurvey) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => SurveyEditView(
                              title: survey.name,
                              survey: survey,
                              surveyResponseJson: {},
                              surveyResponse: null,
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
            ],
          ),
        ),
      );
    }

    return ListView(
      children: widgets,
    );
  }

  Future<void> showSurveyResponsesList(
      BuildContext context, Survey survey) async {
    var responses =
        await SurveyResponseQueries.getSurveyResponsesBySurveyNonArchived(
      widget.epsState.database.database,
      survey,
    );
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => SurveyResponsesListView(
              buildMainDrawer: false,
              epsState: widget.epsState,
              survey: survey,
              surveyResponses: responses,
            )));
  }
}
