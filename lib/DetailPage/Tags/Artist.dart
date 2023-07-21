import 'package:flutter/material.dart';
import 'package:scrolling_dulu/DetailPage/Tags/tagspage.dart';
import 'dart:async';

import '../../data/service.dart';

class ListArtist extends StatefulWidget {
  @override
  _ListArtistState createState() => _ListArtistState();

  final String imageId;

  const ListArtist({Key? key, required this.imageId}) : super(key: key);
}

class _ListArtistState extends State<ListArtist> {
  late String imageId;
  String? errorText;
  @override
  void initState() {
    super.initState();
    imageId = widget.imageId;
    fetchData();
  }

  Map<String, dynamic> posts = {};
  List<dynamic> listartist = [];
  Future<void> fetchData() async {
    try {
      final data = await ApiServices.getDetail(imageId);
      setState(() {
        posts = data;
        List<dynamic> artists = data['tags']['artist'];
        listartist = artists;
      });
    } catch (e) {
      setState(() {
        posts = {}; // Atau tampilkan data kosong jika terjadi kesalahan
        errorText = 'Something error: $e'; // Menampilkan pesan kesalahan
      });
    } // Tambahkan data baru ke daftar yang ada
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: listartist.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Artist:",
                    style: TextStyle(
                        color: Color.fromRGBO(135, 182, 255, 1),
                        fontWeight: FontWeight.bold),
                  ),
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: (10 / 2),
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: listartist.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return MaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TagsPage(name: listartist[index]),
                            ),
                          );
                        },
                        color: Color.fromRGBO(223, 142, 29, 1),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          listartist[index],
                          style: const TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  )
                ],
              )
            : null);
  }
}
