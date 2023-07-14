import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PoolsPage extends StatefulWidget {
  @override
  _PoolsPageState createState() => _PoolsPageState();
}

class _PoolsPageState extends State<PoolsPage> {
  List<dynamic> posts = [];
  var urldata = Uri.parse('https://e926.net/pools.json');
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
  var nextPageUrl = 'https://e926.net/pools.json?page=$_currentPage';
  var response = await http.get(Uri.parse(nextPageUrl));

  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    var newPosts = jsonData;

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
      posts = jsonData;
    });
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
        title: const Text('Pools',
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
      body: Center( 
        child: RefreshIndicator(
        onRefresh: refreshData,
        child: StaggeredGridView.countBuilder(
          controller: _scrollController,
          crossAxisCount: 1,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
            itemCount: posts.length,
            itemBuilder: (context, index) { // Tetapkan aspek rasio awal (misalnya 1:1)
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Color.fromRGBO(37, 71, 123, 1),
                  ),     
                  child: Column(
                    children: [
                      Text(posts[index]['name'],
                      style: TextStyle(color: Color.fromRGBO(53, 99, 169, 1)),)
                    ],
                  ),
                );
            },
            staggeredTileBuilder: (int index) {
                new StaggeredTile.count(2, index.isEven ? 2 : 1);
                 return StaggeredTile.fit(1);
             },
          ),
      ),
      )
    );
  }
}
