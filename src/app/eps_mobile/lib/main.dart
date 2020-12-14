import 'package:eps_mobile/models/eps_state.dart';
import 'package:flutter/material.dart';
import 'package:eps_mobile/views/sign_in_view.dart';
import 'package:version_banner/version_banner.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final EpsState epsState;

  const MyApp({Key key, this.epsState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VersionBanner(
        text: '1.0.0',
        color: Colors.lightBlue,
        child: MaterialApp(
          title: 'EPS Mobile',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SignInView(
            title: 'EPS Mobile',
          ),
        ));
  }
}
