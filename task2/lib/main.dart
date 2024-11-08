import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Albums with Search Filter',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.teal,
        hintColor: Colors.amber,
        fontFamily: 'Georgia',
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white70),
        ),
      ),
      home: AlbumListScreen(),
    );
  }
}

class Album {
  final int id;
  final String title;

  Album({required this.id, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'],
    );
  }
}

class AlbumListScreen extends StatefulWidget {
  @override
  _AlbumListScreenState createState() => _AlbumListScreenState();
}

class _AlbumListScreenState extends State<AlbumListScreen> {
  List<Album> _albums = [];
  List<Album> _filteredAlbums = [];
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _fetchAlbums() async {
    try {
      final response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));

      if (response.statusCode == 200) {
        List jsonData = json.decode(response.body);
        List<Album> loadedAlbums =
            jsonData.map((data) => Album.fromJson(data)).toList();

        setState(() {
          _albums = loadedAlbums;
          _filteredAlbums = loadedAlbums;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load albums');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAlbums();
    _searchController.addListener(_filterAlbums);
  }

  void _filterAlbums() {
    String query = _searchController.text.toLowerCase();
    List<Album> filteredAlbums = _albums.where((album) {
      return album.title.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _filteredAlbums = filteredAlbums;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albums with Search Filter'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Text('Failed to load data. Please try again later.'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search Albums',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.teal[700],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.amber),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    _filteredAlbums.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No albums found matching your search.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.amber),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _filteredAlbums.length,
                              itemBuilder: (context, index) {
                                Album album = _filteredAlbums[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 8.0),
                                  child: Card(
                                    color: Colors.teal[800],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.amber,
                                        child: Text(
                                          album.id.toString(),
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      title: Text(
                                        album.title,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
