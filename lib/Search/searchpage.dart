import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:scrolling_dulu/Search/resultpage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> _suggestions = [];
  String _searchQuery = "";
  Timer? _debounce;

  Future<void> _fetchSuggestions() async {
    try {
      final response = await http.get(Uri.parse(
          'https://e926.net/tags/autocomplete.json?search%5Bname_matches%5D=$_searchQuery'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> tags = jsonData;
        setState(() {
          _suggestions = tags.map((tag) => tag['name'].toString()).toList();
        });
      }
    } catch (e) {
      print('Failed to fetch suggestions: $e');
    }
  }

  void _onSearchQueryChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
        _fetchSuggestions();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color.fromRGBO(135, 182, 255, 1),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color.fromRGBO(2, 15, 35, 1),
        title: const Text('Search',
            style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
              onChanged: _onSearchQueryChanged,
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
                hintStyle: TextStyle(color: Color.fromRGBO(135, 182, 255, 1)),
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
                      style:
                          TextStyle(color: Color.fromRGBO(135, 182, 255, 1))),
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

  Future<void> _searchTag(String suggestion) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultPage(name: suggestion)),
    );
  }
}
