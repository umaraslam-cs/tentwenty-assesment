/// Movie model for the watch screen
class Movie {
  final String id;
  final String title;
  final String imageUrl;
  final double? rating;
  final String? genre;
  final String? duration;
  final String? releaseYear;
  final String? overview;
  final String? backdropUrl;

  Movie({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.rating,
    this.genre,
    this.duration,
    this.releaseYear,
    this.overview,
    this.backdropUrl,
  });

  // Factory constructor for creating a Movie from JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      rating: json['rating']?.toDouble(),
      genre: json['genre'] as String?,
      duration: json['duration'] as String?,
      releaseYear: json['releaseYear'] as String?,
      overview: json['overview'] as String?,
      backdropUrl: json['backdropUrl'] as String?,
    );
  }

  // Convert Movie to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'rating': rating,
      'genre': genre,
      'duration': duration,
      'releaseYear': releaseYear,
      'overview': overview,
      'backdropUrl': backdropUrl,
    };
  }
}
