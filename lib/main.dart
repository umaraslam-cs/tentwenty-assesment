import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/network/api_client.dart';
import 'models/cached_movie.dart';
import 'routes/app_router.dart';
import 'services/connectivity/connectivity_service.dart';
import 'services/movie/i_movie_service.dart';
import 'services/movie/movie_service.dart';
import 'services/storage/local_storage_service.dart';
import 'viewmodels/movie/movie_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(CachedMovieAdapter());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider<Dio>(create: (_) => ApiClient().dio),

        // Connectivity service
        Provider<ConnectivityService>(
          create: (_) {
            final service = ConnectivityService();
            service.initialize(); // Initialize connectivity monitoring
            return service;
          },
          dispose: (_, service) => service.dispose(),
        ),

        // Local storage service
        Provider<LocalStorageService>(
          create: (_) {
            final service = LocalStorageService();
            service.initialize(); // Initialize Hive boxes
            return service;
          },
          dispose: (_, service) => service.dispose(),
        ),

        // Movie service
        Provider<IMovieService>(create: (context) => MovieService(context.read<Dio>())),

        // Movie ViewModel with all dependencies
        ChangeNotifierProvider<MovieViewModel>(
          create: (context) => MovieViewModel(
            context.read<IMovieService>(),
            context.read<LocalStorageService>(),
            context.read<ConnectivityService>(),
          ),
        ),

        // Add other repositories/services/viewmodels here as needed
      ],
      child: MaterialApp.router(
        title: 'TenTwenty Assessment',
        debugShowCheckedModeBanner: false,
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
