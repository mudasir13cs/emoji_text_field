import 'package:flutter/material.dart';

class EmojiCategory {
  final String name;
  final IconData icon;
  final List<String> emojis;

  const EmojiCategory({
    required this.name,
    required this.icon,
    required this.emojis,
  });
}
