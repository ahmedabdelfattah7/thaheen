import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/models/course.dart';

/// Reads the course catalog bundled in the app. Offline only.
class CourseRepository {
  CourseRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const catalogPath = 'assets/data/courses.json';

  final AssetBundle _bundle;
  List<Course>? _cache;

  /// Loads and parses the catalog once. Throws when the file is missing or
  /// malformed, so the caller can show an error state.
  Future<List<Course>> getCourses() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await _bundle.loadString(catalogPath, cache: false);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return _cache = [
      for (final course in json['courses'] as List)
        Course.fromJson(course as Map<String, dynamic>),
    ];
  }
}
