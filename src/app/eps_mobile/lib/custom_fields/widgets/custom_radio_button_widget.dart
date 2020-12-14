import 'package:eps_mobile/custom_fields/models/tuple_bool_int_string.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class CustomRadioButtonWidget extends StatefulWidget {
  CustomRadioButtonWidget({
    Key key,
    this.choices,
    this.initialValue,
    this.labelText,
    this.padding,
    this.enforcesValidationMustMakeSelection,
    this.localizationClearSelection,
    this.localizationMustMakeASelection,
  }) : super(key: key);

  final List<Tuple2<int, String>> choices;
  final Tuple2<int, String> initialValue;
  final String labelText;
  final EdgeInsetsGeometry padding;
  final bool enforcesValidationMustMakeSelection;

  // Localizatins
  final String localizationClearSelection;
  final String localizationMustMakeASelection;

  final _CustomRadioButtonWidgetState _widgetState =
      new _CustomRadioButtonWidgetState();

  @override
  _CustomRadioButtonWidgetState createState() {
    return getState();
  }

  _CustomRadioButtonWidgetState getState() {
    return _widgetState;
  }

  int getValue() {
    return _widgetState._chosenValue;
  }
}

class _CustomRadioButtonWidgetState extends State<CustomRadioButtonWidget> {
  List<TupleBoolIntString> choices;
  bool _showErrorText = false;
  String _errorText = '';
  int _chosenValue = -1;

  void initState() {
    super.initState();
    choices = List<TupleBoolIntString>();
    for (var choice in widget.choices) {
      var boolValue = false;
      if (widget.initialValue != null) {
        if (choice.item1 == widget.initialValue.item1) {
          boolValue = true;
        }
        _chosenValue = widget.initialValue.item1;
      }
      choices.add(TupleBoolIntString(
        boolValue,
        choice.item1,
        choice.item2,
      ));
    }
    _enforceValidationMustMakeSelection();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    for (var value in choices) {
      widgets.add(
        RadioListTile(
          title: Text(value.stringValue),
          value: value.intValue,
          groupValue: _chosenValue,
          onChanged: (_) {
            setState(() {
              _chosenValue = value.intValue;
              _enforceValidationMustMakeSelection();
            });
          },
        ),
      );
    }

    // Clear Button
    widgets.add(
      Padding(
        padding: EdgeInsets.all(10.0),
        child: RaisedButton(
            child: Text(widget.localizationClearSelection),
            onPressed: () {
              setState(() {
                _chosenValue = -1;
                _enforceValidationMustMakeSelection();
              });
            }),
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

  void _enforceValidationMustMakeSelection() {
    if (widget.enforcesValidationMustMakeSelection != null) {
      if (widget.enforcesValidationMustMakeSelection) {
        if (_chosenValue < 1) {
          setState(() {
            _showErrorText = true;
            _errorText = widget.localizationMustMakeASelection;
          });
        } else {
          setState(() {
            _showErrorText = false;
            _errorText = '';
          });
        }
      }
    }
  }
}
