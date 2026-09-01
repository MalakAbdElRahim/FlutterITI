// To parse this JSON data, do
//
//     final movieModel = movieModelFromJson(jsonString);

import 'dart:convert';

MovieModel movieModelFromJson(String str) => MovieModel.fromJson(json.decode(str));

String movieModelToJson(MovieModel data) => json.encode(data.toJson());

class MovieModel {
    bool adult;
    String? backdropPath;
    List<int> genreIds;
    int id;
    String title;
    String originalLanguage;
    String overview;
    double popularity;
    String? posterPath;
    DateTime? releaseDate;
    bool softcore;
    bool video;
    double voteAverage;

    MovieModel({
        required this.adult,
        this.backdropPath,
        required this.genreIds,
        required this.id,
        required this.title,
        required this.originalLanguage,
        required this.overview,
        required this.popularity,
        this.posterPath,
        this.releaseDate,
        this.softcore = false,
        required this.video,
        required this.voteAverage,
    });

    String get fullPosterPath => (posterPath != null && posterPath!.isNotEmpty)
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : 'https://via.placeholder.com/500x750?text=No+Poster';

    String get fullBackdropPath => (backdropPath != null && backdropPath!.isNotEmpty)
        ? 'https://image.tmdb.org/t/p/w780$backdropPath'
        : fullPosterPath;

    String get releaseYear => releaseDate != null ? releaseDate!.year.toString() : 'N/A';

    factory MovieModel.fromJson(Map<String, dynamic> json) => MovieModel(
        adult: json["adult"] ?? false,
        backdropPath: json["backdrop_path"],
        genreIds: json["genre_ids"] != null
            ? List<int>.from(json["genre_ids"].map((x) => x))
            : [],
        id: json["id"] ?? 0,
        title: json["title"] ?? 'Unknown Title',
        originalLanguage: json["original_language"] ?? 'en',
        overview: json["overview"] ?? '',
        popularity: (json["popularity"] as num?)?.toDouble() ?? 0.0,
        posterPath: json["poster_path"],
        releaseDate: json["release_date"] != null && json["release_date"].toString().isNotEmpty
            ? DateTime.tryParse(json["release_date"].toString())
            : null,
        softcore: json["softcore"] ?? false,
        video: json["video"] ?? false,
        voteAverage: (json["vote_average"] as num?)?.toDouble() ?? 0.0,
    );

    Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
        "id": id,
        "title": title,
        "original_language": originalLanguage,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "release_date": releaseDate != null
            ? "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}"
            : null,
        "softcore": softcore,
        "video": video,
        "vote_average": voteAverage,
    };
}
