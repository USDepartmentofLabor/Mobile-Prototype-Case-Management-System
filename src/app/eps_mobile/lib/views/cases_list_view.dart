import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eps_mobile/helpers/connectivity_helper.dart';
import 'package:eps_mobile/custom_fields/helpers/custom_field_helper.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/case_definition.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/permission_values.dart';
import 'package:eps_mobile/queries/case_queries.dart';
import 'package:eps_mobile/queries/case_status_queries.dart';
import 'package:eps_mobile/service_helpers/cases_get_all.dart';
import 'package:eps_mobile/views/case_edit_view.dart';
import 'package:eps_mobile/views/case_read_only_view.dart';
import 'package:eps_mobile/views/loading_widget.dart';
import 'package:eps_mobile/views/main_drawer.dart';

class CasesListView extends StatefulWidget {
  CasesListView(
      {Key key,
      this.title,
      this.buildMainDrawer,
      this.caseDefinition,
      this.epsState})
      : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final CaseDefinition caseDefinition;
  final EpsState epsState;

  final _CasesListViewState _widgetState = new _CasesListViewState();

  @override
  _CasesListViewState createState() {
    return getState();
  }

  _CasesListViewState getState() {
    return _widgetState;
  }

  String getSearchText() {
    return _widgetState.searchText;
  }
}

class _CasesListViewState extends State<CasesListView> {
  // UI
  bool loading = false;
  TextEditingController _searchTextEditingController;
  String searchText = '';

  // Data
  //List<Case> cases = List<Case>();
  List<CaseInstance> casesToDisplay = List<CaseInstance>();

  // Permissions
  bool _userIsAdmin = false;
  bool _userCanAccessCreateCase = false;
  bool _userCanAccessUpdateCase = false;

  // localizations
  var localizationAddNewCase = '';
  var localizationNewCase = '';
  var localizationCaseInstance = '';
  var localizationUnauthorized = '';
  var localizationNoCasesFound = '';
  var localizationDeleteCase = '';
  var localizationDeleteCaseAreYouSure = '';
  var localizationYes = '';
  var localizationNo = '';

