import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/media_item.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'dart:core';

class LogService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  
  static Future<void> saveLog({
    required MediaItem mediaItem,
    required DateTime loggedDate,
    double? rating,
    String? review,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _firestore.collection('logs').add({
      'uid': user.uid,
      'mediaId': mediaItem.id,
      'mediaType': mediaItem.type.toString().split('.').last,
      'title': mediaItem.title,
      'creator': mediaItem.creator,
      'coverUrl': mediaItem.coverUrl,
      'loggedDate': loggedDate.toIso8601String(),
      'rating': rating,
      'review': review,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  
  static Future<List<Map<String, dynamic>>> fetchPopularThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 7));
    final logs = await FirebaseFirestore.instance
        .collection('logs')
        .where('loggedDate', isGreaterThanOrEqualTo: startOfWeek.toIso8601String())
        .where('loggedDate', isLessThan: endOfWeek.toIso8601String())
        .get();
    final docs = logs.docs;
   
    final Map<String, Map<String, dynamic>> mediaMap = {};
    for (var doc in docs) {
      final mediaId = doc['mediaId'];
      if (!mediaMap.containsKey(mediaId)) {
        mediaMap[mediaId] = {
          'mediaId': mediaId,
          'title': doc['title'],
          'coverUrl': doc['coverUrl'],
          'creator': doc['creator'],
          'mediaType': doc['mediaType'],
          'count': 1,
        };
      } else {
        if (mediaMap[mediaId] != null) {
          mediaMap[mediaId]!['count'] = (mediaMap[mediaId]!['count'] ?? 0) + 1;
        }
      }
    }
    
    final List<Map<String, dynamic>> popular = mediaMap.values.toList();
    popular.sort((a, b) => b['count'].compareTo(a['count']));
    return popular;
  }


  static Future<List<Map<String, dynamic>>> fetchPopularThisWeekByType(String mediaType) async {
    print('[DEBUG] Fetching popular $mediaType for week...');
    final stopwatch = Stopwatch()..start();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 7));
    final logs = await FirebaseFirestore.instance
        .collection('logs')
        .where('loggedDate', isGreaterThanOrEqualTo: startOfWeek.toIso8601String())
        .where('loggedDate', isLessThan: endOfWeek.toIso8601String())
        .where('mediaType', isEqualTo: mediaType)
        .get();
    print('[DEBUG] Query for $mediaType took ${stopwatch.elapsedMilliseconds}ms and returned ${logs.docs.length} docs');
    final docs = logs.docs;
    final Map<String, Map<String, dynamic>> mediaMap = {};
    for (var doc in docs) {
      final mediaId = doc['mediaId'];
      if (!mediaMap.containsKey(mediaId)) {
        mediaMap[mediaId] = {
          'mediaId': mediaId,
          'title': doc['title'],
          'coverUrl': doc['coverUrl'],
          'creator': doc['creator'],
          'mediaType': doc['mediaType'],
          'count': 1,
        };
      } else {
        if (mediaMap[mediaId] != null) {
          mediaMap[mediaId]!['count'] = (mediaMap[mediaId]!['count'] ?? 0) + 1;
        }
      }
    }
    final List<Map<String, dynamic>> popular = mediaMap.values.toList();
    popular.sort((a, b) => b['count'].compareTo(a['count']));
    print('[DEBUG] Popular $mediaType shelf has ${popular.length} items');
    return popular;
  }

  
  static Future<List<Map<String, dynamic>>> fetchTopLoggedThisWeek() async {
    print('[DEBUG] Fetching top 20 most-logged items overall for week...');
    final stopwatch = Stopwatch()..start();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 7));
    final logs = await FirebaseFirestore.instance
        .collection('logs')
        .where('loggedDate', isGreaterThanOrEqualTo: startOfWeek.toIso8601String())
        .where('loggedDate', isLessThan: endOfWeek.toIso8601String())
        .get();
    print('[DEBUG] Query for top overall took ${stopwatch.elapsedMilliseconds}ms and returned ${logs.docs.length} docs');
    final docs = logs.docs;
    final Map<String, Map<String, dynamic>> mediaMap = {};
    for (var doc in docs) {
      final mediaId = doc['mediaId'];
      if (!mediaMap.containsKey(mediaId)) {
        mediaMap[mediaId] = {
          'mediaId': mediaId,
          'title': doc['title'],
          'coverUrl': doc['coverUrl'],
          'creator': doc['creator'],
          'mediaType': doc['mediaType'],
          'count': 1,
        };
      } else {
        if (mediaMap[mediaId] != null) {
          mediaMap[mediaId]!['count'] = (mediaMap[mediaId]!['count'] ?? 0) + 1;
        }
      }
    }
    final List<Map<String, dynamic>> popular = mediaMap.values.toList();
    popular.sort((a, b) => b['count'].compareTo(a['count']));
    print('[DEBUG] Top overall shelf has ${popular.length} items');
    return popular.take(20).toList();
  }
} 