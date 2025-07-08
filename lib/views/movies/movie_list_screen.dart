import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/movie.dart';
import '../../utils/custom_app_bar.dart';
import '../../utils/custom_bottom_nav_bar.dart';
import '../../utils/extensions.dart';
import 'components/movie_card.dart';
import '../../viewmodels/movie/movie_viewmodel.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  static const String routeName = '/movie-list';
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  BottomNavTab currentTab = BottomNavTab.watch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieViewModel>().loadMovies();
    });
  }

  void _onSearchPressed() {
    // TODO: Implement search functionality
    debugPrint('Search pressed');
  }

  void _onMovieTapped(Movie movie) {
    // Navigate to movie detail screen
    context.push(MovieDetailScreen.routeName, extra: movie);
  }

  void _onTabChanged(BottomNavTab tab) {
    setState(() {
      currentTab = tab;
    });
    // TODO: Handle navigation to different screens based on tab
    debugPrint('Tab changed to: $tab');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CustomAppBar(title: 'Watch', onSearchPressed: _onSearchPressed),
      body: Consumer<MovieViewModel>(
        builder: (context, movieViewModel, child) {
          if (movieViewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.inactiveTab),
                  16.h,
                  Text(
                    movieViewModel.errorMessage ?? 'An error occurred',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.inactiveTab),
                    textAlign: TextAlign.center,
                  ),
                  16.h,
                  ElevatedButton(
                    onPressed: () {
                      movieViewModel.clearError();
                      movieViewModel.loadMovies();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return movieViewModel.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryText))
              : RefreshIndicator(
                  onRefresh: movieViewModel.refreshMovies,
                  color: AppColors.primaryText,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
                          bottom: 100, // Extra padding for bottom nav
                        ),
                        sliver: movieViewModel.movies.isEmpty
                            ? SliverFillRemaining(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.movie_outlined, size: 64, color: AppColors.inactiveTab),
                                      16.h,
                                      Text(
                                        'No movies found',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(color: AppColors.inactiveTab),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate((context, index) {
                                  final movie = movieViewModel.movies[index];
                                  return MovieCard(movie: movie, onTap: () => _onMovieTapped(movie));
                                }, childCount: movieViewModel.movies.length),
                              ),
                      ),
                    ],
                  ),
                );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(currentTab: currentTab, onTabChanged: _onTabChanged),
    );
  }
}
