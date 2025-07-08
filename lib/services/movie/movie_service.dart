import 'package:dio/dio.dart';

import '../../core/constants/app_urls.dart';
import '../../core/network/exceptions.dart';
import '../../models/popular_movies_response.dart';
import '../../models/movie.dart';
import '../../models/movie_detail_response.dart';
import '../../models/movie_videos_response.dart';
import 'i_movie_service.dart';

/// Concrete implementation of IMovieService using TMDB API
class MovieService implements IMovieService {
  final Dio dio;

  MovieService(this.dio);

  /// Convert MovieDetails to Movie for UI compatibility
  Movie _convertToMovie(MovieDetails movieDetails) {
    return Movie(
      id: movieDetails.id.toString(),
      title: movieDetails.title,
      imageUrl: movieDetails.fullPosterUrl,
      rating: movieDetails.voteAverage,
      genre: movieDetails.genreIds.isNotEmpty ? 'Genre IDs: ${movieDetails.genreIds.join(", ")}' : null,
      duration: null, // Not available in discover API
      releaseYear: movieDetails.releaseDate.isNotEmpty
          ? DateTime.tryParse(movieDetails.releaseDate)?.year.toString()
          : null,
      overview: movieDetails.overview.isNotEmpty ? movieDetails.overview : null,
      backdropUrl: movieDetails.fullBackdropUrl,
    );
  }

  /// Get all movies using popular movies from TMDB
  /// Throws [ApiException] on error.
  @override
  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await dio.get(AppUrls.upcomingMovies);
      final discoverResponse = PopularMoviesResponse.fromJson(response.data);
      return discoverResponse.results.map((movieDetails) => _convertToMovie(movieDetails)).toList();
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Unknown error', statusCode: e.response?.statusCode);
    } catch (e) {
      throw AppException('Unexpected error: $e');
    }
  }

  /// Get detailed movie information from TMDB API
  /// Throws [ApiException] on error.
  @override
  Future<MovieDetailResponse> getMovieDetails(int movieId, {String language = 'en-US'}) async {
    try {
      final response = await dio.get('${AppUrls.movieDetails}/$movieId', queryParameters: {'language': language});

      return MovieDetailResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Unknown error', statusCode: e.response?.statusCode);
    } catch (e) {
      throw AppException('Unexpected error: $e');
    }
  }

  /// Get movie videos (trailers, teasers, etc.) from TMDB API
  /// Throws [ApiException] on error.
  @override
  Future<MovieVideosResponse> getMovieVideos(int movieId, {String language = 'en-US'}) async {
    try {
      final response = await dio.get('${AppUrls.movieVideos}/$movieId/videos', queryParameters: {'language': language});

      return MovieVideosResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Unknown error', statusCode: e.response?.statusCode);
    } catch (e) {
      throw AppException('Unexpected error: $e');
    }
  }
}
