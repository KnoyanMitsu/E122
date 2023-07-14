import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final mobileview;
  final desktopview;

  const Responsive(
      {Key? key, required this.mobileview, required this.desktopview})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobileview;
        } else {
          return desktopview;
        }
      }),
    );
  }
}
