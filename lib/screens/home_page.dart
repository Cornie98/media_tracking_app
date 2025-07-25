import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/log_service.dart';
import 'media_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, List<Map<String, dynamic>>> shelves = {
    'overall': [],
    'movie': [],
    'tvShow': [],
    'book': [],
    'music': [],
    'game': [],
  };
  bool _loadingShelves = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchShelves();
  }

  Future<void> _fetchShelves() async {
    setState(() { _loadingShelves = true; _error = null; });
    try {
      final stopwatch = Stopwatch()..start();
      final overall = await LogService.fetchTopLoggedThisWeek();
      print('[DEBUG] Overall shelf loaded in  {stopwatch.elapsedMilliseconds}ms, count:  {overall.length}');
      stopwatch.reset();
      final movies = (await LogService.fetchPopularThisWeekByType('movie')).take(20).toList();
      print('[DEBUG] Movies shelf loaded in  {stopwatch.elapsedMilliseconds}ms, count:  {movies.length}');
      stopwatch.reset();
      final tvShows = (await LogService.fetchPopularThisWeekByType('tvShow')).take(20).toList();
      print('[DEBUG] TV Shows shelf loaded in  {stopwatch.elapsedMilliseconds}ms, count:  {tvShows.length}');
      stopwatch.reset();
      final books = (await LogService.fetchPopularThisWeekByType('book')).take(20).toList();
      print('[DEBUG] Books shelf loaded in  {stopwatch.elapsedMilliseconds}ms, count:  {books.length}');
      stopwatch.reset();
      final music = (await LogService.fetchPopularThisWeekByType('music')).take(20).toList();
      print('[DEBUG] Music shelf loaded in  {stopwatch.elapsedMilliseconds}ms, count:  {music.length}');
      stopwatch.reset();
      final games = (await LogService.fetchPopularThisWeekByType('game')).take(20).toList();
      print('[DEBUG] Games shelf loaded in  {stopwatch.elapsedMilliseconds}ms, count:  {games.length}');
      setState(() {
        shelves['overall'] = overall;
        shelves['movie'] = movies;
        shelves['tvShow'] = tvShows;
        shelves['book'] = books;
        shelves['music'] = music;
        shelves['game'] = games;
        _loadingShelves = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load popular items.';
        _loadingShelves = false;
      });
    }
  }

  Widget _buildShelf(String title, String type) {
    final items = shelves[type]!.take(20).toList();
    if (items.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MediaDetailPage(
                        mediaItem: MediaItem(
                          id: item['mediaId'],
                          type: _mediaTypeFromString(item['mediaType']),
                          title: item['title'],
                          creator: item['creator'],
                          coverUrl: item['coverUrl'],
                          loggedDate: null,
                          rating: null,
                          review: null,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['coverUrl'],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[300],
                              child: Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          item['title'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          item['creator'],
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.people, color: Colors.blue, size: 16),
                          SizedBox(width: 2),
                          Text(item['count'].toString(), style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  MediaType _mediaTypeFromString(String type) {
    switch (type) {
      case 'movie': return MediaType.movie;
      case 'tvShow': return MediaType.tvShow;
      case 'book': return MediaType.book;
      case 'music': return MediaType.music;
      case 'game': return MediaType.game;
      default: return MediaType.movie;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingShelves) {
      return Scaffold(
        appBar: AppBar(title: Text('Home - Most Popular This Week')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Home - Most Popular This Week')),
        body: Center(child: Text(_error!, style: TextStyle(color: Colors.red))),
      );
    }
   
    if (shelves.values.every((list) => list.isEmpty)) {
      return Scaffold(
        appBar: AppBar(title: Text('Home - Most Popular This Week')),
        body: Center(child: Text('No popular items this week.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Home - Most Popular This Week')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (shelves['overall']!.isNotEmpty) _buildShelf('Most Logged Overall', 'overall'),
              if (shelves['movie']!.isNotEmpty) _buildShelf('Popular Movies', 'movie'),
              if (shelves['tvShow']!.isNotEmpty) _buildShelf('Popular TV Shows', 'tvShow'),
              if (shelves['book']!.isNotEmpty) _buildShelf('Popular Books', 'book'),
              if (shelves['music']!.isNotEmpty) _buildShelf('Popular Music', 'music'),
              if (shelves['game']!.isNotEmpty) _buildShelf('Popular Games', 'game'),
            ],
          ),
        ),
      ),
    );
  }
} 