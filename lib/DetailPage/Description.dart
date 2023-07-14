import 'package:flutter/material.dart';

class Description extends StatelessWidget {
final String descriptions;

  const Description({Key? key, required this.descriptions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return Expanded(
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color.fromRGBO(37, 71, 123, 1),
          ),     
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
          "Description",
          style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1), fontWeight: FontWeight.bold),
        ),
        Text(
          descriptions,
          style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
        ),
        ],
        ) 
      ),
   );
  }
}