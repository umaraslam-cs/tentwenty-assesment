import 'package:flutter/foundation.dart';

import '../../core/network/exceptions.dart';
import '../../models/movie.dart';
import '../../models/movie_detail_response.dart';
import '../../models/movie_videos_response.dart';
import '../../services/connectivity/connectivity_service.dart';
import '../../services/movie/i_movie_service.dart';
import '../../services/storage/local_storage_service.dart';

/// ViewModel for managing movie-related state and business logic
class MovieViewModel extends ChangeNotifier {
  final IMovieService _movieService;
  final LocalStorageService _localStorageService;
  final ConnectivityService _connectivityService;

  MovieViewModel(this._movieService, this._localStorageService, this._connectivityService);

  // State variables
  List<Movie> _movies = [];
  MovieDetailResponse? _movieDetail;
  MovieVideosResponse? _movieVideos;
  bool _isLoading = false;
  bool _isLoadingMovieDetail = false;
  bool _isLoadingMovieVideos = false;
  String? _errorMessage;

  // Getters
  List<Movie> get movies => _movies;
  MovieDetailResponse? get movieDetail => _movieDetail;
  MovieVideosResponse? get movieVideos => _movieVideos;
  bool get isLoading => _isLoading;
  bool get isLoadingMovieDetail => _isLoadingMovieDetail;
  bool get isLoadingMovieVideos => _isLoadingMovieVideos;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Load all movies with offline-first approach
  Future<void> loadMovies() async {
    _clearError();

    try {
      // First, check if we have cached data to avoid showing loader unnecessarily
      final hasCachedData = await _localStorageService.hasCachedMovies();

      // Only show loader if we don't have cached data
      if (!hasCachedData) {
        _setLoading(true);
      }

      // Load from cache if available (this will show movies instantly)
      await _loadFromCacheIfAvailable();

      // Check connectivity status
      final isOnline = await _connectivityService.checkConnectivity();

      if (isOnline) {
        // If online, fetch from API and update cache
        // This happens silently in background if we had cache
        await _loadFromApi();
      } else {
        // If offline, ensure we have cached data or show appropriate message
        await _handleOfflineState();
      }
    } catch (e) {
      await _handleLoadingError(e);
    } finally {
      // Ensure loading is always false at the end
      _setLoading(false);
    }
  }

  /// Load movies from cache if available and not stale
  /// Returns true if cached data was successfully loaded
  Future<bool> _loadFromCacheIfAvailable() async {
    try {
      final hasCachedMovies = await _localStorageService.hasCachedMovies();
      if (hasCachedMovies) {
        final cachedMovies = await _localStorageService.getCachedMovies();
        if (cachedMovies.isNotEmpty) {
          _movies = cachedMovies;
          notifyListeners();
          return true; // Successfully loaded cached data
        }
      }
      return false; // No cached data available
    } catch (e) {
      // If cache loading fails, continue with API call
      debugPrint('Failed to load from cache: $e');
      return false; // Cache loading failed
    }
  }

  /// Load movies from API and update cache
  Future<void> _loadFromApi() async {
    try {
      final apiMovies = await _movieService.getPopularMovies();
      _movies = apiMovies;
      notifyListeners();

      // Cache the movies for offline use
      await _localStorageService.cacheMovies(apiMovies);
    } on ApiException catch (e) {
      _setError('Failed to load movies: ${e.message}');
    } on AppException catch (e) {
      _setError('App error: ${e.message}');
    }
  }

  /// Handle offline state when no internet connection
  Future<void> _handleOfflineState() async {
    if (_movies.isEmpty) {
      // Try to load any cached movies, even if stale
      try {
        final cachedMovies = await _localStorageService.getCachedMovies(
          maxAge: const Duration(days: 30), // Allow older cache when offline
        );
        if (cachedMovies.isNotEmpty) {
          _movies = cachedMovies;
          notifyListeners();
        } else {
          _setError('No internet connection and no cached movies available');
        }
      } catch (e) {
        _setError('No internet connection and failed to load cached movies');
      }
    }
    // If we already have movies (from cache), don't show error
  }

