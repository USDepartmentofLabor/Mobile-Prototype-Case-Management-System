import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomNumberWidget extends StatefulWidget {
  CustomNumberWidget({
    Key key,
    this.labelText,
    this.padding,
    this.initialValue,
    this.enforcesValidationCanNotBeBlank,
    this.localizationThisIsNotANumber,
  }) : super(key: key);

  final String labelText;
  final EdgeInsetsGeometry padding;
  final double initialValue;
  final bool enforcesValidationCanNotBeBlank;

  // Localizations
  final String localizationThisIsNotANumber;

  final _CustomNumberWidgetState _widgetState = new _CustomNumberWidgetState();

  @override
  _CustomNumberWidgetState createState() {
    return getState();
  }

  _CustomNumberWidgetState getState() {
    return _widgetState;
  }

  double getValue() {
    return getState()._getValue();
  }
}

class _CustomNumberWidgetState extends State<CustomNumberWidget> {
  TextEditingController _textEditingController;
  bool _showErrorText = false;
  String _errorText = '';

  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    if (widget.initialValue != null) {
      _textEditingController.text = widget.initialValue.toString();
    }
    _handleOnChanged(_textEditingController.text);
  }

  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: TextField(
        controller: _textEditingController,
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          //signed: true,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          errorText: _showErrorText ? _errorText : null,
        ),
        onChanged: (_) {
          _handleOnChanged(_);
        },
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[-0123456789.]'))
        ],
      ),
    );
  }

  void _handleOnChanged(String newValue) {
    var valueIsNumber = double.tryParse(newValue) != null;

    if (valueIsNumber == false) {
      setState(() {
        _showErrorText = true;
        _errorText = widget.localizationThisIsNotANumber;
      });
    } else {
      setState(() {
        _showErrorText = false;
        _errorText = '';
      });
    }
  }

  double _getValue() {
    var value = _textEditingController.text;
    if (double.tryParse(value) != null) {
      return double.parse(value);
    } else {
      return null;
    }
  }
}
