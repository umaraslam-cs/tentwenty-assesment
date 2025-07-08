/// Movie videos response model from TMDB API
class MovieVideosResponse {
  final int id;
  final List<MovieVideo> results;

  MovieVideosResponse({required this.id, required this.results});

  factory MovieVideosResponse.fromJson(Map<String, dynamic> json) {
    return MovieVideosResponse(
      id: json['id'] ?? 0,
      results: (json['results'] as List?)?.map((v) => MovieVideo.fromJson(v)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'results': results.map((v) => v.toJson()).toList()};
  }

  /// Get the first official trailer video
  MovieVideo? get officialTrailer {
    return results
        .where((video) => video.type == 'Trailer' && video.official && video.site == 'YouTube')
        .cast<MovieVideo?>()
        .firstWhere((video) => video != null, orElse: () => null);
  }

  /// Get all trailer videos
  List<MovieVideo> get trailers {
    return results.where((video) => video.type == 'Trailer' && video.site == 'YouTube').toList();
  }
}

/// Individual movie video model
class MovieVideo {
  final String iso6391;
  final String iso31661;
  final String name;
  final String key;
  final String site;
  final int size;
  final String type;
  final bool official;
  final String publishedAt;
  final String id;

  MovieVideo({
    required this.iso6391,
    required this.iso31661,
    required this.name,
    required this.key,
    required this.site,
    required this.size,
    required this.type,
    required this.official,
    required this.publishedAt,
    required this.id,
  });

  factory MovieVideo.fromJson(Map<String, dynamic> json) {
    return MovieVideo(
      iso6391: json['iso_639_1'] ?? '',
      iso31661: json['iso_3166_1'] ?? '',
      name: json['name'] ?? '',
      key: json['key'] ?? '',
      site: json['site'] ?? '',
      size: json['size'] ?? 0,
      type: json['type'] ?? '',
      official: json['official'] ?? false,
      publishedAt: json['published_at'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iso_639_1': iso6391,
      'iso_3166_1': iso31661,
      'name': name,
      'key': key,
      'site': site,
      'size': size,
      'type': type,
      'official': official,
      'published_at': publishedAt,
      'id': id,
    };
  }

  /// Get YouTube URL for the video
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';

  /// Get YouTube thumbnail URL
  String get thumbnailUrl => 'https://img.youtube.com/vi/$key/maxresdefault.jpg';

  /// Check if this is a trailer
  bool get isTrailer => type == 'Trailer';

  /// Check if this is official content
  bool get isOfficial => official;
}
