import 'package:hive/hive.dart';

import 'movie.dart';

part 'cached_movie.g.dart';

/// Cached movie model for local storage with essential fields only
@HiveType(typeId: 0)
class CachedMovie extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String releaseDate;

  @HiveField(3)
  final String posterPath;

  @HiveField(4)
  final DateTime cachedAt;

  CachedMovie({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.posterPath,
    required this.cachedAt,
  });

  /// Factory constructor to create CachedMovie from Movie
  factory CachedMovie.fromMovie(Movie movie) {
    return CachedMovie(
      id: movie.id,
      title: movie.title,
      releaseDate: movie.releaseYear ?? '',
      posterPath: movie.imageUrl,
      cachedAt: DateTime.now(),
    );
  }

  /// Convert CachedMovie to Movie for UI compatibility
  Movie toMovie() {
    return Movie(id: id, title: title, imageUrl: posterPath, releaseYear: releaseDate.isNotEmpty ? releaseDate : null);
  }

  /// Check if the cached movie is stale (older than specified duration)
  bool isStale({Duration maxAge = const Duration(hours: 24)}) {
    return DateTime.now().difference(cachedAt) > maxAge;
  }

  @override
  String toString() {
    return 'CachedMovie{id: $id, title: $title, releaseDate: $releaseDate, cachedAt: $cachedAt}';
  }
}
