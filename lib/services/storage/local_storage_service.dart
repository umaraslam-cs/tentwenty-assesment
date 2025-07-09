import 'package:hive_flutter/hive_flutter.dart';

import '../../models/cached_movie.dart';
import '../../models/movie.dart';

/// Service for managing local storage using Hive
class LocalStorageService {
  static const String _moviesBoxName = 'movies_cache';
  Box<CachedMovie>? _moviesBox;

  /// Initialize Hive and open the movies box
  Future<void> initialize() async {
    try {
      // Only open if not already opened
      if (!Hive.isBoxOpen(_moviesBoxName)) {
        _moviesBox = await Hive.openBox<CachedMovie>(_moviesBoxName);
      } else {
        _moviesBox = Hive.box<CachedMovie>(_moviesBoxName);
      }
    } catch (e) {
      throw Exception('Failed to initialize local storage: $e');
    }
  }

  /// Ensure the box is open before operations
  Future<Box<CachedMovie>> _ensureBoxOpen() async {
    if (_moviesBox == null || !_moviesBox!.isOpen) {
      await initialize();
    }
    return _moviesBox!;
  }

  /// Cache a list of movies to local storage
  Future<void> cacheMovies(List<Movie> movies) async {
    try {
      final box = await _ensureBoxOpen();

      // Clear existing cache before adding new movies
      await box.clear();

      // Convert movies to cached movies and store
      final cachedMovies = movies.map((movie) => CachedMovie.fromMovie(movie)).toList();

      // Store each movie with its ID as key for easy retrieval
      for (final cachedMovie in cachedMovies) {
        await box.put(cachedMovie.id, cachedMovie);
      }
    } catch (e) {
      throw Exception('Failed to cache movies: $e');
    }
  }

  /// Retrieve cached movies from local storage
  Future<List<Movie>> getCachedMovies({Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final box = await _ensureBoxOpen();

      if (box.isEmpty) {
        return [];
      }

      final cachedMovies = box.values.toList();

      // Filter out stale movies if maxAge is specified
      final validMovies = cachedMovies.where((cachedMovie) => !cachedMovie.isStale(maxAge: maxAge)).toList();

      // If all movies are stale, return empty list
      if (validMovies.isEmpty && cachedMovies.isNotEmpty) {
        await clearCache(); // Clean up stale data
        return [];
      }

      // Convert cached movies back to Movie objects
      return validMovies.map((cachedMovie) => cachedMovie.toMovie()).toList();
    } catch (e) {
      throw Exception('Failed to retrieve cached movies: $e');
    }
  }

  /// Check if there are valid cached movies available
  Future<bool> hasCachedMovies({Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final box = await _ensureBoxOpen();

      if (box.isEmpty) {
        return false;
      }

      // Check if any cached movie is still valid
      final hasValidMovies = box.values.any((cachedMovie) => !cachedMovie.isStale(maxAge: maxAge));

      return hasValidMovies;
    } catch (e) {
      return false; // Return false on error to trigger API call
    }
  }

  /// Clear all cached movies
  Future<void> clearCache() async {
    try {
      final box = await _ensureBoxOpen();
      await box.clear();
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  /// Get cache information for debugging
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final box = await _ensureBoxOpen();

      final totalMovies = box.length;
      final validMovies = box.values.where((movie) => !movie.isStale()).length;
      final oldestCacheDate = box.values.isEmpty
          ? null
          : box.values.map((movie) => movie.cachedAt).reduce((a, b) => a.isBefore(b) ? a : b);

      return {
        'totalMovies': totalMovies,
        'validMovies': validMovies,
        'staleMovies': totalMovies - validMovies,
        'oldestCacheDate': oldestCacheDate?.toIso8601String(),
        'isBoxOpen': box.isOpen,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Close the storage service
  Future<void> close() async {
    try {
      if (_moviesBox?.isOpen == true) {
        await _moviesBox!.close();
      }
    } catch (e) {
      // Log error but don't throw as this is cleanup
      print('Error closing local storage: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    // Note: We don't close the box here as it might be used by other parts of the app
    // The box will be closed when the app terminates
    _moviesBox = null;
  }
}
