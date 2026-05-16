import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

abstract class AppTheme {
  static ThemeData get dark => _buildDark();

  static ThemeData _buildDark() {
    const primary = AppColors.interactivePrimary;
    const surface = AppColors.bgSurface;
    const bg      = AppColors.bgBase;

    final colorScheme = const ColorScheme(
      brightness:      Brightness.dark,
      primary:         primary,
      onPrimary:       Colors.white,
      primaryContainer: AppColors.navy600,
      onPrimaryContainer: AppColors.textPrimary,
      secondary:       AppColors.interactiveAccent,
      onSecondary:     AppColors.navy800,
      secondaryContainer: AppColors.navy500,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary:        AppColors.interactiveGaming,
      onTertiary:      AppColors.navy800,
      tertiaryContainer: AppColors.navy600,
      onTertiaryContainer: AppColors.textPrimary,
      error:           AppColors.feedbackExpired,
      onError:         Colors.white,
      errorContainer:  Color(0xFF5C0A0A),
      onErrorContainer: Color(0xFFFFB4B4),
      surface:         surface,
      onSurface:       AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline:         AppColors.borderDefault,
      outlineVariant:  AppColors.borderMuted,
      shadow:          Colors.black,
      inverseSurface:  AppColors.gray100,
      onInverseSurface: AppColors.navy800,
      inversePrimary:  AppColors.blue700,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme:  colorScheme,
      scaffoldBackgroundColor: bg,
      textTheme:    AppTypography.textTheme,

      // AppBar — Steam-style flat dark header
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgSurface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTypography.h4,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          statusBarColor: AppColors.bgSurface,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary, size: AppSpacing.iconSizeLg),
      ),

      // Card — game card style
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: const BorderSide(color: AppColors.borderMuted, width: 1),
        ),
      ),

      // Elevated button — primary action (Claim Free Game)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.interactivePrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.gray500,
          disabledForegroundColor: AppColors.gray400,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          minimumSize: const Size(0, AppSpacing.minTapTarget),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          textStyle: AppTypography.label,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return AppColors.gray500;
            if (states.contains(WidgetState.hovered)) return AppColors.interactivePrimaryHover;
            if (states.contains(WidgetState.pressed)) return AppColors.blue700;
            return AppColors.interactivePrimary;
          }),
        ),
      ),

      // Text button — secondary actions
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.interactiveAccent,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          minimumSize: const Size(0, AppSpacing.minTapTarget),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          textStyle: AppTypography.label.copyWith(color: AppColors.interactiveAccent),
        ),
      ),

      // Chip — genre/platform chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgElevated,
        disabledColor: AppColors.gray500,
        selectedColor: AppColors.blue600,
        secondarySelectedColor: AppColors.blue600,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs2),
        labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        labelStyle: AppTypography.labelSmall,
        secondaryLabelStyle: AppTypography.labelSmall.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.chipRadius)),
        side: const BorderSide(color: AppColors.borderMuted, width: 1),
        elevation: 0,
      ),

      // Input decoration — search bar
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.borderMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          borderSide: const BorderSide(color: AppColors.interactivePrimary, width: 1.5),
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md,
        ),
        isDense: true,
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        tileColor: AppColors.bgSurface,
        selectedTileColor: AppColors.bgElevated,
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        subtitleTextStyle: AppTypography.bodySmall,
        titleTextStyle: AppTypography.h4,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.borderMuted,
        thickness: 1,
        space: 0,
      ),

      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSurface,
        selectedItemColor: AppColors.interactivePrimary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),

      // Snackbar / toast
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgElevated,
        contentTextStyle: AppTypography.body,
        actionTextColor: AppColors.interactivePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
        behavior: SnackBarBehavior.floating,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.interactivePrimary;
          return AppColors.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.blue700;
          return AppColors.borderDefault;
        }),
      ),

      // Progress indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.interactivePrimary,
        linearTrackColor: AppColors.borderMuted,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: AppSpacing.iconSize,
      ),
    );
  }

  AppTheme._();
}
