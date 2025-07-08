import '../../models/movie.dart';
import '../../models/movie_detail_response.dart';
import '../../models/movie_videos_response.dart';

/// Interface for movie service
abstract class IMovieService {
  /// Get all movies
  Future<List<Movie>> getPopularMovies();

  /// Get detailed movie information from TMDB API
  Future<MovieDetailResponse> getMovieDetails(int movieId, {String language = 'en-US'});

  /// Get movie videos (trailers, teasers, etc.) from TMDB API
  Future<MovieVideosResponse> getMovieVideos(int movieId, {String language = 'en-US'});
}
