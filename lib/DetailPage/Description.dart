import 'package:flutter/material.dart';

class Description extends StatelessWidget {
  final String descriptions;

  const Description({Key? key, required this.descriptions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 58, 96),
        borderRadius: BorderRadius.circular(5),
      ),
      height: 300,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              descriptions,
              style: const TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
            ),
          ],
        ),
      ),
    );
  }
}
