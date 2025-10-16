import 'package:flutter/material.dart';

extension WidgetsX on List<Widget> {
  List<Widget> expanded() => map((child) => Expanded(child: child)).toList();
}
