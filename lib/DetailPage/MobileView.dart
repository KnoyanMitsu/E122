import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'Description.dart';
import 'Fullimage.dart'; // Import halaman penuh gambar

class MobileView extends StatefulWidget {
  final String imageId;

  const MobileView({Key? key, required this.imageId}) : super(key: key);
  
  @override
  _MobileViewState createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> {
  late String imageId;

  @override
  void initState() {
    super.initState();
    imageId = widget.imageId;
    fetchData();
  }

  Map<String, dynamic> posts = {};
  Future<void> fetchData() async {
    var urldata = Uri.parse('https://e926.net/posts/$imageId.json');
    var result = await http.get(urldata);
    if (result.statusCode == 200) {
      var jsonData = json.decode(result.body);
      setState(() {
        posts = jsonData['post'];
      });
    } else {
      print('lost connection. Code status: ${result.statusCode}');
    }
  }

  Future<void> refreshData() async {
    await fetchData();
  }
  
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
          ? ListView(
              padding: EdgeInsets.all(0),
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullImagePage(
                          imageUrl: posts['sample']['url'],
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
                      fit: BoxFit.contain,
                      loadingWidgetBuilder: (_, double progress, __) {
                        return Center(
                          child: CircularProgressIndicator(value: progress),
                        );
                      },
                      placeholder: const Icon(Icons.image),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Description(descriptions: posts['description']),
              ],
            )
            
          : CircularProgressIndicator(),
    );
  }
}
