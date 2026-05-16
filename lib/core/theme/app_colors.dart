import 'package:flutter/material.dart';

/// Gaming/Steam-inspired dark color palette
/// Based on Steam's visual language: dark navy backgrounds, electric blue accents
abstract class AppColors {
  // ===== PRIMITIVE COLORS =====

  // Navy scale (Steam's signature dark blue-gray)
  static const Color navy50  = Color(0xFFE8EEF4);
  static const Color navy100 = Color(0xFFC1D2DF);
  static const Color navy200 = Color(0xFF8FA8BF);
  static const Color navy300 = Color(0xFF5E7E9F);
  static const Color navy400 = Color(0xFF3D607F);
  static const Color navy500 = Color(0xFF2A475E); // Steam elevated surface
  static const Color navy600 = Color(0xFF1B2838); // Steam card background
  static const Color navy700 = Color(0xFF171A21); // Steam base background
  static const Color navy800 = Color(0xFF101318); // Deepest dark
  static const Color navy900 = Color(0xFF080B0F);

  // Blue accent scale (Steam's brand blue)
  static const Color blue50  = Color(0xFFE6F4FF);
  static const Color blue100 = Color(0xFFB3DFFE);
  static const Color blue200 = Color(0xFF80C9FD);
  static const Color blue300 = Color(0xFF4DB4FC);
  static const Color blue400 = Color(0xFF1A9FFF); // Steam action button
  static const Color blue500 = Color(0xFF66C0F4); // Steam link/accent
  static const Color blue600 = Color(0xFF4C7BBF); // Steam button hover
  static const Color blue700 = Color(0xFF335A8F); // Darker blue
  static const Color blue800 = Color(0xFF1A3A5F);
  static const Color blue900 = Color(0xFF0A1F35);

  // Cyan/Electric scale (neon gaming accent)
  static const Color cyan300 = Color(0xFF00D4FF);
  static const Color cyan400 = Color(0xFF00BFFF);
  static const Color cyan500 = Color(0xFF00AEFF);

  // Green scale (Free/Available)
  static const Color green300 = Color(0xFF7BD95A);
  static const Color green400 = Color(0xFF5CC13E);
  static const Color green500 = Color(0xFF4FA94D); // Steam free/available
  static const Color green600 = Color(0xFF3D8B3A);

  // Orange scale (Expires soon)
  static const Color orange300 = Color(0xFFFFB74D);
  static const Color orange400 = Color(0xFFFFA726);
  static const Color orange500 = Color(0xFFF08C00); // Warning/expiring

  // Red scale (Error/Expired)
  static const Color red400    = Color(0xFFEF5350);
  static const Color red500    = Color(0xFFE53935);

  // Gray text scale
  static const Color gray50  = Color(0xFFF5F7FA);
  static const Color gray100 = Color(0xFFC7D5E0); // Steam primary text
  static const Color gray200 = Color(0xFF8F98A0); // Steam secondary text
  static const Color gray300 = Color(0xFF677582); // Muted text
  static const Color gray400 = Color(0xFF4C5A66); // Very muted
  static const Color gray500 = Color(0xFF3A4550); // Disabled

  // ===== SEMANTIC COLORS =====

  // Backgrounds
  static const Color bgBase     = navy700; // #171A21 — main screen background
  static const Color bgSurface  = navy600; // #1B2838 — cards, panels
  static const Color bgElevated = navy500; // #2A475E — modals, hover states
  static const Color bgOverlay  = Color(0xCC101318); // overlay with opacity

  // Text
  static const Color textPrimary   = gray100;  // #C7D5E0 — main text
  static const Color textSecondary = gray200;  // #8F98A0 — secondary/descriptions
  static const Color textMuted     = gray300;  // #677582 — labels, placeholders
  static const Color textDisabled  = gray500;  // #3A4550 — disabled state
  static const Color textInverse   = navy800;  // dark text on light bg

  // Borders
  static const Color borderDefault = Color(0xFF3D5468); // subtle border
  static const Color borderMuted   = Color(0xFF2C3D4F); // very subtle
  static const Color borderStrong  = Color(0xFF4C7BBF); // emphasized (blue)

  // Interactive
  static const Color interactivePrimary      = blue400;  // #1A9FFF — main CTA
  static const Color interactivePrimaryHover = blue600;  // #4C7BBF
  static const Color interactiveAccent       = blue500;  // #66C0F4 — links
  static const Color interactiveGaming       = cyan400;  // #00BFFF — neon gaming

  // Feedback
  static const Color feedbackFree     = green500;  // Free to claim
  static const Color feedbackExpiring = orange500; // Expiring soon
  static const Color feedbackExpired  = red400;    // Expired
  static const Color feedbackNew      = cyan500;   // Newly added

  // Platform badge colors
  static const Color platformEpic   = Color(0xFF313131); // Epic Games (near black)
  static const Color platformSteam  = Color(0xFF1B2838); // Steam dark
  static const Color platformGOG    = Color(0xFF6D1A8A); // GOG purple
  static const Color platformOrigin = Color(0xFFF56C2D); // EA orange
  static const Color platformITchio = Color(0xFFFA5C5C); // itch.io pink-red

  // Genre/Category chip colors
  static const Color genreAction  = Color(0xFF8B2FC9); // Action — purple
  static const Color genreRPG     = Color(0xFF1A7A4C); // RPG — dark green
  static const Color genreIndie   = Color(0xFF0066CC); // Indie — blue
  static const Color genreShooter = Color(0xFFCC3300); // Shooter — red
  static const Color genreStrategy= Color(0xFF8B6914); // Strategy — gold
  static const Color genreAdvent  = Color(0xFF007799); // Adventure — teal
  static const Color genreHorror  = Color(0xFF3D0026); // Horror — dark red
  static const Color genreOther   = Color(0xFF3A4550); // Other — gray

  AppColors._();
}
