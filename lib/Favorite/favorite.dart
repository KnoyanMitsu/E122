import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
import 'package:scrolling_dulu/data/service.dart';
import '../DetailPage/DetailPage.dart';

class HotPage extends StatefulWidget {
  @override
  _HotPageState createState() => _HotPageState();
}

String? errorText;

class _HotPageState extends State<HotPage> {
  List<dynamic> posts = [];
  var urldata =
      Uri.parse('https://e926.net/posts.json?d=1&page=1&tags=order%3Arank');
  ScrollController _scrollController = ScrollController();
  int _currentPage = 1; // Halaman saat ini

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
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

    final data = await ApiServices.gethotsNext(_currentPage);
    // Lakukan permintaan HTTP untuk memuat data halaman selanjutnya
    setState(() {
      posts.addAll(data); // Tambahkan data baru ke daftar yang ada
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 6;
    } else {
      return 2;
    }
  }

  Future<void> fetchData() async {
    var jsonData = await ApiServices.gethots();
    setState(() {
      posts = jsonData;
    });
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  List<dynamic> filterNonNullSample(List<dynamic> posts) {
    return posts.where((post) => post['sample']['url'] != null).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredPosts = filterNonNullSample(posts);
    return Scaffold(
      backgroundColor: Color.fromRGBO(2, 15, 35, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(2, 15, 35, 1),
        title: const Text('Hot',
            style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'This Settings',
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('This Settings')));
            },
            color: Color.fromRGBO(135, 182, 255, 1),
          ),
        ],
      ),
      body: errorText != null
          ? buildErrorWidget() // Menampilkan widget pesan kesalahan
          : RefreshIndicator(
              onRefresh: refreshData,
              child: StaggeredGridView.countBuilder(
                controller: _scrollController,
                crossAxisCount: _getCrossAxisCount(context),
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  double aspectRatio = filteredPosts[index]['sample']['width'] /
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
                                    filteredPosts[index]['sample']['url'],
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
