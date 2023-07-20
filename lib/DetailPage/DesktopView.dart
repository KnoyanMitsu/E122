import 'package:flutter/material.dart';

import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:scrolling_dulu/data/service.dart';
import 'FullWebm.dart';
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
  String? errorText;
  @override
  void initState() {
    super.initState();
    imageId = widget.imageId;
    fetchData();
  }

  Map<String, dynamic> posts = {};
  List<dynamic> artists = [];
  String artist = "";
  Future<void> fetchData() async {
    try {
      final data = await ApiServices.getDetail(imageId);
      setState(() {
        posts = data;
        artists = data['tags']['artist'];
        String artistsAsString = artists.join(', ');
        artist = artistsAsString;
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
      body: errorText != null
          ? buildErrorWidget() // Menampilkan widget pesan kesalahan
          : posts.isNotEmpty
              ? Row(
                  children: [
                    Flexible(
                      flex: 1, // Proporsi gambar
                      child: InkWell(
                        onTap: () {
                          // Pindah ke halaman FullImagePage ketika gambar diklik
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => _isWebM(posts['file']['url'])
                          ? VideoPlayerWidget(imageUrl: posts['file']['url'])
                          : FullImagePage(
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
                              posts['sample']['url'],
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
                                child:
                                    CircularProgressIndicator(value: progress),
                              );
                            },
                            placeholder: const Icon(Icons.image),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        width: 10), // Jarak antara gambar dan informasi lainnya
                    Flexible(
                      flex: 2, // Proporsi informasi lainnya
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(37, 71, 123, 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Artist(artists: artist),
                            Description(descriptions: posts['description']),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : CircularProgressIndicator(),
    );
  }

  Widget buildErrorWidget() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              errorText!,
              style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  errorText = null; // Hapus pesan kesalahan dan coba lagi
                });
                fetchData(); // Panggil fetchData() kembali
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
    bool _isWebM(String url) {
    return url.toLowerCase().endsWith('.webm');
  }
}
