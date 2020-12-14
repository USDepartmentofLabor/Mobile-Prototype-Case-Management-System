import 'package:eps_mobile/queries/case_definition_queries.dart';
import 'package:eps_mobile/sync/case_definitions_sync.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:eps_mobile/helpers/connectivity_helper.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/case_definition.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/queries/case_queries.dart';
import 'package:eps_mobile/service_helpers/case_definitions_get.dart';
import 'package:eps_mobile/service_helpers/cases_get_all.dart';
import 'package:eps_mobile/views/cases_list_view.dart';
import 'package:eps_mobile/views/loading_widget.dart';
import 'package:eps_mobile/views/main_drawer.dart';

class CaseDefinitionsView extends StatefulWidget {
  CaseDefinitionsView({Key key, this.buildMainDrawer, this.epsState})
      : super(key: key);

  final bool buildMainDrawer;
  final EpsState epsState;

  final _CaseDefinitionsViewState _widgetState =
      new _CaseDefinitionsViewState();

  @override
  _CaseDefinitionsViewState createState() {
    return getState();
  }

  _CaseDefinitionsViewState getState() {
    return _widgetState;
  }
}

class _CaseDefinitionsViewState extends State<CaseDefinitionsView> {
  // UI
  bool loading = false;

  // Data
  List<Tuple2<CaseDefinition, int>> caseDefinitionsAndCounts =
      List<Tuple2<CaseDefinition, int>>();

  // Permissions
  bool _userIsAdmin = false;
  bool _userCanAccessReadCase = false;

  // Localizations
  var localizationUnauthorized = '';
  var localizationCases = '';

  void getLocalizations() {
    setState(() {
      // values for this view
      localizationUnauthorized =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.UNAUTHORIZED,
      );
      localizationCases =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CASES,
      );
    });
  }

  Future<void> refresh() async {
    getLocalizations();

    List<Tuple2<CaseDefinition, int>> caseDefinitionsAndCounts =
        List<Tuple2<CaseDefinition, int>>();

    var userIsAdmin = await widget.epsState.userIsAdmin();
    var userHasReadCase = await widget.epsState.userHasPermission(
      PermissionValues.READ_CASE,
    );

    var isOnline = await ConnectivityHelper.isOnline();
    var apiIsReachable = await ConnectivityHelper.apiIsReachable(
      widget.epsState.serviceInfo,
    );

    var needToLoadFromLocal = true;

    if (isOnline && apiIsReachable) {
      // Online, check API

      var caseDefinitionsResult = await CaseDefinitionsGet(
        widget.epsState,
      ).getCaseDefinitions(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
      );

      if (caseDefinitionsResult.item1 == true) {
        // sync it
        var syncCaseDefs = await CaseDefinitionsSync.syncFromServerList(
          widget.epsState,
          caseDefinitionsResult.item2,
        );
        if (syncCaseDefs.boolValue == false) {
          print('sync error on case definitions refresh');
        }

        // get the counts
        for (var caseDefinition in caseDefinitionsResult.item2) {
          var caseCountResult = await CasesGetAll(widget.epsState).getAllCases(
            widget.epsState.serviceInfo.url,
            widget.epsState.serviceInfo.useHttps,
            caseDefinition.id,
          );
          if (caseCountResult.item1 == true) {
            caseDefinitionsAndCounts.add(Tuple2<CaseDefinition, int>(
              caseDefinition,
              caseCountResult.item2.length,
            ));
          }
        }
      }

      needToLoadFromLocal = false;
    }

    if (needToLoadFromLocal) {
      // Offline or API inaccessible, pull from database
      var localCaseDefinitions =
          await CaseDefinitionQueries.getAllCaseDefinitions(
        widget.epsState.database.database,
      );
      for (var localCaseDef in localCaseDefinitions) {
        var serverCases = await CaseQueries.getCasesByDefinitionIdServerOnly(
          widget.epsState.database.database,
          localCaseDef.id,
        );
        var localCases = await CaseQueries.getCasesByDefinitionIdLocalOnly(
          widget.epsState.database.database,
          localCaseDef.id,
        );
        caseDefinitionsAndCounts.add(Tuple2<CaseDefinition, int>(
          localCaseDef,
          serverCases.length + localCases.length,
        ));
      }
    }

    // Sort by case definition name
    caseDefinitionsAndCounts
        .sort((a, b) => a.item1.name.compareTo(b.item1.name));

    setState(() {
      this._userIsAdmin = userIsAdmin;
      this._userCanAccessReadCase = userHasReadCase;
      this.caseDefinitionsAndCounts = caseDefinitionsAndCounts;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    if (widget.epsState != null) {
      refresh().then((value) {
        setState(() {
          loading = false;
        });
      });
    }
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
          title: Text(this.localizationCases),
        ),
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
    var widgets = new List<Widget>();

    for (var caseDefinition in caseDefinitionsAndCounts) {
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
                        caseDefinition.item1.name,
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.65,
                    ),
                  ],
                ),
                onTap: () {
                  showCasesList(
                    context,
                    caseDefinition.item1,
                  );
                },
              ),

              // count
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      child: Text(
                        '( ' + caseDefinition.item2.toString() + ' )',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.15,
                    ),
                  ],
                ),
                onTap: () {
                  showCasesList(
                    context,
                    caseDefinition.item1,
                  );
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

  Future<void> showCasesList(
    BuildContext context,
    CaseDefinition caseDefinition,
  ) async {
    if (_userIsAdmin | _userCanAccessReadCase) {
      var cases = await CaseQueries.getCasesByDefinitionIdServerOnly(
        widget.epsState.database.database,
        caseDefinition.id,
      );
      await showCaseDefinitionCasesList(
        context,
        caseDefinition,
        cases,
      );
    } else {
      widget.epsState.showFlashBasic(
        context,
        localizationUnauthorized,
      );
    }
  }

  Future<void> showCaseDefinitionCasesList(
    BuildContext context,
    CaseDefinition caseDefinition,
    List<CaseInstance> cases,
  ) async {
    var casesListView = CasesListView(
      buildMainDrawer: false,
      epsState: widget.epsState,
      title: caseDefinition.name + ' ' + localizationCases,
      caseDefinition: caseDefinition,
    );

    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (BuildContext context) => casesListView,
    ))
        .then((value) {
      refresh().then((value) {
        setState(() {
          loading = false;
        });
      });
    });
  }
}
