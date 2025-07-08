import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/network/api_client.dart';
import 'routes/app_router.dart';
import 'services/movie/i_movie_service.dart';
import 'services/movie/movie_service.dart';
import 'viewmodels/movie/movie_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dio>(create: (_) => ApiClient().dio),
        Provider<IMovieService>(create: (context) => MovieService(context.read<Dio>())),
        ChangeNotifierProvider<MovieViewModel>(create: (context) => MovieViewModel(context.read<IMovieService>())),
        // Add other repositories/services/viewmodels here as needed
      ],
      child: MaterialApp.router(
        title: 'TenTwenty Assessment',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          // Set Poppins as the default font for the entire app
          textTheme: GoogleFonts.poppinsTextTheme(),
          // You can also apply to specific text themes if needed
          primaryTextTheme: GoogleFonts.poppinsTextTheme(),
          // Set default colors
          scaffoldBackgroundColor: AppColors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.white,
            titleTextStyle: GoogleFonts.poppins(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            iconTheme: const IconThemeData(color: AppColors.primaryText),
          ),
          // Set button themes with Poppins
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          // Set input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: GoogleFonts.poppins(),
            hintStyle: GoogleFonts.poppins(),
            helperStyle: GoogleFonts.poppins(),
            errorStyle: GoogleFonts.poppins(),
          ),
        ),
        routeInformationParser: AppRouter.router.routeInformationParser,
        routeInformationProvider: AppRouter.router.routeInformationProvider,
        routerDelegate: AppRouter.router.routerDelegate,
      ),
    );
  }
}
