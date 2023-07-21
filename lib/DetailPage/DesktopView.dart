import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gif/flutter_gif.dart';
import 'package:scrolling_dulu/DetailPage/Tags/Artist.dart';
import 'package:scrolling_dulu/DetailPage/Tags/Character.dart';
import 'package:scrolling_dulu/DetailPage/Tags/Copyright.dart';
import 'package:scrolling_dulu/DetailPage/Tags/General.dart';
import 'package:scrolling_dulu/DetailPage/Tags/Species.dart';
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

class _DesktopViewState extends State<DesktopView>
    with TickerProviderStateMixin {
  late FlutterGifController controller;
  late String imageId;
  String? errorText;
  @override
  void initState() {
    super.initState();
    controller = FlutterGifController(vsync: this);
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
          ? buildErrorWidget()
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
                              builder: (context) =>
                                  _isWebM(posts['file']['url'])
                                      ? VideoPlayerWidget(
                                          imageUrl: posts['file']['url'])
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
                          child: _isGIF(posts['sample']['url'])
                              ? ExtendedImage.network(
                                  posts['sample']['url'],
                                  fit: BoxFit.cover,
                                  cache: true,
                                  enableLoadState: false,
                                  loadStateChanged: (ExtendedImageState state) {
                                    switch (state.extendedImageLoadState) {
                                      case LoadState.loading:
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      case LoadState.completed:
                                        return ExtendedRawImage(
                                          image: state.extendedImageInfo?.image,
                                          fit: BoxFit.cover,
                                        );
                                      case LoadState.failed:
                                        return Center(
                                          child: Icon(Icons.error),
                                        );
                                    }
                                  },
                                )
                              : GifImage(
                                  controller: controller,
                                  image: NetworkImage(
                                    posts['sample']['url'],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Jarak antara gambar dan informasi lainnya
                    Flexible(
                      flex: 2, // Proporsi informasi lainnya
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(37, 71, 123, 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Artist(artists: artist),
                              const SizedBox(height: 10),
                              const Text(
                                "Description:",
                                style: TextStyle(
                                    color: Color.fromRGBO(135, 182, 255, 1),
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Description(descriptions: posts['description']),
                              const SizedBox(
                                height: 5,
                              ),
                              ListArtist(imageId: imageId),
                              const SizedBox(height: 5),
                              ListGeneral(imageId: imageId),
                              const SizedBox(height: 5),
                              ListSpecies(imageId: imageId),
                              const SizedBox(height: 5),
                              ListCopyright(imageId: imageId),
                              const SizedBox(height: 5),
                              ListCharacter(imageId: imageId)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
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

  bool _isGIF(String url) {
    return url.toLowerCase().endsWith('.gif');
  }
}
