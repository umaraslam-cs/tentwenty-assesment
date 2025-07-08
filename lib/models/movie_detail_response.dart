/// Detailed movie response model from TMDB API
class MovieDetailResponse {
  final bool adult;
  final String? backdropPath;
  final dynamic belongsToCollection;
  final int? budget;
  final List<Genre> genres;
  final String homepage;
  final int id;
  final String? imdbId;
  final List<String> originCountry;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String? posterPath;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final String releaseDate;
  final int? revenue;
  final int? runtime;
  final List<SpokenLanguage> spokenLanguages;
  final String status;
  final String? tagline;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;

  MovieDetailResponse({
    required this.adult,
    this.backdropPath,
    this.belongsToCollection,
    this.budget,
    required this.genres,
    required this.homepage,
    required this.id,
    this.imdbId,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.productionCompanies,
    required this.productionCountries,
    required this.releaseDate,
    this.revenue,
    this.runtime,
    required this.spokenLanguages,
    required this.status,
    this.tagline,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory MovieDetailResponse.fromJson(Map<String, dynamic> json) {
    return MovieDetailResponse(
      adult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'],
      belongsToCollection: json['belongs_to_collection'],
      budget: json['budget'],
      genres: (json['genres'] as List?)?.map((g) => Genre.fromJson(g)).toList() ?? [],
      homepage: json['homepage'] ?? '',
      id: json['id'] ?? 0,
      imdbId: json['imdb_id'],
      originCountry: (json['origin_country'] as List?)?.cast<String>() ?? [],
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      posterPath: json['poster_path'],
      productionCompanies:
          (json['production_companies'] as List?)?.map((c) => ProductionCompany.fromJson(c)).toList() ?? [],
      productionCountries:
          (json['production_countries'] as List?)?.map((c) => ProductionCountry.fromJson(c)).toList() ?? [],
      releaseDate: json['release_date'] ?? '',
      revenue: json['revenue'],
      runtime: json['runtime'],
      spokenLanguages: (json['spoken_languages'] as List?)?.map((l) => SpokenLanguage.fromJson(l)).toList() ?? [],
      status: json['status'] ?? '',
      tagline: json['tagline'],
      title: json['title'] ?? '',
      video: json['video'] ?? false,
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adult': adult,
      'backdrop_path': backdropPath,
      'belongs_to_collection': belongsToCollection,
      'budget': budget,
      'genres': genres.map((g) => g.toJson()).toList(),
      'homepage': homepage,
      'id': id,
      'imdb_id': imdbId,
      'origin_country': originCountry,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'overview': overview,
      'popularity': popularity,
      'poster_path': posterPath,
      'production_companies': productionCompanies.map((c) => c.toJson()).toList(),
      'production_countries': productionCountries.map((c) => c.toJson()).toList(),
      'release_date': releaseDate,
      'revenue': revenue,
      'runtime': runtime,
      'spoken_languages': spokenLanguages.map((l) => l.toJson()).toList(),
      'status': status,
      'tagline': tagline,
      'title': title,
      'video': video,
      'vote_average': voteAverage,
      'vote_count': voteCount,
    };
  }

  /// Get full poster URL
  String get fullPosterUrl => posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : '';

  /// Get full backdrop URL
  String get fullBackdropUrl => backdropPath != null ? 'https://image.tmdb.org/t/p/w1280$backdropPath' : '';

  /// Get formatted runtime
  String get formattedRuntime => runtime != null ? '$runtime min' : '';

  /// Get genres as string list
  List<String> get genreNames => genres.map((g) => g.name).toList();

  /// Get formatted release date
  String get formattedReleaseDate {
    if (releaseDate.isEmpty) return 'Coming Soon';
    try {
      final date = DateTime.parse(releaseDate);
      return 'In theaters ${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return 'Coming Soon';
    }
  }
}

/// Genre model
class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

/// Production Company model
class ProductionCompany {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;

  ProductionCompany({required this.id, this.logoPath, required this.name, required this.originCountry});

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'] ?? 0,
      logoPath: json['logo_path'],
      name: json['name'] ?? '',
      originCountry: json['origin_country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'logo_path': logoPath, 'name': name, 'origin_country': originCountry};
  }
}

/// Production Country model
class ProductionCountry {
  final String iso31661;
  final String name;

  ProductionCountry({required this.iso31661, required this.name});

  factory ProductionCountry.fromJson(Map<String, dynamic> json) {
    return ProductionCountry(iso31661: json['iso_3166_1'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'iso_3166_1': iso31661, 'name': name};
  }
}

/// Spoken Language model
class SpokenLanguage {
  final String englishName;
  final String iso6391;
  final String name;

  SpokenLanguage({required this.englishName, required this.iso6391, required this.name});

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      englishName: json['english_name'] ?? '',
      iso6391: json['iso_639_1'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'english_name': englishName, 'iso_639_1': iso6391, 'name': name};
  }
}
