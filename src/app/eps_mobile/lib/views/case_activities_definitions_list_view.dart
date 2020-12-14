import 'package:eps_mobile/models/eps_state.dart';
import 'package:flutter/material.dart';

class CaseActivitiesDefinitionsListView extends StatefulWidget {
  CaseActivitiesDefinitionsListView(
      {Key key,
      this.title,
      this.contentMessage,
      this.buildMainDrawer,
      this.epsState})
      : super(key: key);

  final String title;
  final String contentMessage;
  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _CaseActivitiesDefinitionsListViewState createState() =>
      _CaseActivitiesDefinitionsListViewState();
}

class _CaseActivitiesDefinitionsListViewState
    extends State<CaseActivitiesDefinitionsListView> {
  @override
  void initState() {
    super.initState();
    widget.epsState.currentContext = context;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('a'),
        Text('b'),
        Text('c'),
      ],
    );
  }
}
