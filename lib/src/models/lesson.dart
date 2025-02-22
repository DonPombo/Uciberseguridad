import 'package:flutter/material.dart';

class Lesson {
  final String title;
  final String image;
  final double rating;
  final double progress;
  final IconData icon;

  Lesson({
    required this.title,
    required this.image,
    required this.rating,
    required this.progress,
    required this.icon,
  });
} 