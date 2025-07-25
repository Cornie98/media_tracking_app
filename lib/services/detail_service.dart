import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/media_item.dart';

class DetailService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

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

  static const String _tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String _openLibraryBaseUrl = 'https://openlibrary.org';
  static const String _itunesBaseUrl = 'https://itunes.apple.com';

  // RAWG API for games
  static String get _rawgApiKey {
    try {
      final apiKey = dotenv.env['RAWG_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('RAWG_API_KEY not found in environment variables');
      }
      return apiKey;
    } catch (e) {
      print('Error getting RAWG API key: $e');
      throw Exception('RAWG API key not configured. Please check your .env file.');
    }
  }
  static const String _rawgBaseUrl = 'https://api.rawg.io/api';

  // Fetch detailed information from APIs
  static Future<Map<String, dynamic>> fetchMediaDetails(MediaItem mediaItem) async {
    try {
      switch (mediaItem.type) {
        case MediaType.movie:
          return await _fetchMovieDetails(mediaItem.id);
        case MediaType.tvShow:
          return await _fetchTVShowDetails(mediaItem.id);
        case MediaType.book:
          return await _fetchBookDetails(mediaItem.id);
        case MediaType.music:
          return await _fetchMusicDetails(mediaItem.id);
        case MediaType.game:
          return await _fetchGameDetails(mediaItem.id);
      }
    } catch (e) {
      print('Error fetching media details: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _fetchMovieDetails(String movieId) async {
    try {
      final apiKey = _tmdbApiKey;
      final url = '$_tmdbBaseUrl/movie/$movieId?api_key=$apiKey&language=en-US&append_to_response=credits';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'description': data['overview'] ?? 'No description available',
          'cast': data['credits']?['cast']?.take(5).map((actor) => actor['name']).toList() ?? [],
          'genres': data['genres']?.map((genre) => genre['name']).toList() ?? [],
          'releaseDate': data['release_date'] ?? '',
          'runtime': data['runtime'] ?? 0,
          'voteAverage': data['vote_average']?.toDouble() ?? 0.0,
          'voteCount': data['vote_count'] ?? 0,
        };
      }
    } catch (e) {
      print('Error fetching movie details: $e');
    }
    return {};
  }

  static Future<Map<String, dynamic>> _fetchTVShowDetails(String tvId) async {
    try {
      final apiKey = _tmdbApiKey;
      final url = '$_tmdbBaseUrl/tv/$tvId?api_key=$apiKey&language=en-US&append_to_response=credits';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'description': data['overview'] ?? 'No description available',
          'cast': data['credits']?['cast']?.take(5).map((actor) => actor['name']).toList() ?? [],
          'genres': data['genres']?.map((genre) => genre['name']).toList() ?? [],
          'firstAirDate': data['first_air_date'] ?? '',
          'lastAirDate': data['last_air_date'] ?? '',
          'numberOfSeasons': data['number_of_seasons'] ?? 0,
          'numberOfEpisodes': data['number_of_episodes'] ?? 0,
          'voteAverage': data['vote_average']?.toDouble() ?? 0.0,
          'voteCount': data['vote_count'] ?? 0,
        };
      }
    } catch (e) {
      print('Error fetching TV show details: $e');
    }
    return {};
  }

  static Future<Map<String, dynamic>> _fetchBookDetails(String bookId) async {
    try {
      final url = '$_openLibraryBaseUrl/works/$bookId.json';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'description': data['description']?['value'] ?? data['description'] ?? 'No description available',
          'authors': data['authors']?.map((author) => author['author']['name']).toList() ?? [],
          'subjects': data['subjects']?.take(5).toList() ?? [],
          'firstPublished': data['first_publish_date'] ?? '',
          'pages': data['number_of_pages_median'] ?? 0,
          'rating': data['rating']?['average']?.toDouble() ?? 0.0,
        };
      }
    } catch (e) {
      print('Error fetching book details: $e');
    }
    return {};
  }

  static Future<Map<String, dynamic>> _fetchMusicDetails(String musicId) async {
    try {
      final url = '$_itunesBaseUrl/lookup?id=$musicId&entity=song,album';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        if (results.isNotEmpty) {
          final item = results.first;
          
          // Try to find a sample track (preview URL)
          String? previewUrl;
          String? sampleTrackName;
          
          // Look for tracks with preview URLs
          for (var result in results) {
            if (result['kind'] == 'song' && result['previewUrl'] != null) {
              previewUrl = result['previewUrl'];
              sampleTrackName = result['trackName'];
              break;
            }
          }
          
          return {
            'description': item['longDescription'] ?? item['description'] ?? 'No description available',
            'artist': item['artistName'] ?? '',
            'genre': item['primaryGenreName'] ?? '',
            'releaseDate': item['releaseDate'] ?? '',
            'trackCount': item['trackCount'] ?? 0,
            'rating': item['averageUserRating']?.toDouble() ?? 0.0,
            'price': item['price'] ?? '',
            'previewUrl': previewUrl,
            'sampleTrackName': sampleTrackName,
          };
        }
      }
    } catch (e) {
      print('Error fetching music details: $e');
    }
    return {};
  }

  static Future<Map<String, dynamic>> _fetchGameDetails(String gameId) async {
    try {
      final apiKey = _rawgApiKey;
      final url = '$_rawgBaseUrl/games/$gameId?key=$apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'description': data['description'] ?? 'No description available',
          'developer': data['developers']?.first?['name'] ?? '',
          'publisher': data['publishers']?.first?['name'] ?? '',
          'genres': data['genres']?.map((genre) => genre['name']).toList() ?? [],
          'platforms': data['platforms']?.map((platform) => platform['platform']['name']).toList() ?? [],
          'releaseDate': data['released'] ?? '',
          'rating': data['rating']?.toDouble() ?? 0.0,
          'ratingCount': data['rating_top'] ?? 0,
        };
      }
    } catch (e) {
      print('Error fetching game details: $e');
    }
    return {};
  }

  // Fetch ratings and comments from Firestore
  static Future<List<Map<String, dynamic>>> fetchRatingsAndComments(String mediaId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final logs = await _firestore
          .collection('logs')
          .where('mediaId', isEqualTo: mediaId)
          .get();

      final List<Map<String, dynamic>> reviews = [];
      for (var doc in logs.docs) {
        if (doc['rating'] != null) {
          reviews.add({
            'user': doc['uid'],
            'rating': doc['rating'].toDouble(),
            'review': doc['review'] ?? '',
            'date': doc['loggedDate'] ?? '',
            'createdAt': doc['createdAt'],
          });
        }
      }

      // Sort by creation date (newest first)
      reviews.sort((a, b) {
        if (a['createdAt'] == null && b['createdAt'] == null) return 0;
        if (a['createdAt'] == null) return 1;
        if (b['createdAt'] == null) return -1;
        return b['createdAt'].compareTo(a['createdAt']);
      });

      return reviews;
    } catch (e) {
      print('Error fetching ratings and comments: $e');
      return [];
    }
  }

  // Calculate average rating
  static double calculateAverageRating(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 0.0;
    
    final totalRating = reviews.fold<double>(0.0, (sum, review) => sum + (review['rating'] ?? 0.0));
    return totalRating / reviews.length;
  }

  // Get rating distribution
  static Map<int, int> getRatingDistribution(List<Map<String, dynamic>> reviews) {
    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = 0;
    }
    
    for (var review in reviews) {
      final rating = (review['rating'] ?? 0.0).round();
      if (rating >= 1 && rating <= 5) {
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
    }
    
    return distribution;
  }
} 