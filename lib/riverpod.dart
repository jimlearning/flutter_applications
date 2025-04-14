// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'dart:io';
// import 'dart:convert';

// part 'riverpod.g.dart';

// @riverpod
// Future<List<Package>> fetchPackages(
//   Ref ref, {
//     required int page,
//     String search = '',
// }) async {
//   final client = HttpClient();
//   // Fetch an API. Here we're using package:dio, but we could use anything else.
//   final response = await client.get(
//     'https://pub.dartlang.org/api/search?page=$page&q=${Uri.encodeQueryComponent(search)}'
//   );

//    jsonDecode(response);
//   // Decode the JSON response into a Dart class.
//   return
// }

// class Package {
//   final String name;
//   final String description;
//   final String score;
//   final String author;
//   final String latestVersion;
//   final String latestPublished;
//   final String pubPoints;
//   final String popularity;

//   Package({
//     required this.name,
//     required this.description,
//     required this.score,
//     required this.author,
//     required this.latestVersion,
//     required this.latestPublished,
//     required this.pubPoints,
//     required this.popularity,
//   })
// }