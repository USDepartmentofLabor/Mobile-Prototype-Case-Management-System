import 'package:flutter/material.dart';

class CustomTextWidget extends StatefulWidget {
  CustomTextWidget({
    Key key,
    this.initialValue,
    this.labelText,
    this.padding,
    this.enforcesValidationCanNotBeBlank,
    this.enforcesCheckForAllSpaces,
    this.localizationValueCanNotBeBlank,
    this.localizationValueCanNotBeAllSpaces,
  }) : super(key: key);

  final String initialValue;
  final String labelText;
  final EdgeInsetsGeometry padding;
  final bool enforcesValidationCanNotBeBlank;
  final bool enforcesCheckForAllSpaces;

  // Localizations
  final String localizationValueCanNotBeBlank;
  final String localizationValueCanNotBeAllSpaces;

  final _CustomTextWidgetState _customTextWidgetState =
      new _CustomTextWidgetState();

  @override
  _CustomTextWidgetState createState() {
    return getState();
  }

  _CustomTextWidgetState getState() {
    return _customTextWidgetState;
  }

  String getValue() {
    return _customTextWidgetState._textEditingController.text;
  }
}

class _CustomTextWidgetState extends State<CustomTextWidget> {
  TextEditingController _textEditingController;
  bool _showErrorText = false;
  String _errorText = '';

  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    if (widget.initialValue != '') {
      _textEditingController.text = widget.initialValue;
    }
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
        decoration: InputDecoration(
          labelText: widget.labelText,
          errorText: _showErrorText ? _errorText : null,
        ),
        onChanged: (_) {
          handleOnChanged(_);
        },
      ),
    );
  }

  void handleOnChanged(
    String newValue,
  ) {
    var showErrors = false;
    var errorList = List<String>();

    if (widget.enforcesValidationCanNotBeBlank) {
      if (validationCanNotBeBlank(newValue)) {
        showErrors = true;
        errorList.add(
          widget.localizationValueCanNotBeBlank,
        );
      }
    }
    if (widget.enforcesCheckForAllSpaces) {
      if (validationCheckForAllSpaces(newValue)) {
        showErrors = true;
        errorList.add(
          widget.localizationValueCanNotBeAllSpaces,
        );
      }
    }

    var newErrorText = '';
    for (var error in errorList) {
      newErrorText += error;
      if (errorList.indexOf(error) != errorList.length - 1) {
        newErrorText += ', ';
      }
    }

    setState(() {
      _showErrorText = showErrors;
      _errorText = newErrorText;
    });
  }

  // Validation Rules
  bool validationCanNotBeBlank(
    String value,
  ) {
    return value.length == 0;
  }

  bool validationCheckForAllSpaces(
    String value,
  ) {
    var length = value.length;
    var spaceCount = 0;
    value.runes.forEach((int rune) {
      var character = new String.fromCharCode(rune);
      if (character == ' ') {
        spaceCount++;
      }
    });
    if (length > 0) {
      return length == spaceCount;
    }
    return false;
  }
}
