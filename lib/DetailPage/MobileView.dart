import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:flutter_gif/flutter_gif.dart';
import '../data/service.dart';
import 'Description.dart';
import 'Artist.dart';
import 'FullWebm.dart';
import 'Fullimage.dart';
import 'Tags/Artist.dart';
import 'Tags/Character.dart';
import 'Tags/Copyright.dart';
import 'Tags/General.dart';
import 'Tags/Species.dart'; // Import halaman penuh gambar

class MobileView extends StatefulWidget {
  final String imageId;

  const MobileView({Key? key, required this.imageId}) : super(key: key);

  @override
  _MobileViewState createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> with TickerProviderStateMixin {
  late String imageId;
  String? errorText;
  late FlutterGifController controller;
  @override
  void initState() {
    controller = FlutterGifController(vsync: this);
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
    }
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(2, 15, 35, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(2, 15, 35, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromRGBO(135, 182, 255, 1),
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
              ? ListView(
                  padding: const EdgeInsets.all(0),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _isWebM(posts['file']['url'])
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
                          color: const Color.fromRGBO(37, 71, 123, 1),
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
                    Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(37, 71, 123, 1),
                        ),
                        child: Column(
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
                            const SizedBox(height: 10),
                            Description(descriptions: posts['description']),
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
                        ))
                  ],
                )
              : const CircularProgressIndicator(),
    );
  }

  Widget buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            errorText!,
            style: const TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                errorText = null; // Hapus pesan kesalahan dan coba lagi
              });
              fetchData(); // Panggil fetchData() kembali
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  bool _isGIF(String url) {
    return url.toLowerCase().endsWith('.gif');
  }

  bool _isWebM(String url) {
    return url.toLowerCase().endsWith('.webm');
  }
}
