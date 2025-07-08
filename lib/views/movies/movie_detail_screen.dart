import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/movie.dart';
import '../../utils/extensions.dart';
import '../../utils/primary_button.dart';
import '../../utils/toast_utils.dart';
import '../../viewmodels/movie/movie_viewmodel.dart';
import 'components/genre_tag.dart';
import 'movie_player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  static const String routeName = '/movie-detail';
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late MovieViewModel movieViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load detailed movie information and videos
      movieViewModel = context.read<MovieViewModel>();
      final movieId = int.tryParse(widget.movie.id);
      if (movieId != null) {
        movieViewModel.loadMovieDetail(movieId);
        movieViewModel.loadMovieVideos(movieId);
      }
    });
  }

  @override
  void dispose() {
    // Clear movie detail and videos data when leaving the screen
    movieViewModel.clearMovieDetail();
    movieViewModel.clearMovieVideos();
    super.dispose();
  }

  void _watchTrailer() {
    final movieViewModel = context.read<MovieViewModel>();
    final officialTrailer = movieViewModel.officialTrailer;

    if (officialTrailer != null) {
      // Navigate to full-screen video player
      context.push(MoviePlayerScreen.routeName, extra: {'video': officialTrailer, 'movieTitle': widget.movie.title});
    } else {
      // Show error if no trailer available
      AppToast.showError('No trailer available for this movie');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Consumer<MovieViewModel>(
        builder: (context, movieViewModel, child) {
          if (movieViewModel.hasError) {
            return _buildErrorState(movieViewModel);
          }

          final movieDetail = movieViewModel.movieDetail;
          final isLoading = movieViewModel.isLoadingMovieDetail;
          final isLoadingVideos = movieViewModel.isLoadingMovieVideos;
          final hasTrailer = movieViewModel.officialTrailer != null;

          // Check device orientation
          final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

          if (isLandscape) {
            return _buildLandscapeLayout(context, movieViewModel, movieDetail, isLoading, isLoadingVideos, hasTrailer);
          } else {
            return _buildPortraitLayout(context, movieViewModel, movieDetail, isLoading, isLoadingVideos, hasTrailer);
          }
        },
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    MovieViewModel movieViewModel,
    movieDetail,
    bool isLoading,
    bool isLoadingVideos,
    bool hasTrailer,
  ) {
    return CustomScrollView(
      slivers: [
        // Hero Section with Movie Backdrop
        SliverAppBar(
          expandedHeight: context.height * 0.5,
          pinned: true,
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 13),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios, color: AppColors.white, size: 18),
              ),
            ),
          ),
          title: Text(
            'Watch',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.white),
          ),
          centerTitle: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Movie Backdrop Image
                Image.network(
                  movieDetail?.fullBackdropUrl ?? widget.movie.backdropUrl ?? widget.movie.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primaryText,
                      child: const Icon(Icons.movie, size: 100, color: AppColors.white),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: context.height * 0.25,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 1.0)],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
                // Movie Logo/Title and Release Date
                Positioned(
                  left: 66,
                  bottom: 144,
                  right: 66,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Movie Title (acts as logo)
                      Container(
                        height: 30,
                        alignment: Alignment.center,
                        child: Text(
                          movieDetail?.title ?? widget.movie.title,
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                      16.h,
                      // Release Date
                      Text(
                        movieDetail?.formattedReleaseDate ?? _getFormattedReleaseDate(),
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.white),
                        textAlign: TextAlign.center,
                      ),
                      12.h,
                    ],
                  ),
                ),
                // Action Buttons
                Positioned(left: 66, bottom: 34, right: 66, child: _buildActionButtons(isLoadingVideos, hasTrailer)),
              ],
            ),
          ),
        ),
        // Content Section
        SliverToBoxAdapter(
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryText)),
                )
              : Padding(padding: const EdgeInsets.fromLTRB(40, 30, 40, 40), child: _buildMovieContent(movieDetail)),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    MovieViewModel movieViewModel,
    movieDetail,
    bool isLoading,
    bool isLoadingVideos,
    bool hasTrailer,
  ) {
    return Row(
      children: [
        // Left side - Movie Image with Buttons
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(movieDetail?.fullBackdropUrl ?? widget.movie.backdropUrl ?? widget.movie.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.8)],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios, color: AppColors.white, size: 20),
                    ),
                  ),
                ),
                // Movie title and content
                Positioned(
                  left: 32,
                  right: 32,
                  bottom: context.height * 0.35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Movie Title
                      Text(
                        movieDetail?.title ?? widget.movie.title,
                        style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      12.h,
                      // Release Date
                      Text(
                        movieDetail?.formattedReleaseDate ?? _getFormattedReleaseDate(),
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Positioned(
                  left: 32,
                  right: 32,
                  bottom: context.height * 0.05,
                  child: _buildActionButtons(isLoadingVideos, hasTrailer),
                ),
              ],
            ),
          ),
        ),
        // Right side - Content
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            color: AppColors.white,
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 32,
                    right: 32,
                    bottom: 16,
                  ),
                  child: Text(
                    'Watch',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primaryText))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: _buildMovieContent(movieDetail),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isLoadingVideos, bool hasTrailer) {
    return Column(
      children: [
        // Get Tickets Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: PrimaryButton(
            onPressed: () {
              // TODO: Implement ticket booking
              debugPrint('Get Tickets pressed for ${widget.movie.title}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Get Tickets',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        10.h,
        // Watch Trailer Button (Outlined)
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton.icon(
            onPressed: isLoadingVideos ? null : _watchTrailer,
            icon: isLoadingVideos
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : Icon(hasTrailer ? Icons.play_arrow : Icons.error_outline, color: AppColors.white, size: 16),
            label: Text(
              isLoadingVideos
                  ? 'Loading...'
                  : hasTrailer
                  ? 'Watch Trailer'
                  : 'No Trailer',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieContent(movieDetail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Genres Section
        Text(
          'Genres',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primaryText),
        ),
        14.h,
        _buildGenresList(movieDetail),
        28.h,
        // Divider Line
        Container(height: 1, color: Colors.black.withValues(alpha: 0.05)),
        15.h,
        // Overview Section
        Text(
          'Overview',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primaryText),
        ),
        14.h,
        Text(
          movieDetail?.overview ?? _getMovieOverview(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8F8F8F),
            height: 1.6,
          ),
        ),
        if (movieDetail != null) ...[
          28.h,
          // Additional Movie Info
          ..._buildMovieInfo(movieDetail),
        ],
        40.h,
      ],
    );
  }

  Widget _buildErrorState(MovieViewModel movieViewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.inactiveTab),
          16.h,
          Text(
            movieViewModel.errorMessage ?? 'An error occurred',
            style: GoogleFonts.poppins(fontSize: 16, color: AppColors.inactiveTab),
            textAlign: TextAlign.center,
          ),
          16.h,
          ElevatedButton(
            onPressed: () {
              movieViewModel.clearError();
              final movieId = int.tryParse(widget.movie.id);
              if (movieId != null) {
                movieViewModel.loadMovieDetail(movieId);
                movieViewModel.loadMovieVideos(movieId);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenresList(movieDetail) {
    final genres = movieDetail?.genreNames ?? _getGenresFromMovie();

    return Wrap(spacing: 5, runSpacing: 8, children: genres.map<Widget>((genre) => GenreTag(genre: genre)).toList());
  }

  List<Widget> _buildMovieInfo(movieDetail) {
    return [
      if (movieDetail.runtime != null) ...[_buildInfoRow('Runtime', movieDetail.formattedRuntime), 12.h],
      if (movieDetail.voteAverage > 0) ...[
        _buildInfoRow('Rating', '${movieDetail.voteAverage.toStringAsFixed(1)}/10'),
        12.h,
      ],
      if (movieDetail.revenue != null && movieDetail.revenue! > 0) ...[
        _buildInfoRow('Revenue', '\$${_formatCurrency(movieDetail.revenue!)}'),
        12.h,
      ],
      if (movieDetail.budget != null && movieDetail.budget! > 0) ...[
        _buildInfoRow('Budget', '\$${_formatCurrency(movieDetail.budget!)}'),
        12.h,
      ],
    ];
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryText),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF8F8F8F)),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }

  List<String> _getGenresFromMovie() {
    if (widget.movie.genre == null || widget.movie.genre!.isEmpty) {
      return ['Action', 'Thriller', 'Science', 'Fiction']; // Default genres
    }

    // Split genres by comma or other delimiters
    return widget.movie.genre!
        .split(RegExp(r'[,|&]'))
        .map((genre) => genre.trim())
        .where((genre) => genre.isNotEmpty)
        .toList();
  }

  String _getFormattedReleaseDate() {
    if (widget.movie.releaseYear != null) {
      return 'In theaters ${widget.movie.releaseYear}';
    }
    return 'Coming Soon';
  }

  String _getMovieOverview() {
    // Use real movie overview if available, otherwise use default
    return widget.movie.overview ??
        "As a collection of history's worst tyrants and criminal masterminds gather to plot a war to wipe out millions, one man must race against time to stop them. Discover the origins of the very first independent intelligence agency in The King's Man. The Comic Book \"The Secret Service\" by Mark Millar and Dave Gibbons.";
  }
}
