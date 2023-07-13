import 'package:flutter/material.dart';

import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'Favorite/favorite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 7, 18, 52)),
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




class _MyHomePageState extends State<MyHomePage> {
     List<dynamic> posts = [];
  var urldata = Uri.parse('https://e926.net/posts.json?page=1&tags=ralsei');

  int _getCrossAxisCount(BuildContext context) {
  final double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 600) {
    return 4;
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
  fetchData();
}

@override
void dispose() {
  _scrollController.removeListener(_scrollListener);
  _scrollController.dispose();
  super.dispose();
}

void _scrollListener() {
  if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
    // Ketika mencapai scroll bawah, muat data lebih lanjut
    _loadMoreData();
  }
}

Future<void> _loadMoreData() async {
  // Tingkatkan nomor halaman saat ini
  _currentPage++;

  // Lakukan permintaan HTTP untuk memuat data halaman selanjutnya
  var nextPageUrl = 'https://e926.net/posts.json?page=$_currentPage&tags=ralsei';
  var response = await http.get(Uri.parse(nextPageUrl));

  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    var newPosts = jsonData['posts'];

    setState(() {
      posts.addAll(newPosts); // Tambahkan data baru ke daftar yang ada
    });
  } else {
    print(nextPageUrl);
    print('Gagal mengambil data halaman $_currentPage. Kode status: ${response.statusCode}');
  }
}

  Future<void> fetchData() async {
    var result = await http.get(urldata);
    var jsonData = json.decode(result.body);
    setState(() {
      posts = jsonData['posts'];
    });
  }

  Future<void> refreshData() async {
    await fetchData();
  }

int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
    appBar: AppBar(
        backgroundColor: Color.fromRGBO(2, 15, 35, 1),
        title: const Text('Flutter With e926 API (Debug)',
        style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'This Search',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This Search')));
            },
            color: Color.fromRGBO(135, 182, 255, 1),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Halaman "Home"
          RefreshIndicator(
        onRefresh: refreshData,
        child: GridView.builder(
          controller: _scrollController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return AspectRatio(
                aspectRatio: 1.0, // Tetapkan aspek rasio awal (misalnya 1:1)
                child: Container(
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Color.fromRGBO(37, 71, 123, 1),
                  ),     
                  child: Column(
                    children: [
                      Expanded(
                        child: TransitionToImage(
                          image: AdvancedNetworkImage(
                            posts[index]['preview']['url'],
                            loadedCallback: (){
                              print('Done');
                            },
                            loadFailedCallback: (){
                              print('what happen your internet');
                            },
                            useDiskCache: true, // Gunakan cache untuk mempercepat pengambilan gambar
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_upward,
                            color: Colors.green[200],),
                            onPressed: () {
                              // Aksi ketika tombol upvote ditekan
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_downward,
                            color: Colors.red[200],),
                            onPressed: () {
                              // Aksi ketika tombol downvote ditekan
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ),
          // Halaman "Favorite"
          HotPage(),
        ],
      ),
      bottomNavigationBar: SalomonBottomBar(
        
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        backgroundColor: Color.fromRGBO(2, 15, 35, 1),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home,
            color: Color.fromRGBO(135, 182, 255, 1)),
            title: Text('Home',
            style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
            selectedColor: Color.fromRGBO(53, 99, 169, 1),
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.local_fire_department,
            color: Color.fromRGBO(135, 182, 255, 1)),
            title: Text('Hot',
            style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
            selectedColor: Color.fromRGBO(53, 99, 169, 1),
          ),
        ],
      ),
    );
  }
}



