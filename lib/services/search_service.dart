import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/media_item.dart';

class SearchService {
  // TMDB API for movies and TV shows
  static String get _tmdbApiKey {
    try {
      final apiKey = dotenv.env['TMDB_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('TMDB_API_KEY not found in environment variables');
      }
      return apiKey;
    } catch (e) {
      print('Error getting TMDB API key: $e');
      throw Exception('TMDB API key not configured. Please check your .env file.');
    }
  }
  static String get _tmdbAccessToken {
    try {
      final accessToken = dotenv.env['TMDB_ACCESS_TOKEN'];
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('TMDB_ACCESS_TOKEN not found in environment variables');
      }
      return accessToken;
    } catch (e) {
      print('Error getting TMDB access token: $e');
      throw Exception('TMDB access token not configured. Please check your .env file.');
    }
  }
  static const String _tmdbBaseUrl = 'https://api.themoviedb.org/3';
  
  
  static const String _openLibraryBaseUrl = 'https://openlibrary.org';
  

  static const String _itunesBaseUrl = 'https://itunes.apple.com';


  static Future<List<MediaItem>> searchMovies(String query) async {
    try {
      final apiKey = _tmdbApiKey;
      print('[DEBUG] searchMovies called with query: $query');
      print('[DEBUG] Using TMDB_API_KEY:  [31m [1m${apiKey.substring(0, 6)}... (hidden) [0m');
      final url = '$_tmdbBaseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(query)}&language=en-US&page=1';
      print('[DEBUG] Requesting URL: $url');
      final response = await http.get(Uri.parse(url));
      print('[DEBUG] Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        print('[DEBUG] Number of movie results: ${results.length}');
        return results.map((movie) => MediaItem(
          id: movie['id'].toString(),
          type: MediaType.movie,
          title: movie['title'] ?? '',
          creator: movie['release_date']?.split('-')[0] ?? '', 
          coverUrl: movie['poster_path'] != null 
            ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
            : 'https://via.placeholder.com/300x450?text=No+Image',
          loggedDate: null,
          rating: null,
          review: null,
        )).toList();
      } else {
        print('[DEBUG] Error response body: ${response.body}');
      }
    } catch (e) {
      print('[DEBUG] Error searching movies: $e');
      if (e.toString().contains('TMDB API key not configured')) {
        print('Please configure your TMDB API key in the .env file');
      }
    }
    return [];
  }

  static Future<List<MediaItem>> searchTVShows(String query) async {
    try {
      final apiKey = _tmdbApiKey;
      print('[DEBUG] searchTVShows called with query: $query');
      print('[DEBUG] Using TMDB_API_KEY:  [31m [1m${apiKey.substring(0, 6)}... (hidden) [0m');
      final url = '$_tmdbBaseUrl/search/tv?api_key=$apiKey&query=${Uri.encodeComponent(query)}&language=en-US&page=1';
      print('[DEBUG] Requesting URL: $url');
      final response = await http.get(Uri.parse(url));
      print('[DEBUG] Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        print('[DEBUG] Number of TV show results: ${results.length}');
        return results.map((show) => MediaItem(
          id: show['id'].toString(),
          type: MediaType.tvShow,
          title: show['name'] ?? '',
          creator: show['first_air_date']?.split('-')[0] ?? '',
          coverUrl: show['poster_path'] != null 
            ? 'https://image.tmdb.org/t/p/w500${show['poster_path']}'
            : 'https://via.placeholder.com/300x450?text=No+Image',
          loggedDate: null,
          rating: null,
          review: null,
        )).toList();
      } else {
        print('[DEBUG] Error response body: ${response.body}');
      }
    } catch (e) {
      print('[DEBUG] Error searching TV shows: $e');
      if (e.toString().contains('TMDB API key not configured')) {
        print('Please configure your TMDB API key in the .env file');
      }
    }
    return [];
  }

  
  static Future<List<MediaItem>> searchBooks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_openLibraryBaseUrl/search.json?q=${Uri.encodeComponent(query)}&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List;
        
        return docs.map((book) => MediaItem(
          id: book['key'] ?? '',
          type: MediaType.book,
          title: book['title'] ?? '',
          creator: book['author_name']?.first ?? 'Unknown Author',
          coverUrl: book['cover_i'] != null 
            ? 'https://covers.openlibrary.org/b/id/${book['cover_i']}-L.jpg'
            : 'https://via.placeholder.com/300x450?text=No+Image',
          loggedDate: null,
          rating: null,
          review: null,
        )).toList();
      }
    } catch (e) {
      print('Error searching books: $e');
    }
    
    return [];
  }

 
  static Future<List<MediaItem>> searchMusic(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_itunesBaseUrl/search?term=${Uri.encodeComponent(query)}&media=music&entity=album,song&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        return results.map((music) => MediaItem(
          id: music['trackId']?.toString() ?? music['collectionId']?.toString() ?? '',
          type: MediaType.music,
          title: music['trackName'] ?? music['collectionName'] ?? '',
          creator: music['artistName'] ?? 'Unknown Artist',
          coverUrl: music['artworkUrl100']?.replaceAll('100x100', '300x300') ?? 'https://via.placeholder.com/300x300?text=No+Image',
          loggedDate: null,
          rating: null,
          review: null,
        )).toList();
      }
    } catch (e) {
      print('Error searching music: $e');
    }
    
    return [];
  }

 
  static Future<List<Map<String, dynamic>>> fetchSeasons(String tvId) async {
    final apiKey = _tmdbApiKey;
    final url = '$_tmdbBaseUrl/tv/$tvId?api_key=$apiKey&language=en-US';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final seasons = data['seasons'] as List;
      return seasons.map((season) => {
        'season_number': season['season_number'],
        'name': season['name'],
        'episode_count': season['episode_count'],
        'poster_path': season['poster_path'],
        'air_date': season['air_date'],
      }).toList();
    } else {
      throw Exception('Failed to fetch seasons');
    }
  }


  static Future<List<Map<String, dynamic>>> fetchEpisodes(String tvId, int seasonNumber) async {
    final apiKey = _tmdbApiKey;
    final url = '$_tmdbBaseUrl/tv/$tvId/season/$seasonNumber?api_key=$apiKey&language=en-US';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final episodes = data['episodes'] as List;
      return episodes.map((ep) => {
        'episode_number': ep['episode_number'],
        'name': ep['name'],
        'overview': ep['overview'],
        'air_date': ep['air_date'],
        'still_path': ep['still_path'],
      }).toList();
    } else {
      throw Exception('Failed to fetch episodes');
    }
  }


  static Future<List<MediaItem>> searchAll(String query, MediaType type) async {
    switch (type) {
      case MediaType.movie:
        return await searchMovies(query);
      case MediaType.tvShow:
        return await searchTVShows(query);
      case MediaType.book:
        return await searchBooks(query);
      case MediaType.music:
        return await searchMusic(query);
    }
  }
} 