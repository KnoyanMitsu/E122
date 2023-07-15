import 'package:flutter/material.dart';

class Artist extends StatelessWidget {
final String artists;

  const Artist({Key? key, required this.artists}) : super(key: key);

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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
          "Artist",
          style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1), fontWeight: FontWeight.bold),
        ),
        Text(
          artists,
          style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
        ),
        ],
        ) 
      ),
   );
  }
}