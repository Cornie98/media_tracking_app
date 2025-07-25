import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/log_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  bool _loadingStats = true;
  Map<String, dynamic> userStats = {};
  final Map<String, dynamic> userData = {
    'name': 'connie',
    'email': 'connie@example.com',
    'joinDate': 'July 2025',
    'totalItems': 0,
    'movies': 0,
    'books': 0,
    'music': 0,
    'tvShows': 0,
    'games': 0,
    'averageRating': 4.2,
  };
  List<Map<String, dynamic>> _loggedDatesWithTypes = [];
  List<Map<String, dynamic>> _allLoggedDates = [];

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
  }

  Future<void> _fetchUserStats() async {
    setState(() { _loadingStats = true; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
    
      final loggedDatesWithTypes = await LogService.fetchLoggedDatesWithTypes();
      
     
      final allLoggedDates = await LogService.fetchAllLoggedDatesSorted();
      
      
      final logs = await FirebaseFirestore.instance
        .collection('logs')
        .where('uid', isEqualTo: user.uid)
        .get();
      final docs = logs.docs;
      int movies = 0, books = 0, music = 0, tvShows = 0, games = 0;
      double totalRating = 0;
      int ratedCount = 0;
      
      for (var doc in docs) {
        final type = doc['mediaType'];
        switch (type) {
          case 'movie': movies++; break;
          case 'book': books++; break;
          case 'music': music++; break;
          case 'tvShow': tvShows++; break;
          case 'game': games++; break;
        }
        if (doc['rating'] != null) {
          totalRating += (doc['rating'] as num).toDouble();
          ratedCount++;
        }
      }
      
      setState(() {
        userStats = {
          'totalItems': docs.length,
          'movies': movies,
          'books': books,
          'music': music,
          'tvShows': tvShows,
          'games': games,
          'averageRating': ratedCount > 0 ? (totalRating / ratedCount) : null,
        };
        _loggedDatesWithTypes = loggedDatesWithTypes;
        _allLoggedDates = allLoggedDates;
        _loadingStats = false;
      });
    } catch (e) {
      print('Error fetching user stats: $e');
      setState(() {
        _loadingStats = false;
      });
    }
  }

 
  IconData _getIconForMediaType(String mediaType) {
    switch (mediaType) {
      case 'movie':
        return Icons.movie;
      case 'book':
        return Icons.book;
      case 'tvShow':
        return Icons.tv;
      case 'music':
        return Icons.music_note;
      case 'game':
        return Icons.sports_esports;
      default:
        return Icons.media_bluetooth_on;
    }
  }

  
  Color _getColorForMediaType(String mediaType) {
    switch (mediaType) {
      case 'movie':
        return Colors.red;
      case 'book':
        return Colors.green;
      case 'tvShow':
        return Colors.purple;
      case 'music':
        return Colors.orange;
      case 'game':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

 
  List<String> _getMediaTypesForDate(DateTime date) {
    return _loggedDatesWithTypes
        .where((item) => 
            item['date'].year == date.year && 
            item['date'].month == date.month && 
            item['date'].day == date.day)
        .map((item) => item['mediaType'] as String)
        .toList();
  }

  
  List<Map<String, dynamic>> _getLoggedMediaForDate(DateTime date) {
    return _loggedDatesWithTypes
        .where((item) => 
            item['date'].year == date.year && 
            item['date'].month == date.month && 
            item['date'].day == date.day)
        .toList();
  }

  
  void _showLoggedMediaDialog(DateTime date) {
    final loggedMedia = _getLoggedMediaForDate(date);
    if (loggedMedia.isEmpty) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logged on ${date.day}/${date.month}/${date.year}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: loggedMedia.map((item) {
                final mediaType = item['mediaType'] as String;
                final title = item['title'] as String;
                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getColorForMediaType(mediaType),
                    ),
                    child: Icon(
                      _getIconForMediaType(mediaType),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                                     subtitle: Text(
                     mediaType == 'tvShow' ? 'TV Show' : 
                     mediaType == 'movie' ? 'Movie' :
                     mediaType == 'book' ? 'Book' : 
                     mediaType == 'game' ? 'Game' : 'Music',
                     style: TextStyle(color: Colors.grey[600]),
                   ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ProfilePage build method called');
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'DEBUG: Profile page is loading correctly',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[800]),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: Icon(Icons.logout, color: Colors.white),
                    label: Text('LOGOUT NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildUserInfoSection(),
            SizedBox(height: 24),
            _loadingStats
              ? Center(child: CircularProgressIndicator())
              : _buildStatsSection(),
            SizedBox(height: 24),
            _buildCalendarSection(),
            SizedBox(height: 24),
            _buildLoggedDatesList(),
            SizedBox(height: 24),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Text(
              userData['name'].split(' ').map((n) => n[0]).join(''),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  userData['email'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Member since ${userData['joinDate']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Items',
                userStats['totalItems'].toString(),
                Icons.library_books,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Avg Rating',
                userStats['averageRating']?.toStringAsFixed(1) ?? 'N/A',
                Icons.star,
                Colors.amber,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Movies',
                userStats['movies'].toString(),
                Icons.movie,
                Colors.red,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Books',
                userStats['books'].toString(),
                Icons.book,
                Colors.green,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Music',
                userStats['music'].toString(),
                Icons.music_note,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'TV Shows',
                userStats['tvShows'].toString(),
                Icons.tv,
                Colors.purple,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Games',
                userStats['games'].toString(),
                Icons.sports_esports,
                Colors.indigo,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Container(), 
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Calendar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => false,
                onDaySelected: (selectedDay, focusedDay) {
                  final mediaTypes = _getMediaTypesForDate(selectedDay);
                  if (mediaTypes.isNotEmpty) {
                    _showLoggedMediaDialog(selectedDay);
                  }
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final mediaTypes = _getMediaTypesForDate(date);
                    if (mediaTypes.isNotEmpty) {
                      
                      if (mediaTypes.length > 1) {
                        return Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: Center(
                              child: Text(
                                mediaTypes.length.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Show specific icon for single media type
                        final mediaType = mediaTypes.first;
                        return Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getColorForMediaType(mediaType),
                            ),
                            child: Icon(
                              _getIconForMediaType(mediaType),
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        );
                      }
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                 
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Multiple Items'),
                    ],
                  ),
                  
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Icon(
                          Icons.movie,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Movie'),
                    ],
                  ),
                 
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Book'),
                    ],
                  ),
                 
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple,
                        ),
                        child: Icon(
                          Icons.tv,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('TV Show'),
                    ],
                  ),
                  
                   Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Container(
                         width: 16,
                         height: 16,
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           color: Colors.orange,
                         ),
                         child: Icon(
                           Icons.music_note,
                           color: Colors.white,
                           size: 10,
                         ),
                       ),
                       SizedBox(width: 8),
                       Text('Music'),
                     ],
                   ),
                   
                   Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Container(
                         width: 16,
                         height: 16,
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           color: Colors.indigo,
                         ),
                         child: Icon(
                           Icons.sports_esports,
                           color: Colors.white,
                           size: 10,
                         ),
                       ),
                       SizedBox(width: 8),
                       Text('Game'),
                     ],
                   ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedDatesList() {
    if (_allLoggedDates.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _allLoggedDates.length,
            itemBuilder: (context, index) {
              final dateData = _allLoggedDates[index];
              final date = dateData['date'] as DateTime;
              final items = dateData['items'] as List<dynamic>;
              
              
              final day = date.day;
              final suffix = _getDaySuffix(day);
              final month = _getMonthName(date.month);
              final formattedDate = '$day$suffix $month ${date.year}';
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 12),
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ...items.map<Widget>((item) {
                    final mediaType = item['mediaType'] as String;
                    final title = item['title'] as String;
                    final rating = item['rating'] as double?;
                    
                    return Padding(
                      padding: EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getColorForMediaType(mediaType),
                            ),
                            child: Icon(
                              _getIconForMediaType(mediaType),
                              color: Colors.white,
                              size: 8,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (rating != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildStarRating(rating),
                                SizedBox(width: 4),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (rating >= index + 1) {
          
          return Icon(
            Icons.star,
            color: Colors.amber,
            size: 16,
          );
        } else if (rating > index && rating < index + 1) {
          
          return Icon(
            Icons.star_half,
            color: Colors.amber,
            size: 16,
          );
        } else {
         
          return Icon(
            Icons.star_border,
            color: Colors.amber,
            size: 16,
          );
        }
      }),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text('Edit Profile'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.orange),
                title: Text('Notifications'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.security, color: Colors.green),
                title: Text('Privacy & Security'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.help, color: Colors.purple),
                title: Text('Help & Support'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Sign Out'),
                onTap: _signOut,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 