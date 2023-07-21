import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scrolling_dulu/Search/resultpage.dart';
import 'package:scrolling_dulu/data/service.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = "";
  List<String> _suggestions = [];
  Timer? _debounceTimer;
  String? errorText;
  Future<void> _fetchSuggestions() async {
    try {
      if (_searchQuery.isNotEmpty) {
        final List<dynamic> tags =
            await ApiServices.getAutocomplete(_searchQuery);
        setState(() {
          _suggestions = tags.map((tag) => tag['name'].toString()).toList();
        });
      }
    } catch (e) {
      print('Failed to fetch suggestions: $e');
    }
  }

  void _onSearchQueryChanged(String value) {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      setState(() {
        _searchQuery = value;
      });
      _fetchSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromRGBO(135, 182, 255, 1),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color.fromRGBO(2, 15, 35, 1),
        title: const Text('Search',
            style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
      ),
      body: errorText != null
          ? buildErrorWidget() // Menampilkan widget pesan kesalahan
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    style: const TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
                    onChanged: _onSearchQueryChanged,
                    onSubmitted: (value) {
                      _searchTag(value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      labelStyle:
                          TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
                      hintStyle:
                          TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
                      hintText: 'Search tags',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        title: Text(suggestion,
                            style: const TextStyle(
                                color: Color.fromRGBO(135, 182, 255, 1))),
                        onTap: () {
                          _searchTag(suggestion);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _searchTag(String suggestion) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultPage(name: suggestion)),
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
                _fetchSuggestions(); // Panggil fetchData() kembali
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
