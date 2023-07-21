import 'package:flutter/material.dart';

class Artist extends StatelessWidget {
  final String artists;

  const Artist({Key? key, required this.artists}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Artist:",
          style: TextStyle(
              color: Color.fromRGBO(135, 182, 255, 1),
              fontWeight: FontWeight.bold),
        ),
        Text(
          artists,
          style: const TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
        ),
      ],
    );
  }
}
