# TenTwenty Assessment - Flutter Movie App

A Flutter application demonstrating movie browsing with mvvm architecture, offline-first approach, and modern development practices.

## Features

- Browse popular movies with detailed information
- Video player for movie trailers
- Offline-first data management with caching
- Responsive UI with custom components
- Clean MVVM architecture with Provider

## Architecture

**Pattern**: MVVM (Model-View-ViewModel) with Provider & ChangeNotifier

**Key Components**:

- **Views**: UI screens and widgets
- **ViewModels**: Business logic and state management using ChangeNotifier
- **Models**: Data entities and API response models
- **Services**: Data fetching, local storage, and business services
- **Repository Pattern**: Abstracted data layer with offline-first approach

## Technical Stack

- **Flutter SDK**: 3.32.4
- **Dart SDK**: ^3.8.1
- **Platforms**: iOS, Android

### Dependencies

| Package                         | Purpose          |
| ------------------------------- | ---------------- |
| `provider ^6.1.2`               | State management |
| `hive ^2.2.3`                   | Local database   |
| `dio ^5.4.0`                    | HTTP client      |
| `go_router ^13.2.0`             | Navigation       |
| `youtube_player_flutter ^9.0.3` | Video playback   |
| `connectivity_plus ^6.1.0`      | Network status   |
| `google_fonts ^6.2.1`           | Typography       |

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── core/                       # Core functionality
│   ├── constants/              # App constants
│   └── network/                # API client & exceptions
├── models/                     # Data models
├── services/                   # Business services
│   ├── movie/                  # Movie data service
│   ├── storage/                # Local storage service
│   └── connectivity/           # Network connectivity
├── viewmodels/                 # State management
├── views/                      # UI screens
├── utils/                      # Shared utilities
└── routes/                     # App navigation
```

## Data Flow

The app implements an offline-first strategy:

1. **Cache Check**: Always check local storage first
2. **Immediate Display**: Show cached data instantly
3. **Background Sync**: Fetch fresh data from API
4. **Cache Update**: Update local storage with new data
5. **UI Refresh**: Notify listeners to update UI

## State Management

Uses **Provider** with **ChangeNotifier** pattern:

```dart
// ViewModel
class MovieViewModel extends ChangeNotifier {
  List<Movie> _movies = [];
  bool _isLoading = false;

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;

  Future<void> loadMovies() async {
    _isLoading = true;
    notifyListeners();
    // Fetch data...
    _isLoading = false;
    notifyListeners();
  }
}

// UI
Consumer<MovieViewModel>(
  builder: (context, viewModel, child) {
    return viewModel.isLoading
      ? CircularProgressIndicator()
      : MovieList(viewModel.movies);
  },
)
```

## Local Storage

**Hive** is used for local data persistence:

- Fast, lightweight NoSQL database
- Type-safe with code generation
- Cross-platform support
- Efficient caching mechanism

```dart
@HiveType(typeId: 0)
class CachedMovie extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime cachedAt;
}
```

## Setup

### Prerequisites

- Flutter SDK 3.32.4+
- Dart SDK 3.8.1+
- Android Studio/VS Code with Flutter extension

### Installation

1. **Clone repository**

   ```bash
   git clone https://github.com/umaraslam-cs/tentwenty-assesment.git
   cd tentwenty_assesment
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code**

   ```bash
   dart run build_runner build
   ```

4. **Setup environment**

   ```bash
   # Create .env file with API configuration
   touch .env
   ```

5. **Run application**
   ```bash
   flutter run
   ```

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Create Pull Request

## License

This project is for educational and assessment purposes.

---

**Built with Flutter 3.32.4**
