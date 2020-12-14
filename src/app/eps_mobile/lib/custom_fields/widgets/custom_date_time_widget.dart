import 'package:eps_mobile/helpers/datetime_helper.dart';
import 'package:flutter/material.dart';

class CustomDateTimeWidget extends StatefulWidget {
  CustomDateTimeWidget({
    Key key,
    this.labelText,
    this.padding,
    this.initialValue,
    this.localizationClear,
    this.localizationPickDate,
  }) : super(key: key);

  final String labelText;
  final EdgeInsetsGeometry padding;
  final DateTime initialValue;

  // Localizations
  final String localizationPickDate;
  final String localizationClear;

  final _CustomDateTimeWidgetState _widgetState =
      new _CustomDateTimeWidgetState();

  @override
  _CustomDateTimeWidgetState createState() {
    return getState();
  }

  _CustomDateTimeWidgetState getState() {
    return _widgetState;
  }

  DateTime getValue() {
    return _widgetState._value;
  }
}

class _CustomDateTimeWidgetState extends State<CustomDateTimeWidget> {
  bool _showErrorText = false;
  String _errorText = '';
  DateTime _value;

  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    var display = '';
    if (_value != null) {
      display = DateTimeHelper.getDateTimeAsYYYYMMDDString(_value);
    } else {
      display = '';
    }

    var widgets = List<Widget>();
    widgets.add(
      Padding(
        padding: widget.padding,
        child: Text(
          widget.labelText,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
    if (_showErrorText) {
      widgets.add(
        Padding(
          padding: widget.padding,
          child: Text(
            _errorText,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    widgets.add(
      Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            display,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ),
    );
    widgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              //width: MediaQuery.of(context).size.width * 0.41,
              child: RaisedButton(
                child: Text(widget.localizationPickDate),
                onPressed: () async {
                  var value = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.fromMillisecondsSinceEpoch(0),
                    lastDate: DateTime(3000),
                  );
                  if (value != null) {
                    setState(() {
                      _value = value;
                    });
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: SizedBox(
              //width: MediaQuery.of(context).size.width * 0.41,
              child: RaisedButton(
                child: Text(widget.localizationClear),
                onPressed: () async {
                  setState(() {
                    _value = null;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      child: ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: widgets,
      ),
    );
  }
}
