import 'dart:async';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/detail_service.dart';
import '../services/music_player_service.dart';
import 'log_page.dart';
import 'select_season_screen.dart';

class MediaDetailPage extends StatefulWidget {
  final MediaItem mediaItem;
  MediaDetailPage({required this.mediaItem});
  @override
  _MediaDetailPageState createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  Map<String, dynamic> _mediaDetails = {};
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  double _averageRating = 0.0;
  Map<int, int> _ratingDistribution = {};
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Initialize music player
    MusicPlayerService.initialize();
    // Start timer to update UI
    _startUpdateTimer();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch media details from API
      final details = await DetailService.fetchMediaDetails(widget.mediaItem);
      
      // Fetch ratings and comments from Firestore
      final reviews = await DetailService.fetchRatingsAndComments(widget.mediaItem.id);
      
      // Calculate average rating and distribution
      final avgRating = DetailService.calculateAverageRating(reviews);
      final distribution = DetailService.getRatingDistribution(reviews);

      setState(() {
        _mediaDetails = details;
        _reviews = reviews;
        _averageRating = avgRating;
        _ratingDistribution = distribution;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Clean up timer when widget is disposed
    _updateTimer?.cancel();
    super.dispose();
  }

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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                                    '${_averageRating > 0 ? _averageRating.toStringAsFixed(1) : 'Not rated'}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (_reviews.isNotEmpty) ...[
                                    SizedBox(width: 8),
                                    Text(
                                      '(${_reviews.length} reviews)',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
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
                        if (widget.mediaItem.type == MediaType.music) ...[
                          Text(
                            'Sample Track',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildMusicPlayer(),
                          SizedBox(height: 24),
                    
                        ] else ...[
                          Text(
                            'About',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildMediaInfo(),
                        ],
                        SizedBox(height: 24),
                        if (_reviews.isNotEmpty) ...[
                          Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildRatingDistribution(),
                          SizedBox(height: 16),
                          _buildReviewsList(),
                        ] else ...[
                          Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Center(
                              child: Text(
                                'No reviews yet. Be the first to review!',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRatingDistribution() {
    if (_ratingDistribution.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating Distribution',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 12),
          ...List.generate(5, (index) {
            final rating = 5 - index;
            final count = _ratingDistribution[rating] ?? 0;
            final percentage = _reviews.isNotEmpty ? (count / _reviews.length * 100) : 0.0;
            
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text('$rating', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('$count', style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMediaInfo() {
    final description = _mediaDetails['description'] ?? 'No description available';
    
    switch (widget.mediaItem.type) {
      case MediaType.movie:
        final cast = _mediaDetails['cast'] as List? ?? [];
        final genres = _mediaDetails['genres'] as List? ?? [];
        final releaseDate = _mediaDetails['releaseDate'] ?? '';
        final runtime = _mediaDetails['runtime'] ?? 0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            if (cast.isNotEmpty)
              Text(
                'Cast: ${cast.take(3).join(', ')}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (cast.isNotEmpty) SizedBox(height: 8),
            if (genres.isNotEmpty)
              Text(
                'Genre: ${genres.join(', ')}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (genres.isNotEmpty) SizedBox(height: 8),
            if (releaseDate.isNotEmpty)
              Text(
                'Release Year: ${releaseDate.split('-')[0]}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (runtime > 0) ...[
              if (releaseDate.isNotEmpty) SizedBox(height: 8),
              Text(
                'Runtime: ${runtime} minutes',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ],
        );
      case MediaType.tvShow:
        final cast = _mediaDetails['cast'] as List? ?? [];
        final genres = _mediaDetails['genres'] as List? ?? [];
        final firstAirDate = _mediaDetails['firstAirDate'] ?? '';
        final numberOfSeasons = _mediaDetails['numberOfSeasons'] ?? 0;
        final numberOfEpisodes = _mediaDetails['numberOfEpisodes'] ?? 0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            if (cast.isNotEmpty)
              Text(
                'Cast: ${cast.take(3).join(', ')}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (cast.isNotEmpty) SizedBox(height: 8),
            if (genres.isNotEmpty)
              Text(
                'Genre: ${genres.join(', ')}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (genres.isNotEmpty) SizedBox(height: 8),
            if (firstAirDate.isNotEmpty)
              Text(
                'First Aired: ${firstAirDate.split('-')[0]}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (numberOfSeasons > 0) ...[
              if (firstAirDate.isNotEmpty) SizedBox(height: 8),
              Text(
                'Seasons: $numberOfSeasons',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
            if (numberOfEpisodes > 0) ...[
              if (numberOfSeasons > 0) SizedBox(height: 8),
              Text(
                'Episodes: $numberOfEpisodes',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ],
        );
      case MediaType.book:
        final authors = _mediaDetails['authors'] as List? ?? [];
        final subjects = _mediaDetails['subjects'] as List? ?? [];
        final firstPublished = _mediaDetails['firstPublished'] ?? '';
        final pages = _mediaDetails['pages'] ?? 0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            if (authors.isNotEmpty)
              Text(
                'Author: ${authors.join(', ')}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (authors.isNotEmpty) SizedBox(height: 8),
            if (pages > 0)
              Text(
                'Pages: $pages',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (pages > 0) SizedBox(height: 8),
            if (subjects.isNotEmpty)
              Text(
                'Subjects: ${subjects.take(3).join(', ')}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (subjects.isNotEmpty) SizedBox(height: 8),
            if (firstPublished.isNotEmpty)
              Text(
                'Published: $firstPublished',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
          ],
        );
      case MediaType.music:
        return _buildMusicInfo();
      case MediaType.game:
        final developer = _mediaDetails['developer'] ?? '';
        final publisher = _mediaDetails['publisher'] ?? '';
        final genres = _mediaDetails['genres'] as List? ?? [];
        final platforms = _mediaDetails['platforms'] as List? ?? [];
        final releaseDate = _mediaDetails['releaseDate'] ?? '';
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 16),
            if (developer.isNotEmpty)
              Text(
                'Developer: $developer',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (developer.isNotEmpty) SizedBox(height: 8),
            if (publisher.isNotEmpty)
              Text(
                'Publisher: $publisher',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (publisher.isNotEmpty) SizedBox(height: 8),
            if (genres.isNotEmpty)
              Text(
                'Genre: ${genres.join(', ')}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (genres.isNotEmpty) SizedBox(height: 8),
            if (platforms.isNotEmpty)
              Text(
                'Platforms: ${platforms.take(3).join(', ')}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            if (platforms.isNotEmpty) SizedBox(height: 8),
            if (releaseDate.isNotEmpty)
              Text(
                'Release Year: ${releaseDate.split('-')[0]}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
          ],
        );
    }
  }

  Widget _buildMusicInfo() {
    final description = _mediaDetails['description'] ?? 'No description available';
    final artist = _mediaDetails['artist'] ?? '';
    final genre = _mediaDetails['genre'] ?? '';
    final releaseDate = _mediaDetails['releaseDate'] ?? '';
    final trackCount = _mediaDetails['trackCount'] ?? 0;
    final price = _mediaDetails['price'] ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        SizedBox(height: 16),
        if (artist.isNotEmpty)
          Text(
            'Artist: $artist',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        if (artist.isNotEmpty) SizedBox(height: 8),
        if (trackCount > 0)
          Text(
            'Tracks: $trackCount songs',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        if (trackCount > 0) SizedBox(height: 8),
        if (genre.isNotEmpty)
          Text(
            'Genre: $genre',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        if (genre.isNotEmpty) SizedBox(height: 8),
        if (releaseDate.isNotEmpty)
          Text(
            'Released: ${releaseDate.split('T')[0]}',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        if (price.isNotEmpty) ...[
          if (releaseDate.isNotEmpty) SizedBox(height: 8),
          Text(
            'Price: \$$price',
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ],
    );
  }

  Widget _buildMusicPlayer() {
    final artist = _mediaDetails['artist'] ?? '';
    final trackCount = _mediaDetails['trackCount'] ?? 0;
    final sampleTrackName = _mediaDetails['sampleTrackName'] ?? 'Sample Track';
    final previewUrl = _mediaDetails['previewUrl'];
    
    // Get current player state
    final isPlaying = MusicPlayerService.isPlaying;
    final position = MusicPlayerService.position;
    final duration = MusicPlayerService.duration;
    final isCurrentTrack = MusicPlayerService.currentUrl == previewUrl;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Album Art and Info
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.mediaItem.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.music_note, size: 32, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mediaItem.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    if (artist.isNotEmpty)
                      Text(
                        artist,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    SizedBox(height: 4),
                    if (trackCount > 0)
                      Text(
                        '$trackCount tracks',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Sample Track Info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.music_note, color: Colors.deepPurple, size: 20),
                    SizedBox(width: 8),
                                             Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 sampleTrackName,
                                 style: TextStyle(
                                   fontWeight: FontWeight.bold,
                                   fontSize: 16,
                                 ),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                               ),
                               Text(
                                 previewUrl != null ? 'Preview available' : 'No preview available',
                                 style: TextStyle(
                                   fontSize: 12,
                                   color: Colors.grey[600],
                                 ),
                               ),
                             ],
                           ),
                         ),
                  ],
                ),
                SizedBox(height: 16),
                
                                 // Progress Bar
                 Container(
                   height: 4,
                   decoration: BoxDecoration(
                     color: Colors.grey[300],
                     borderRadius: BorderRadius.circular(2),
                   ),
                   child: FractionallySizedBox(
                     alignment: Alignment.centerLeft,
                     widthFactor: isCurrentTrack && duration.inMilliseconds > 0 
                         ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
                         : 0.0,
                     child: Container(
                       decoration: BoxDecoration(
                         color: Colors.deepPurple,
                         borderRadius: BorderRadius.circular(2),
                       ),
                     ),
                   ),
                 ),
                SizedBox(height: 8),
                
                                 // Time and Controls
                 Row(
                   children: [
                     Text(
                       isCurrentTrack ? _formatDuration(position) : '0:00',
                       style: TextStyle(
                         fontSize: 12,
                         color: Colors.grey[600],
                       ),
                     ),
                     Spacer(),
                     Text(
                       isCurrentTrack ? _formatDuration(duration) : '0:00',
                       style: TextStyle(
                         fontSize: 12,
                         color: Colors.grey[600],
                       ),
                     ),
                   ],
                 ),
                SizedBox(height: 16),
                
                // Play Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous, size: 32),
                      onPressed: () {},
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                                             child: IconButton(
                         icon: Icon(
                           isCurrentTrack && isPlaying ? Icons.pause : Icons.play_arrow, 
                           size: 32, 
                           color: Colors.white
                         ),
                         onPressed: () async {
                           if (previewUrl != null) {
                             if (isCurrentTrack && isPlaying) {
                               // Pause current track
                               await MusicPlayerService.pause();
                             } else {
                               // Play or resume track
                               await MusicPlayerService.play(previewUrl);
                             }
                             // Trigger UI update
                             setState(() {});
                           } else {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text('No preview available for this track'),
                                 duration: Duration(seconds: 2),
                               ),
                             );
                           }
                         },
                       ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.skip_next, size: 32),
                      onPressed: () {},
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (mounted && widget.mediaItem.type == MediaType.music) {
        setState(() {
          // This will trigger a rebuild to update the progress bar and time
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildReviewsList() {
    return Column(
      children: _reviews.map((review) {
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
                    review['user'] ?? 'Anonymous',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 8),
              if (review['review']?.isNotEmpty == true)
                Text(
                  review['review'],
                  style: TextStyle(fontSize: 14),
                ),
              if (review['review']?.isNotEmpty == true) SizedBox(height: 8),
              Text(
                review['date'] ?? '',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 