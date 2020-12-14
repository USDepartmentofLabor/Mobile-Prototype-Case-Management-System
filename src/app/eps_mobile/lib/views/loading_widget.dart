import 'package:flutter/material.dart';
import 'package:loading/indicator/line_scale_indicator.dart';
import 'package:loading/loading.dart';

class LoadingWidget {
  static Widget buildLoading(
    BuildContext context,
    String localizationLoading,
  ) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Loading(
                indicator: LineScaleIndicator(),
                size: 100.0,
                color: Colors.blue),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
              child: Text(localizationLoading),
            ),
          ],
        ),
      ),
    );
  }
}
