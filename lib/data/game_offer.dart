class GameOffer {
  final String id;
  final String title;
  final String description;
  final String platform;
  final String status;
  final double originalPrice;
  final String? thumbnailUrl;
  final String? backgroundImage;
  final List<String> genres;
  final DateTime? offerEnd;
  final String? pageSlug;
  final String? aiRecommendation;
  final int? metacritic;
  final double? rating;

  const GameOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.platform,
    required this.status,
    required this.originalPrice,
    this.thumbnailUrl,
    this.backgroundImage,
    this.genres = const [],
    this.offerEnd,
    this.pageSlug,
    this.aiRecommendation,
    this.metacritic,
    this.rating,
  });

  factory GameOffer.fromJson(Map<String, dynamic> json) {
    return GameOffer(
      id: json['id'] as String? ?? json['docId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      platform: json['platform'] as String? ?? 'epic',
      status: json['status'] as String? ?? 'free',
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      backgroundImage: json['backgroundImage'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      offerEnd: json['offerEnd'] != null
          ? DateTime.tryParse(json['offerEnd'].toString())
          : null,
      pageSlug: json['pageSlug'] as String?,
      aiRecommendation: json['aiRecommendation'] as String?,
      metacritic: json['metacritic'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  bool get isFree => status == 'free';
  bool get isUpcoming => status == 'upcoming';

  Duration? get timeRemaining {
    if (offerEnd == null) return null;
    final diff = offerEnd!.difference(DateTime.now());
    return diff.isNegative ? null : diff;
  }

  String get storeUrl {
    if (platform == 'epic') {
      if (pageSlug != null) {
        return 'https://store.epicgames.com/ja/p/$pageSlug';
      }
      return 'https://store.epicgames.com/ja/free-games';
    }
    return 'https://store.steampowered.com';
  }
}
