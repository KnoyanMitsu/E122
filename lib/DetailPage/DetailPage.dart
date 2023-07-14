import 'package:flutter/material.dart';
import 'Responsive.dart';
import 'DesktopView.dart';
import 'MobileView.dart';

class DetailPage extends StatefulWidget {
  final String imageId;

  const DetailPage({Key? key, required this.imageId}) : super(key: key);
  @override
  _DetailPage createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  late String imageId;
  @override
  void initState() {
    super.initState();
    imageId = widget.imageId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Responsive(
        desktopview: DesktopView(imageId: imageId),
        mobileview: MobileView(imageId: imageId),
      ),
    );
  }
}
