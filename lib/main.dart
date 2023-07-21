import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gif/flutter_gif.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:scrolling_dulu/Search/searchpage.dart';
import 'package:scrolling_dulu/data/service.dart';
import 'package:scrolling_dulu/settings/settings.dart';
import 'Favorite/favorite.dart';
import 'Pools/Pools.dart';
import 'DetailPage/DetailPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EFultter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 7, 18, 52)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Container'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
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
    var newPosts = await ApiServices.getPostsNext(_currentPage);

    setState(() {
      posts.addAll(newPosts); // Tambahkan data baru ke daftar yang ada
    });
  }

  Future<void> fetchData() async {
    final data = await ApiServices.getPosts();
    setState(() {
      posts = data;
    }); // Tambahkan data baru ke daftar yang ada
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

// Fungsi untuk menyaring elemen yang memiliki sample['url'] tidak null
  List<dynamic> filterNonNullSample(List<dynamic> posts) {
    return posts.where((post) => post['sample']['url'] != null).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredPosts = filterNonNullSample(posts);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Halaman "Home"
            Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: const Color.fromRGBO(2, 15, 35, 1),
                title: const Text('Home',
                    style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'This Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
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
                                            imageId: filteredPosts[index]['id']
                                                .toString())),
                                  );
                                }, // Tetapkan aspek rasio awal (misalnya 1:1)
                                child: Container(
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
                                                      (ExtendedImageState
                                                          state) {
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
                                                    filteredPosts[index]
                                                        ['sample']['url'],
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
                                )),
                          );
                        },
                        staggeredTileBuilder: (int index) {
                          new StaggeredTile.count(2, index.isEven ? 2 : 1);
                          return const StaggeredTile.fit(1);
                        },
                      ),
              ),
            ),
            HotPage(),
            PoolsPage(),
          ],
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
        bottomNavigationBar: SalomonBottomBar(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          backgroundColor: const Color.fromRGBO(2, 15, 35, 1),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home,
                  color: Color.fromRGBO(135, 182, 255, 1)),
              title: const Text('Home',
                  style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
              selectedColor: const Color.fromRGBO(53, 99, 169, 1),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.local_fire_department,
                  color: Color.fromRGBO(135, 182, 255, 1)),
              title: const Text('Hot',
                  style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
              selectedColor: const Color.fromRGBO(53, 99, 169, 1),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.menu_book_outlined,
                  color: Color.fromRGBO(135, 182, 255, 1)),
              title: const Text('Pools',
                  style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
              selectedColor: const Color.fromRGBO(53, 99, 169, 1),
            ),
          ],
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
