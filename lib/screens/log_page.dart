import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/search_service.dart';
import '../services/log_service.dart';

class LogPage extends StatefulWidget {
  final MediaItem? mediaItem;
  LogPage({this.mediaItem});
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  double? userRating;
  String userReview = '';
  MediaType selectedType = MediaType.movie;
  final TextEditingController searchController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<MediaItem> searchResults = [];
  bool isSearching = false;
  MediaItem? selectedMediaItem;

  @override
  void initState() {
    super.initState();
    if (widget.mediaItem != null) {
      selectedMediaItem = widget.mediaItem;
      selectedType = widget.mediaItem!.type;
    }
  }

  Future<void> _searchMedia(String query) async {
    if (query.length < 2) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }
    setState(() {
      isSearching = true;
    });
    try {
      final results = await SearchService.searchAll(query, selectedType);
      setState(() {
        searchResults = results;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        isSearching = false;
      });
      print('Search error: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mediaItem != null ? 'Rate & Review' : 'Log Media'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.mediaItem == null) ...[
              Text(
                'Media Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: MediaType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.toString().split('.').last),
                    selected: selectedType == type,
                    onSelected: (selected) {
                      setState(() {
                        selectedType = type;
                        searchResults = [];
                        selectedMediaItem = null;
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 24),
              Text(
                'Search for ${selectedType.toString().split('.').last}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search for ${selectedType.toString().split('.').last}...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: isSearching 
                    ? Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                ),
                onChanged: (value) {
                  _searchMedia(value);
                },
              ),
              SizedBox(height: 16),
              if (searchResults.isNotEmpty) ...[
                Text(
                  'Search Results',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  height: 200,
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final item = searchResults[index];
                      return Card(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              item.coverUrl,
                              width: 50,
                              height: 75,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 50,
                                  height: 75,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image, color: Colors.grey[600]),
                                );
                              },
                            ),
                          ),
                          title: Text(item.title),
                          subtitle: Text(item.creator),
                          onTap: () {
                            setState(() {
                              selectedMediaItem = item;
                              searchController.text = item.title;
                              searchResults = [];
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
              ],
              if (selectedMediaItem != null) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          selectedMediaItem!.coverUrl,
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 90,
                              color: Colors.grey[300],
                              child: Icon(Icons.image, color: Colors.grey[600]),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedMediaItem!.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'by ${selectedMediaItem!.creator}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            selectedMediaItem = null;
                            searchController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],
            ] else ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.mediaItem!.coverUrl,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 90,
                            color: Colors.grey[300],
                            child: Icon(Icons.image, color: Colors.grey[600]),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.mediaItem!.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'by ${widget.mediaItem!.creator}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],
            Text(
              'Date Logged',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey[600]),
                    SizedBox(width: 12),
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Your Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      userRating = index + 1.0;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < (userRating ?? 0) ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 24),
            Text(
              'Your Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Write your thoughts...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  userReview = value;
                });
              },
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (widget.mediaItem != null || selectedMediaItem != null) ? () async {
                  final mediaToSave = widget.mediaItem ?? selectedMediaItem!;
                  final savedMedia = mediaToSave.copyWith(
                    loggedDate: selectedDate,
                    rating: userRating,
                    review: userReview.isNotEmpty ? userReview : null,
                  );
                  try {
                    await LogService.saveLog(
                      mediaItem: savedMedia,
                      loggedDate: selectedDate,
                      rating: userRating,
                      review: userReview.isNotEmpty ? userReview : null,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Media logged successfully!'),
                      ),
                    );
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving log: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Log Media',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 