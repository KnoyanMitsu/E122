import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scrolling_dulu/DetailPage/DetailPage.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:scrolling_dulu/main.dart';

import '../data/service.dart';

class ResultPage extends StatefulWidget {
  final String name;

  const ResultPage({Key? key, required this.name}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
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

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Color.fromRGBO(135, 182, 255, 1),
            onPressed: () {
              Navigator.pop(
                  context, MaterialPageRoute(builder: (context) => MyApp()));
            },
          ),
          backgroundColor: Color.fromRGBO(2, 15, 35, 1),
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
              color: Color.fromRGBO(135, 182, 255, 1),
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
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    double aspectRatio = posts[index]['sample']['width'] /
                        posts[index]['sample']['height'];
                    return AspectRatio(
                      aspectRatio: aspectRatio,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailPage(
                                    imageId: posts[index]['id'].toString())),
                          );
                        }, // Tetapkan aspek rasio awal (misalnya 1:1)
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color.fromRGBO(37, 71, 123, 1),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  child: TransitionToImage(
                                    image: AdvancedNetworkImage(
                                      posts[index]['sample']['url'],
                                      loadedCallback: () {
                                        print('Done');
                                      },
                                      loadFailedCallback: () {
                                        print('what happen your internet');
                                      },
                                      useDiskCache:
                                          true, // Gunakan cache untuk mempercepat pengambilan gambar
                                    ),
                                    fit: BoxFit.cover,
                                    loadingWidgetBuilder:
                                        (_, double progress, __) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                            value: progress),
                                      );
                                    },
                                    placeholder: const Icon(Icons.image),
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
                        ),
                      ),
                    );
                  },
                  staggeredTileBuilder: (int index) {
                    new StaggeredTile.count(2, index.isEven ? 2 : 1);
                    return StaggeredTile.fit(1);
                  },
                ),
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
}
