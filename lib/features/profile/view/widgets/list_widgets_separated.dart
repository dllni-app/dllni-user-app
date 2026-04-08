import 'package:flutter/material.dart';

extension ListWidgetsSeparated on List<Widget> {
  List<Widget> separatedBy(Widget separator) {
    if (isEmpty) {
      return [];
    }
    final result = <Widget>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}
