import 'package:flutter/material.dart';
import 'package:eps_mobile/models/eps_state.dart';
import 'package:eps_mobile/views/main_drawer.dart';

class TestThingView extends StatefulWidget {
  TestThingView({Key key, this.title, this.buildMainDrawer, this.epsState})
      : super(key: key);

  final String title;
  final bool buildMainDrawer;
  final EpsState epsState;

  @override
  _TestThingViewState createState() => _TestThingViewState();
}

class _TestThingViewState extends State<TestThingView> {
  String displayText = '';

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
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return ListView(
      children: <Widget>[
        Text('Tests'),
        buildButtonClear(context),
        buildButtonTestA(context),
        Divider(
          color: Colors.black,
          height: 5.0,
          thickness: 5.0,
          indent: 5.0,
          endIndent: 5.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Text(
            displayText,
            overflow: TextOverflow.ellipsis,
            maxLines: 100,
          ),
        ),
        Divider(
          color: Colors.black,
          height: 5.0,
          thickness: 5.0,
          indent: 5.0,
          endIndent: 5.0,
        ),
      ],
    );
  }

  Widget buildButtonClear(BuildContext context) {
    return RaisedButton(
      child: Text('Clear'),
      onPressed: () {
        setState(() {
          displayText = '';
        });
      },
    );
  }

  Widget buildButtonTestA(BuildContext context) {
    return RaisedButton(
      child: Text('Test A'),
      onPressed: () async {
        var output = '';

        // START
        output = await test();
        // STOP

        setState(() {
          displayText = output;
        });
      },
    );
  }

  Future<String> test() async {
    return await testTemp();
  }

  Future<String> testTemp() async {
    var rtn = '';

    //

    rtn = 'done';
    return rtn;
  }

  // Future<String> test() async {
  //   return 'test';
  // }

  //
  // Future<String> testTemplate(
  // ) async {
  //   var output = '';
  //   //
  //   return output;
  // }
}
