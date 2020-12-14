import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/views/main_drawer.dart';
import 'package:flutter/material.dart';

class PlaceholderView extends StatefulWidget {
  PlaceholderView(
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
  _PlaceholderViewState createState() => _PlaceholderViewState();
}

class _PlaceholderViewState extends State<PlaceholderView> {
  @override
  void initState() {
    super.initState();
    widget.epsState.currentContext = context;
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
        body: Center(
          child: Text(this.widget.contentMessage),
        ),
      ),
    );
  }
}
