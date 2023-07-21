import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scrolling_dulu/DetailPage/DetailPage.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:scrolling_dulu/main.dart';
import '../../Search/searchpage.dart';
import '../../data/service.dart';

class TagsPage extends StatefulWidget {
  final String name;

  const TagsPage({Key? key, required this.name}) : super(key: key);

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> with TickerProviderStateMixin {
  late String name;
  List<dynamic> posts = [];
  String? errorText;
  int _getCrossAxisCount(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 6;
    } else {
      return 2;
    }
  }

  ScrollController _scrollController = ScrollController();
  int _currentPage = 1; // Halaman saat ini
  late FlutterGifController controller;
  @override
  void initState() {
    controller = FlutterGifController(vsync: this);
    super.initState();
    _scrollController.addListener(_scrollListener);
    name = widget.name;
    fetchData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Ketika mencapai scroll bawah, muat data lebih lanjut
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    // Tingkatkan nomor halaman saat ini
    _currentPage++;

    // Lakukan permintaan HTTP untuk memuat data halaman selanjutnya
    var newPosts = await ApiServices.getResultNext(_currentPage, name);

    setState(() {
      posts.addAll(newPosts); // Tambahkan data baru ke daftar yang ada
    });
  }

  Future<void> fetchData() async {
    try {
      final data = await ApiServices.getResult(name);
      setState(() {
        posts = data;
      });
    } catch (e) {
      setState(() {
        posts = []; // Atau tampilkan data kosong jika terjadi kesalahan
        errorText = 'Something error: $e'; // Menampilkan pesan kesalahan
      });
    }
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  int _currentIndex = 0;

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false; // Menahan navigasi kembali
    }
    return true; // Lanjutkan navigasi kembali
  }

  List<dynamic> filterNonNullSample(List<dynamic> posts) {
    return posts.where((post) => post['sample']['url'] != null).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredPosts = filterNonNullSample(posts);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: const Color.fromRGBO(135, 182, 255, 1),
            onPressed: () {
              Navigator.pop(context,
                  MaterialPageRoute(builder: (context) => const MyApp()));
            },
          ),
          backgroundColor: const Color.fromRGBO(2, 15, 35, 1),
          title: const Text('Search',
              style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'This Settings',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This Settings')));
              },
              color: const Color.fromRGBO(135, 182, 255, 1),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: refreshData,
          child: errorText != null
              ? buildErrorWidget() // Menampilkan widget pesan kesalahan
              : StaggeredGridView.countBuilder(
                  controller: _scrollController,
                  crossAxisCount: _getCrossAxisCount(context),
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    double aspectRatio = filteredPosts[index]['sample']
                            ['width'] /
                        filteredPosts[index]['sample']['height'];
                    return AspectRatio(
                      aspectRatio: aspectRatio,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPage(
                                    imageId:
                                        filteredPosts[index]['id'].toString())),
                          );
                        }, // Tetapkan aspek rasio awal (misalnya 1:1)
                        child: filteredPosts[index]['sample']['url'] != null
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color.fromRGBO(37, 71, 123, 1),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        child: _isGIF(filteredPosts[index]
                                                ['sample']['url'])
                                            ? ExtendedImage.network(
                                                filteredPosts[index]['sample']
                                                    ['url'],
                                                fit: BoxFit.cover,
                                                cache: true,
                                                enableLoadState: false,
                                                loadStateChanged:
                                                    (ExtendedImageState state) {
                                                  switch (state
                                                      .extendedImageLoadState) {
                                                    case LoadState.loading:
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    case LoadState.completed:
                                                      return ExtendedRawImage(
                                                        image: state
                                                            .extendedImageInfo
                                                            ?.image,
                                                        fit: BoxFit.cover,
                                                      );
                                                    case LoadState.failed:
                                                      return Center(
                                                        child:
                                                            Icon(Icons.error),
                                                      );
                                                  }
                                                },
                                              )
                                            : GifImage(
                                                controller: controller,
                                                image: NetworkImage(
                                                  filteredPosts[index]['sample']
                                                      ['url'],
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.arrow_upward,
                                            color: Colors.green[200],
                                          ),
                                          onPressed: () {
                                            // Aksi ketika tombol upvote ditekan
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.arrow_downward,
                                            color: Colors.red[200],
                                          ),
                                          onPressed: () {
                                            // Aksi ketika tombol downvote ditekan
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                  staggeredTileBuilder: (int index) {
                    new StaggeredTile.count(2, index.isEven ? 2 : 1);
                    return const StaggeredTile.fit(1);
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },
          backgroundColor: const Color.fromRGBO(53, 99, 169, 1),
          child:
              const Icon(Icons.search, color: Color.fromRGBO(135, 182, 255, 1)),
        ),
      ),
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
      ),
    );
  }

  bool _isGIF(String url) {
    return url.toLowerCase().endsWith('.gif');
  }
}