  /// Handle loading errors with appropriate fallback
  Future<void> _handleLoadingError(dynamic error) async {
    // Try to fall back to cached data
    try {
      final cachedMovies = await _localStorageService.getCachedMovies(
        maxAge: const Duration(days: 7), // Allow slightly stale data on error
      );
      if (cachedMovies.isNotEmpty) {
        _movies = cachedMovies;
        notifyListeners();
        _setError('Using cached data - Unable to fetch latest movies');
        return;
      }
    } catch (cacheError) {
      debugPrint('Cache fallback failed: $cacheError');
    }

    // If no cache fallback available, show appropriate error
    _setError('Failed to load movies. Please check your connection and try again.');
  }

  /// Refresh movies (pull to refresh) with connectivity check
  Future<void> refreshMovies() async {
    // For refresh, we always want fresh data if possible
    final isOnline = await _connectivityService.checkConnectivity();

    if (isOnline) {
      await loadMovies();
    } else {
      // If offline during refresh, just reload from cache
      try {
        final cachedMovies = await _localStorageService.getCachedMovies(
          maxAge: const Duration(days: 30), // Allow older cache during refresh when offline
        );
        if (cachedMovies.isNotEmpty) {
          _movies = cachedMovies;
          notifyListeners();
          _setError('Offline - Showing cached data');
        } else {
          _setError('No internet connection and no cached data available');
        }
      } catch (e) {
        _setError('Failed to load cached data');
      }
    }
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  /// Load detailed movie information
  Future<void> loadMovieDetail(int movieId) async {
    _setLoadingMovieDetail(true);
    _clearError();

    try {
      _movieDetail = await _movieService.getMovieDetails(movieId);
      notifyListeners();
    } on ApiException catch (e) {
      _setError('Failed to load movie details: ${e.message}');
    } on AppException catch (e) {
      _setError('App error: ${e.message}');
    } catch (e) {
      _setError('Unexpected error occurred');
    } finally {
      _setLoadingMovieDetail(false);
    }
  }

  /// Clear movie detail data
  void clearMovieDetail() {
    _movieDetail = null;
  }

  /// Load movie videos (trailers, teasers, etc.)
  Future<void> loadMovieVideos(int movieId) async {
    _setLoadingMovieVideos(true);
    _clearError();

    try {
      _movieVideos = await _movieService.getMovieVideos(movieId);
      notifyListeners();
    } on ApiException catch (e) {
      _setError('Failed to load movie videos: ${e.message}');
    } on AppException catch (e) {
      _setError('App error: ${e.message}');
    } catch (e) {
      _setError('Unexpected error occurred');
    } finally {
      _setLoadingMovieVideos(false);
    }
  }

  /// Clear movie videos data
  void clearMovieVideos() {
    _movieVideos = null;
  }

  /// Get the official trailer for the current movie
  MovieVideo? get officialTrailer => _movieVideos?.officialTrailer;

  /// Get all trailers for the current movie
  List<MovieVideo> get trailers => _movieVideos?.trailers ?? [];

  /// Get connectivity status
  bool get isOnline => _connectivityService.isOnline;

  /// Get cache information for debugging
  Future<Map<String, dynamic>> getCacheInfo() async {
    return await _localStorageService.getCacheInfo();
  }

  /// Clear cache manually
  Future<void> clearCache() async {
    try {
      await _localStorageService.clearCache();
      _setError('Cache cleared successfully');
    } catch (e) {
      _setError('Failed to clear cache: $e');
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoadingMovieDetail(bool loading) {
    _isLoadingMovieDetail = loading;
    notifyListeners();
  }

  void _setLoadingMovieVideos(bool loading) {
    _isLoadingMovieVideos = loading;
    notifyListeners();
  }
}
