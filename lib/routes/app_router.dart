import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../models/movie_videos_response.dart';
import '../views/movies/movie_detail_screen.dart';
import '../views/movies/movie_list_screen.dart';
import '../views/movies/movie_player_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  // route paths
  static const String movieList = MovieListScreen.routeName;
  static const String movieDetail = MovieDetailScreen.routeName;
  static const String moviePlayer = MoviePlayerScreen.routeName;

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: movieList,
    routes: [
      GoRoute(path: movieList, builder: (context, state) => const MovieListScreen()),
      GoRoute(
        path: movieDetail,
        builder: (context, state) {
          final movie = state.extra as Movie;
          return MovieDetailScreen(movie: movie);
        },
      ),
      GoRoute(
        path: moviePlayer,
        builder: (context, state) {
          final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
          final MovieVideo video = extra['video'] as MovieVideo;
          final String movieTitle = extra['movieTitle'] as String;
          return MoviePlayerScreen(video: video, movieTitle: movieTitle);
        },
      ),
    ],
  );
}
