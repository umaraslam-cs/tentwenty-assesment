/// Response model for the discover movies API
class PopularMoviesResponse {
  final DateRange? dates;
  final int page;
  final List<MovieDetails> results;
  final int totalPages;
  final int totalResults;

  PopularMoviesResponse({
    this.dates,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory PopularMoviesResponse.fromJson(Map<String, dynamic> json) {
    return PopularMoviesResponse(
      dates: json['dates'] != null ? DateRange.fromJson(json['dates']) : null,
      page: json['page'] ?? 0,
      results: (json['results'] as List?)?.map((movieJson) => MovieDetails.fromJson(movieJson)).toList() ?? [],
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dates': dates?.toJson(),
      'page': page,
      'results': results.map((movie) => movie.toJson()).toList(),
      'total_pages': totalPages,
      'total_results': totalResults,
    };
  }
}

/// Date range model for the discover movies response
class DateRange {
  final String maximum;
  final String minimum;

  DateRange({required this.maximum, required this.minimum});

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(maximum: json['maximum'] ?? '', minimum: json['minimum'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'maximum': maximum, 'minimum': minimum};
  }
}

/// Detailed movie model from TMDB API
class MovieDetails {
  final bool adult;
  final String? backdropPath;
  final List<int> genreIds;
  final int id;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String? posterPath;
  final String releaseDate;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;

  MovieDetails({
    required this.adult,
    this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      adult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'],
      genreIds: (json['genre_ids'] as List?)?.cast<int>() ?? [],
      id: json['id'] ?? 0,
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      posterPath: json['poster_path'],
      releaseDate: json['release_date'] ?? '',
      title: json['title'] ?? '',
      video: json['video'] ?? false,
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adult': adult,
      'backdrop_path': backdropPath,
      'genre_ids': genreIds,
      'id': id,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'overview': overview,
      'popularity': popularity,
      'poster_path': posterPath,
      'release_date': releaseDate,
      'title': title,
      'video': video,
      'vote_average': voteAverage,
      'vote_count': voteCount,
    };
  }

  /// Convert MovieDetails to the existing Movie model for UI compatibility
  String get fullPosterUrl => posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  String get fullBackdropUrl => backdropPath != null ? 'https://image.tmdb.org/t/p/w780$backdropPath' : '';
}