  void getLocalizations() {
    setState(() {
      localizationAddNewCase =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.ADD_NEW_CASE,
      );
      localizationNewCase =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NEW_CASE,
      );
      localizationCaseInstance =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.CASE_INSTANCE,
      );
      localizationUnauthorized =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.UNAUTHORIZED,
      );
      localizationNoCasesFound =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NO_CASES_FOUND,
      );

      localizationDeleteCase =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DELETE_CASE,
      );
      localizationDeleteCaseAreYouSure =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.DELETE_CASE_ARE_YOU_SURE,
      );
      localizationYes =
          widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.YES,
      );
      localizationNo = widget.epsState.localizationValueHelper.getValueFromEnum(
        widget.epsState.localization,
        LocalizationKeyValues.NO,
      );
    });
  }

  Future<void> refresh() async {
    getLocalizations();

    List<CaseInstance> cases = List<CaseInstance>();

    var userIsAdmin = await widget.epsState.userIsAdmin();
    var userHasReadCase = await widget.epsState.userHasPermission(
      PermissionValues.READ_CASE,
    );
    var userHasUpdateCase = await widget.epsState.userHasPermission(
      PermissionValues.UPDATE_CASE,
    );

    var isOnline = await ConnectivityHelper.isOnline();
    var apiIsReachable = await ConnectivityHelper.apiIsReachable(
      widget.epsState.serviceInfo,
    );

    var needToLoadFromLocal = true;

    if (isOnline && apiIsReachable) {
      // Online, check API

      var caseResult = await CasesGetAll(widget.epsState).getAllCases(
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
        widget.caseDefinition.id,
      );

      if (caseResult.item1 == true) {
        for (var caseInstance in caseResult.item2) {
          cases.add(caseInstance.item1);
        }
      }

      needToLoadFromLocal = false;
    }

    if (needToLoadFromLocal) {
      // Offline or API inaccessible, pull from database

      var serverCases = await CaseQueries.getCasesByDefinitionIdServerOnly(
        widget.epsState.database.database,
        widget.caseDefinition.id,
      );
      var localCases = await CaseQueries.getCasesByDefinitionIdLocalOnly(
        widget.epsState.database.database,
        widget.caseDefinition.id,
      );

      cases.addAll(serverCases);
      cases.addAll(localCases);
    }

    // Sort by case definition name
    cases.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      this._userIsAdmin = userIsAdmin;
      this._userCanAccessCreateCase = userHasReadCase;
      this._userCanAccessUpdateCase = userHasUpdateCase;
      this.casesToDisplay = cases;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    //widget.epsState.currentContext = context;
    _searchTextEditingController = TextEditingController();

    if (widget.epsState != null) {
      refresh().then((value) {
        setState(() {
          loading = false;
        });
      });
    }
  }

  void dispose() {
    _searchTextEditingController.dispose();
    super.dispose();
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
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    var widgets = new List<Widget>();
    if (_userIsAdmin | _userCanAccessCreateCase) {
      widgets.add(buildAddNewCaseRow(context, null));
    }
    widgets.add(
      buildSearchCase(context),
    );
    var caseCount = 0;
    for (var caseInstance in this.casesToDisplay) {
      if (searchText != '') {
        if (search(caseInstance, searchText)) {
          widgets.add(buildCaseRow(context, caseInstance));
          caseCount++;
        }
      } else {
        widgets.add(buildCaseRow(context, caseInstance));
        caseCount++;
      }
    }
    if (caseCount == 0) {
      widgets.add(
        Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              localizationNoCasesFound,
              style: TextStyle(fontSize: 28.0),
            ),
          ),
        ),
      );
    }
    return ListView(
      children: widgets,
    );
  }

  Widget buildAddNewCaseRow(
    BuildContext context,
    CaseDefinition caseDefinition,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
      child: GestureDetector(
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              child: Icon(
                Icons.add,
              ),
            ),
            Text(
              localizationAddNewCase,
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ],
        ),
        onTap: () {
          var newCase = new CaseInstance();
          newCase.caseDefinitionId = widget.caseDefinition.id;
          var copy = CustomFieldHelper.copyCustomFieldsFromCaseDefinition(
            widget.caseDefinition,
            widget.epsState.user.id,
          );
          newCase.customFieldData = json.encode(copy);
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (BuildContext context) => CaseEditView(
                        title: localizationNewCase,
                        buildMainDrawer: false,
                        epsState: widget.epsState,
                        caseDefinition: widget.caseDefinition,
                        caseInstance: newCase,
                        caseStatus: null,
                        isNew: true,
                      )))
              .then((value) {
            refresh().then((value) {
              setState(() {
                loading = false;
              });
            });
          });
        },
      ),
    );
  }

  Widget buildCaseRow(
    BuildContext context,
    CaseInstance caseInstance,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
      child: GestureDetector(
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 1.0),
                  child: Text(
                    caseInstance.name,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 22.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(4.0, 1.0, 1.0, 1.0),
                  child: Text(
                    caseInstance.key,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          if (_userIsAdmin | _userCanAccessUpdateCase) {
            var caseStatus = await CaseStatusQueries.getCaseStatusById(
              widget.epsState.database.database,
              caseInstance.caseStatusId,
            );

            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (BuildContext context) => CaseReadOnlyView(
                          title: localizationCaseInstance,
                          contentMessage: caseInstance.name,
                          caseInstance: caseInstance,
                          caseStatus: caseStatus,
                          caseDefinition: widget.caseDefinition,
                          buildMainDrawer: false,
                          epsState: widget.epsState,
                        )))
                .then((value) {
              refresh().then((value) {
                setState(() {
                  loading = false;
                });
              });
            });
          } else {
            widget.epsState.showFlashBasic(
              context,
              localizationUnauthorized,
            );
          }
        },
        onLongPress: () async {
          // var result = await widget.epsState.booleanDialog(
          //   context,
          //   localizationDeleteCase,
          //   localizationDeleteCaseAreYouSure,
          //   localizationNo,
          //   localizationYes,
          // );
          // if (result) {
          //   // mark for deletion
          //   caseInstance.markForDeletion = true;
          //   CaseQueries.insertCase(
          //     widget.epsState.database.database,
          //     caseInstance,
          //   );
          //   if (widget.epsState.syncData) {
          //     // delete on api
          //     var deleteResult = await CaseDelete.deleteCase(
          //       widget.epsState,
          //       caseInstance.id,
          //     );
          //     if (deleteResult.item1 == false) {
          //       // show error for api delete
          //       widget.epsState.showFlashBasic(
          //         context,
          //         deleteResult.item2,
          //       );
          //     } else {
          //       // api delete successful, so delete locally since we are online
          //       CaseQueries.deleteCase(
          //         widget.epsState.database.database,
          //         caseInstance.id,
          //       );
          //     }
          //   }
          //   // refresh view
          //   var cases = await CaseQueries.getCasesByDefinitionId(
          //     widget.epsState.database.database,
          //     widget.caseDefinition.id,
          //   );
          //   setState(() {
          //     this.casesToDisplay = cases;
          //   });
          // }
        },
      ),
    );
  }

  Widget buildSearchCase(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search,
            size: 40.0,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: TextField(
              controller: _searchTextEditingController,
              decoration: InputDecoration(
                labelText: '',
              ),
              onChanged: (_) {
                setState(() {
                  searchText = _;
                });
              },
            ),
          ),
          GestureDetector(
            child: Icon(
              Icons.highlight_off,
              size: 20.0,
            ),
            onTap: () {
              setState(() {
                _searchTextEditingController.clear();
                searchText = '';
              });
              //refresh();
            },
          ),
        ],
      ),
    );
  }

  bool search(
    CaseInstance caseInstance,
    String searchText,
  ) {
    if (caseInstance.key.toUpperCase().contains(searchText.toUpperCase()) ||
        caseInstance.name.toUpperCase().contains(searchText.toUpperCase())) {
      return true;
    }
    return false;
  }
}
