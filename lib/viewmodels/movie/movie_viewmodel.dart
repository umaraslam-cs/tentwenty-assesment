import 'package:flutter/foundation.dart';

import '../../core/network/exceptions.dart';
import '../../models/movie.dart';
import '../../models/movie_detail_response.dart';
import '../../models/movie_videos_response.dart';
import '../../services/movie/i_movie_service.dart';

/// ViewModel for managing movie-related state and business logic
class MovieViewModel extends ChangeNotifier {
  final IMovieService _movieService;

  MovieViewModel(this._movieService);

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

  /// Load all movies from TMDB API
  Future<void> loadMovies() async {
    _setLoading(true);
    _clearError();

    try {
      _movies = await _movieService.getPopularMovies();
      notifyListeners();
    } on ApiException catch (e) {
      _setError('Failed to load movies: ${e.message}');
    } on AppException catch (e) {
      _setError('App error: ${e.message}');
    } catch (e) {
      _setError('Unexpected error occurred');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh movies (pull to refresh) using TMDB API
  Future<void> refreshMovies() async {
    await loadMovies();
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
