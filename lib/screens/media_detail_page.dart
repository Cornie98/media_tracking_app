import 'package:flutter/material.dart';
import '../models/media_item.dart';
import 'log_page.dart';
import 'select_season_screen.dart';

class MediaDetailPage extends StatefulWidget {
  final MediaItem mediaItem;
  MediaDetailPage({required this.mediaItem});
  @override
  _MediaDetailPageState createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mediaItem.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline),
            onPressed: () {
              if (widget.mediaItem.type == MediaType.tvShow) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectSeasonScreen(tvId: widget.mediaItem.id, showTitle: widget.mediaItem.title),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogPage(mediaItem: widget.mediaItem),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 300,
                    child: Image.network(
                      widget.mediaItem.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, size: 64),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mediaItem.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'by ${widget.mediaItem.creator}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              '${widget.mediaItem.rating?.toStringAsFixed(1) ?? 'Not rated'}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.mediaItem.type.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildMediaInfo(),
                  SizedBox(height: 24),
                  Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildReviewsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaInfo() {
    switch (widget.mediaItem.type) {
      case MediaType.movie:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A mind-bending thriller that explores the depths of dreams and reality.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Cast: Leonardo DiCaprio, Joseph Gordon-Levitt, Ellen Page',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Genre: Sci-Fi, Thriller',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Release Year: 2010',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        );
      case MediaType.tvShow:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A group of kids discover supernatural mysteries in their small town.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Cast: Millie Bobby Brown, Finn Wolfhard, Noah Schnapp',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Genre: Sci-Fi, Drama',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Seasons: 4',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        );
      case MediaType.book:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A classic fantasy novel about a hobbit\'s journey to reclaim a dwarf kingdom.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Pages: 366',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Genre: Fantasy, Adventure',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Published: 1937',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        );
      case MediaType.music:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Beatles\' iconic album featuring timeless classics.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.mediaItem.coverUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Come Together',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'The Beatles',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.play_circle_filled, size: 32),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Tracks: 17 songs',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Genre: Rock, Pop',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Released: 1969',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        );
    }
  }

  Widget _buildReviewsList() {
    final List<Map<String, dynamic>> reviews = [
      {
        'user': 'MovieFan123',
        'rating': 4.5,
        'review': 'Absolutely mind-blowing! The concept is executed perfectly.',
        'date': '2024-01-15',
      },
      {
        'user': 'CinemaLover',
        'rating': 4.0,
        'review': 'Great performances and stunning visuals. A must-watch.',
        'date': '2024-01-10',
      },
      {
        'user': 'FilmCritic',
        'rating': 5.0,
        'review': 'Christopher Nolan at his finest. Pure cinematic genius.',
        'date': '2024-01-05',
      },
    ];
    return Column(
      children: reviews.map((review) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    review['user'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review['rating'] ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                review['review'],
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                review['date'],
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 