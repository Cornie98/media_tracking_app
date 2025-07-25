
enum MediaType { movie, book, tvShow, music, game }


class MediaItem {
  final String id; 
  final MediaType type;
  final String title; 
  final String creator; 
  final String coverUrl; 
  final DateTime? loggedDate; 
  final double? rating; 
  final String? review; 

  MediaItem({
    required this.id,
    required this.type,
    required this.title,
    required this.creator,
    required this.coverUrl,
    this.loggedDate,
    this.rating,
    this.review,
  });

  // Copy with method for easy updates
  MediaItem copyWith({
    String? id,
    MediaType? type,
    String? title,
    String? creator,
    String? coverUrl,
    DateTime? loggedDate,
    double? rating,
    String? review,
  }) {
    return MediaItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      creator: creator ?? this.creator,
      coverUrl: coverUrl ?? this.coverUrl,
      loggedDate: loggedDate ?? this.loggedDate,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }
}
