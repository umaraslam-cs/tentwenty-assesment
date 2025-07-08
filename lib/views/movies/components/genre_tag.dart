import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Genre tag colors from Figma design
class GenreColors {
  static const Color action = Color(0xFF15D2BC);
  static const Color thriller = Color(0xFFE26CA5);
  static const Color science = Color(0xFF564CA3);
  static const Color fiction = Color(0xFFCD9D0F);

  static Color getGenreColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'action':
        return action;
      case 'thriller':
        return thriller;
      case 'science':
      case 'science fiction':
      case 'sci-fi':
        return science;
      case 'fiction':
        return fiction;
      default:
        return science; // Default color
    }
  }
}

class GenreTag extends StatelessWidget {
  final String genre;
  final Color? customColor;

  const GenreTag({super.key, required this.genre, this.customColor});

  @override
  Widget build(BuildContext context) {
    final color = customColor ?? GenreColors.getGenreColor(genre);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Text(
        genre,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, height: 1.67),
      ),
    );
  }
}
