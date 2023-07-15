import 'package:flutter/material.dart';
import 'Description.dart';
import 'Artist.dart';

class Info extends StatelessWidget {
  final String description;
  final String artist;

  const Info({Key? key, required this.description, required this.artist})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Artist(artists: artist),
          Description(descriptions: description),
        ],
      ),
    );
  }
}
