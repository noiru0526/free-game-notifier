/// 4px-based spacing system for consistent layouts
abstract class AppSpacing {
  // Base unit: 4px
  static const double xs2 = 2.0;   // hairline
  static const double xs  = 4.0;   // tight gap
  static const double sm  = 8.0;   // compact spacing
  static const double md  = 12.0;  // default gap
  static const double lg  = 16.0;  // comfortable padding
  static const double xl  = 20.0;  // section spacing
  static const double xl2 = 24.0;  // large gap
  static const double xl3 = 32.0;  // very large
  static const double xl4 = 40.0;  // section separator
  static const double xl5 = 48.0;  // hero padding
  static const double xl6 = 64.0;  // screen padding
  static const double xl7 = 80.0;  // hero section

  // Component-specific padding
  static const double paddingCompact    = sm;   // 8px — chips, small buttons
  static const double paddingDefault    = lg;   // 16px — cards, panels
  static const double paddingComfortable = xl2; // 24px — screen edges

  // Card dimensions
  static const double cardRadius    = 8.0;   // game card corner radius
  static const double chipRadius    = 4.0;   // category chip
  static const double badgeRadius   = 10.0;  // notification badge
  static const double buttonRadius  = 4.0;   // action button
  static const double modalRadius   = 12.0;  // bottom sheet

  // Image dimensions
  static const double gameThumbnailWidth  = 184.0; // card horizontal thumbnail
  static const double gameThumbnailHeight = 104.0;
  static const double gameCardListHeight  = 104.0;

  // Tap targets (WCAG AA: min 44px)
  static const double minTapTarget = 44.0;
  static const double iconSize     = 20.0;
  static const double iconSizeLg   = 24.0;

  AppSpacing._();
}
