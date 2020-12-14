import 'package:eps_mobile/custom_fields/models/tuple_bool_int_string.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class CustomCheckBoxWidget extends StatefulWidget {
  CustomCheckBoxWidget({
    Key key,
    this.choices,
    this.initialValues,
    this.labelText,
    this.padding,
    this.enforcesValidationAtLeastOneMustBeSelected,
    this.localizationMustSelectAtLeastOne,
  }) : super(key: key);

  final List<Tuple2<int, String>> choices;
  final List<Tuple2<int, String>> initialValues;
  final String labelText;
  final EdgeInsetsGeometry padding;
  final bool enforcesValidationAtLeastOneMustBeSelected;

  // Localizations
  final String localizationMustSelectAtLeastOne;

  final _CustomCheckBoxWidgetState _widgetState =
      new _CustomCheckBoxWidgetState();

  @override
  _CustomCheckBoxWidgetState createState() {
    return getState();
  }

  _CustomCheckBoxWidgetState getState() {
    return _widgetState;
  }

  dynamic getValue() {
    var rtn = [];
    for (var item
        in _widgetState.choices.where((element) => element.boolValue == true)) {
      rtn.add(item.intValue);
    }
    return rtn;
  }
}

class _CustomCheckBoxWidgetState extends State<CustomCheckBoxWidget> {
  List<TupleBoolIntString> choices;
  bool _showErrorText = false;
  String _errorText = '';

  void initState() {
    super.initState();
    choices = List<TupleBoolIntString>();
    for (var choice in widget.choices) {
      var boolValue = false;
      if (widget.initialValues != null) {
        if (widget.initialValues.contains(choice)) {
          boolValue = true;
        }
      }
      choices.add(TupleBoolIntString(
        boolValue,
        choice.item1,
        choice.item2,
      ));
    }
    _enforceValidationAtLeastOneMustBeSelected();
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
      widgets.add(CheckboxListTile(
        title: Text(value.stringValue),
        value: value.boolValue,
        onChanged: (_) {
          setState(() {
            value.boolValue = _;
            _enforceValidationAtLeastOneMustBeSelected();
          });
        },
      ));
    }

    return Container(
      child: ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: widgets,
      ),
    );
  }

  void _enforceValidationAtLeastOneMustBeSelected() {
    if (widget.enforcesValidationAtLeastOneMustBeSelected != null) {
      if (widget.enforcesValidationAtLeastOneMustBeSelected) {
        var selectedCount =
            this.choices.where((element) => element.boolValue == true).length;
        if (selectedCount == 0) {
          setState(() {
            _showErrorText = true;
            _errorText = widget.localizationMustSelectAtLeastOne;
          });
        } else {
          _showErrorText = false;
          _errorText = '';
        }
      }
    }
  }
}
