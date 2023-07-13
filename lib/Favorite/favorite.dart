import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_advanced_networkimage_2/transition.dart';

class HotPage extends StatefulWidget {
  @override
  _HotPageState createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  List<dynamic> posts = [];
  var urldata = Uri.parse('https://e926.net/posts.json?d=1&page=1&tags=order%3Arank');
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
  var nextPageUrl = 'https://e926.net/posts.json?d=1&page=$_currentPage&tags=order%3Arank';
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
  int _getCrossAxisCount(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 4;
    } else {
      return 2;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(2, 15, 35, 1),
      body: RefreshIndicator(
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
              aspectRatio: 1.0,
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
                          loadedCallback: () {
                            print('Done');
                          },
                          loadFailedCallback: () {
                            print('What happened to your internet?');
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
            );
          },
        ),
      ),
    );
  }
}
