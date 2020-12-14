import 'package:flutter/material.dart';

class ColorHelper {
  static Color getColor(
    String value,
  ) {
    switch (value) {
      case 'light-green':
        {
          return Colors.lightGreen;
        }
        break;

      case 'light-blue':
        {
          return Colors.lightBlue;
        }
        break;

      case 'blue-grey':
        {
          return Colors.blueGrey;
        }
        break;

      case 'indigo':
        {
          return Colors.indigo;
        }
        break;

      case 'pink':
        {
          return Colors.pink;
        }
        break;

      case 'brown':
        {
          return Colors.brown;
        }
        break;

      case 'grey':
        {
          return Colors.grey;
        }
        break;

      case 'teal':
        {
          return Colors.teal;
        }
        break;

      case 'cyan':
        {
          return Colors.cyan;
        }

      default:
        {
          return Colors.blue;
        }
        break;
    }
  }

  static Color getColorFromHexString(
    String value,
  ) {
    if (value.length != 7) {
      print('error converting color from hex with value: ' + value);
      return Colors.grey;
    }
    return new Color(int.parse(value.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
