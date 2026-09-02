// To parse this JSON data, do
//
//     final castModel = castModelFromJson(jsonString);

import 'dart:convert';

CastModel castModelFromJson(String str) => CastModel.fromJson(json.decode(str));

String castModelToJson(CastModel data) => json.encode(data.toJson());

class CastModel {
  int id;
  List<Cast> cast;
  List<Cast> crew;

  CastModel({
    required this.id,
    required this.cast,
    required this.crew,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) => CastModel(
    id: json["id"] ?? 0,
    cast: json["cast"] != null
        ? List<Cast>.from(json["cast"].map((x) => Cast.fromJson(x)))
        : [],
    crew: json["crew"] != null
        ? List<Cast>.from(json["crew"].map((x) => Cast.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cast": List<dynamic>.from(cast.map((x) => x.toJson())),
    "crew": List<dynamic>.from(crew.map((x) => x.toJson())),
  };
}

class Cast {
  bool adult;
  int gender;
  int id;
  String knownForDepartment;
  String name;
  String originalName;
  double popularity;
  String? profilePath;
  int? castId;
  String? character;
  String creditId;
  int? order;
  String? department;
  String? job;

  Cast({
    required this.adult,
    required this.gender,
    required this.id,
    required this.knownForDepartment,
    required this.name,
    required this.originalName,
    required this.popularity,
    this.profilePath,
    this.castId,
    this.character,
    required this.creditId,
    this.order,
    this.department,
    this.job,
  });

  String get fullProfilePath => (profilePath != null && profilePath!.isNotEmpty)
      ? 'https://image.tmdb.org/t/p/w185$profilePath'
      : 'https://via.placeholder.com/185x278?text=No+Photo';

  factory Cast.fromJson(Map<String, dynamic> json) => Cast(
    adult: json["adult"] ?? false,
    gender: json["gender"] ?? 0,
    id: json["id"] ?? 0,
    knownForDepartment: json["known_for_department"] ?? "",
    name: json["name"] ?? "Unknown",
    originalName: json["original_name"] ?? "",
    popularity: (json["popularity"] as num?)?.toDouble() ?? 0.0,
    profilePath: json["profile_path"],
    castId: json["cast_id"],
    character: json["character"] ?? "",
    creditId: json["credit_id"] ?? "",
    order: json["order"],
    department: json["department"],
    job: json["job"],
  );

  Map<String, dynamic> toJson() => {
    "adult": adult,
    "gender": gender,
    "id": id,
    "known_for_department": knownForDepartment,
    "name": name,
    "original_name": originalName,
    "popularity": popularity,
    "profile_path": profilePath,
    "cast_id": castId,
    "character": character,
    "credit_id": creditId,
    "order": order,
    "department": department,
    "job": job,
  };
}
