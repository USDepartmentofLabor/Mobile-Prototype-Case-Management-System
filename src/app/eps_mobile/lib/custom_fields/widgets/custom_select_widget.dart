import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class CustomSelectWidget extends StatefulWidget {
  CustomSelectWidget({
    Key key,
    this.initialValue,
    this.labelText,
    this.padding,
    this.values,
    this.enforcesValidationMustMakeSelection,
    this.localizationMustMakeASelection,
  }) : super(key: key);

  final Tuple2<int, String> initialValue;
  final String labelText;
  final EdgeInsetsGeometry padding;
  final List<Tuple2<int, String>> values;
  final bool enforcesValidationMustMakeSelection;

  // Localizations
  final String localizationMustMakeASelection;

  final _CustomSelectWidgetState _widgetState = new _CustomSelectWidgetState();

  @override
  _CustomSelectWidgetState createState() {
    return getState();
  }

  _CustomSelectWidgetState getState() {
    return _widgetState;
  }

  dynamic getValue() {
    var rtn = getState()._selectedValue.item1;
    return rtn;
  }
}

class _CustomSelectWidgetState extends State<CustomSelectWidget> {
  Tuple2<int, String> _selectedValue;
  bool _showErrorText = false;
  String _errorText = '';
  List<DropdownMenuItem> _controlValues;
  List<Tuple2<int, String>> values;

  void initState() {
    super.initState();

    values = List<Tuple2<int, String>>();
    values.add(Tuple2<int, String>(-1, '')); // "null" entry for clear
    values.addAll(widget.values);

    _controlValues = values.map<DropdownMenuItem<Tuple2<int, String>>>(
        (Tuple2<int, String> value) {
      return DropdownMenuItem<Tuple2<int, String>>(
        value: value,
        child: Text(value.item2),
      );
    }).toList();

    if (widget.initialValue == null) {
      _selectedValue = values.first;
    } else {
      _selectedValue = widget.initialValue;
    }

    _selectedValue = widget.initialValue;
    if (widget.enforcesValidationMustMakeSelection != null &&
        widget.enforcesValidationMustMakeSelection) {
      if (_selectedValue == null) {
        _errorText = widget.localizationMustMakeASelection;
        _showErrorText = true;
      }
    }
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: DropdownButtonFormField<Tuple2<int, String>>(
        decoration: InputDecoration(
          labelText: widget.labelText,
          errorText: _showErrorText ? _errorText : null,
        ),
        value: _selectedValue,
        items: _controlValues,
        onChanged: (Tuple2<int, String> newValue) {
          _handleChange(newValue);
        },
      ),
    );
  }

  void _handleChange(
    Tuple2<int, String> newValue,
  ) {
    setState(() {
      _selectedValue = newValue;
    });

    if (widget.enforcesValidationMustMakeSelection) {
      _validationMustMakeSelection();
    }
  }

  void _validationMustMakeSelection() {
    if (_selectedValue == values.first) {
      setState(() {
        _errorText = widget.localizationMustMakeASelection;
        _showErrorText = true;
      });
    } else {
      setState(() {
        _errorText = '';
        _showErrorText = false;
      });
    }
  }
}
