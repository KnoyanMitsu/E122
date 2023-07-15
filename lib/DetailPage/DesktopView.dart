import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'Info.dart';
import 'Fullimage.dart';
import 'Description.dart';
import 'Artist.dart';

class DesktopView extends StatefulWidget {
  final String imageId;

  const DesktopView({Key? key, required this.imageId}) : super(key: key);

  @override
  _DesktopViewState createState() => _DesktopViewState();
}

class _DesktopViewState extends State<DesktopView> {
  late String imageId;

  @override
  void initState() {
    super.initState();
    imageId = widget.imageId;
    fetchData();
  }

  Map<String, dynamic> posts = {};
  List<dynamic> artists = [];
  Future<void> fetchData() async {
    var urldata = Uri.parse('https://e926.net/posts/$imageId.json');
    var result = await http.get(urldata);
    if (result.statusCode == 200) {
      var jsonData = json.decode(result.body);
      setState(() {
        posts = jsonData['post'];
      }); // Tambahkan data baru ke daftar yang ada
    } else {
      print('lost connection. Code status: ${result.statusCode}');
    }
  }

  Future<void> refreshData() async {
    await fetchData();
  }
  // Halaman saat ini

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(2, 15, 35, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(2, 15, 35, 1),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color.fromRGBO(135, 182, 255, 1),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Detail',
          style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
        ),
      ),
      body: posts.isNotEmpty
          ? Row(
              children: [
                InkWell(
                  onTap: () {
                    // Pindah ke halaman FullImagePage ketika gambar diklik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullImagePage(
                          imageUrl: posts['file']['url'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Color.fromRGBO(37, 71, 123, 1),
                    ),
                    child: TransitionToImage(
                      image: AdvancedNetworkImage(
                        posts['file']['url'],
                        loadedCallback: () {
                          print('Done');
                        },
                        loadFailedCallback: () {
                          print('What happened to your internet');
                        },
                        useDiskCache: true,
                      ),
                      fit: BoxFit.cover,
                      loadingWidgetBuilder: (_, double progress, __) {
                        return Center(
                          child: CircularProgressIndicator(value: progress),
                        );
                      },
                      placeholder: const Icon(Icons.image),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Info(
                        description: posts['description'],
                        artist: posts['tags']['artist'].toString()))
              ],
            )
          : CircularProgressIndicator(),
    );
  }
}
