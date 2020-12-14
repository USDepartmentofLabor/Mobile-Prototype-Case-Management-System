import 'package:eps_mobile/helpers/connectivity_helper.dart';
import 'package:eps_mobile/models/activity.dart';
import 'package:eps_mobile/models/activity_definition.dart';
import 'package:eps_mobile/models/case_instance.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/queries/activity_queries.dart';
import 'package:eps_mobile/service_helpers/activity_get_all.dart';
import 'package:eps_mobile/views/activity_edit_view.dart';
import 'package:eps_mobile/views/loading_widget.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:flutter/material.dart';

class ActivityCaseListByDefinitionView extends StatefulWidget {
  ActivityCaseListByDefinitionView({
    Key key,
    this.title,
    this.buildMainDrawer,
    this.epsState,
    this.caseInstance,
    this.activityDefinition,
  }) : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final EpsState epsState;
  final CaseInstance caseInstance;
  final ActivityDefinition activityDefinition;

  @override
  _ActivityCaseListByDefinitionViewState createState() =>
      _ActivityCaseListByDefinitionViewState();
}

class _ActivityCaseListByDefinitionViewState
    extends State<ActivityCaseListByDefinitionView> {
  // UI
  bool loading = false;

  // Data
  List<Activity> activities = new List<Activity>();

  Future<void> refresh() async {
    //getLocalizations();

    List<Activity> activities = new List<Activity>();

    var isOnline = await ConnectivityHelper.isOnline();
    var apiIsReachable = await ConnectivityHelper.apiIsReachable(
      widget.epsState.serviceInfo,
    );

    var needToLoadFromLocal = true;

    if (isOnline && apiIsReachable) {
      // Online, check API

      var activitiesGet = await ActivityGetAll.getAll(
        widget.epsState.user.jwtToken,
        widget.epsState.serviceInfo.url,
        widget.epsState.serviceInfo.useHttps,
      );
      if (activitiesGet.item1 == true) {
        for (var actGet in activitiesGet.item3) {
          if (actGet.item1.caseId == widget.caseInstance.id) {
            activities.add(actGet.item1);
          }
        }
      }

      needToLoadFromLocal = false;
    }

    if (needToLoadFromLocal) {
      getLoadData().then(
        (value) {
          setState(() {
            this.activities = value;
          });
        },
      );
    }

    setState(() {
      this.activities = activities;
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

  Future<List<Activity>> getLoadData() async {
    // TO DO: filter
    return await ActivityQueries.getActivitiesByCaseIdAndActivityDefinition(
      widget.epsState.database.database,
      widget.caseInstance.id,
      widget.activityDefinition.id,
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
          title: Text(widget.title),
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
    var widgets = new List<Widget>();
    var caseCount = 0;
    for (var x in this.activities) {
      widgets.add(buildRow(context, x));
      caseCount++;
    }
    if (caseCount == 0) {
      widgets.add(
        Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'No Activities Found',
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

  Widget buildRow(
    BuildContext context,
    Activity activity,
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
                    activity.name.substring(0,
                        activity.name.length > 30 ? 29 : activity.name.length),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 22.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(4.0, 1.0, 1.0, 1.0),
                  child: Text(
                    activity.description.substring(
                        0,
                        activity.description.length > 50
                            ? 49
                            : activity.description.length),
                    overflow: TextOverflow.ellipsis,
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
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => ActivityEditView(
                    title: 'Edit Activity',
                    buildMainDrawer: false,
                    epsState: widget.epsState,
                    caseInstance: widget.caseInstance,
                    isNew: false,
                    activityDefinition: widget.activityDefinition,
                    activity: activity,
                  )));
        },
        onLongPress: () async {
          //
        },
      ),
    );
  }
}
