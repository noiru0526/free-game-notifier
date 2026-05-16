import 'dart:convert';
import 'package:http/http.dart' as http;
import 'game_offer.dart';

// Cloud Functions endpoint (asia-northeast1)
// Replace YOUR_PROJECT_ID with the actual Firebase project ID after deployment
const _kBaseUrl =
    'https://asia-northeast1-YOUR_PROJECT_ID.cloudfunctions.net';

class GameOfferRepository {
  final http.Client _client;

  GameOfferRepository({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<GameOffer>> fetchFreeGames() async {
    final uri = Uri.parse('$_kBaseUrl/getFreeGames');
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
          'getFreeGames returned ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final games = body['games'] as List<dynamic>? ?? [];
    return games
        .map((g) => GameOffer.fromJson(g as Map<String, dynamic>))
        .toList();
  }

  Future<List<GameOffer>> triggerFetch() async {
    final uri = Uri.parse('$_kBaseUrl/fetchEpicNow');
    final response = await _client
        .post(uri, headers: {'Content-Type': 'application/json'}, body: '{}')
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('fetchEpicNow returned ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final offers = body['offers'] as List<dynamic>? ?? [];
    return offers
        .map((o) => GameOffer.fromJson(o as Map<String, dynamic>))
        .toList();
  }
}

/// Mock repository for development — returns hardcoded sample data
class MockGameOfferRepository extends GameOfferRepository {
  MockGameOfferRepository() : super(client: http.Client());

  @override
  Future<List<GameOffer>> fetchFreeGames() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockOffers;
  }

  @override
  Future<List<GameOffer>> triggerFetch() async {
    return fetchFreeGames();
  }
}

final _mockOffers = [
  GameOffer(
    id: 'mock_1',
    title: 'Death Stranding',
    description: '郵便配達者として荒廃したアメリカを旅し、分断された社会をつなぐ壮大なアクションゲーム。コジマプロダクションの傑作。',
    platform: 'epic',
    status: 'free',
    originalPrice: 5980,
    thumbnailUrl: 'https://cdn1.epicgames.com/offer/b9ead79d3a5a43589dc48e4ddcf2a64a/EGS_DeathStranding_KojimaProductions_S1_2560x1440-5d4db09266ca42c1d3e0e58e45b06b70',
    genres: ['Action', 'Adventure'],
    offerEnd: DateTime.now().add(const Duration(days: 5, hours: 14)),
    pageSlug: 'death-stranding',
    metacritic: 82,
    rating: 4.1,
    aiRecommendation: 'アクションと探索が好きなあなたに最適！小島監督の独創的な世界観と「繋がり」をテーマにした感動的なストーリーが魅力です。',
  ),
  GameOffer(
    id: 'mock_2',
    title: 'Control Ultimate Edition',
    description: '連邦管理局の超自然的な謎を解き明かすアクションアドベンチャー。サービス復元と念動力を駆使したバトルが爽快。',
    platform: 'epic',
    status: 'free',
    originalPrice: 4200,
    thumbnailUrl: 'https://cdn1.epicgames.com/offer/a64d4c5460384218b17de5bd785085f2/EGS_ControlUltimateEdition_RemedyEntertainment_S1_2560x1440-7e60a66b11ddb71ab07c82f74e9ad2bc',
    genres: ['Action', 'Shooter'],
    offerEnd: DateTime.now().add(const Duration(days: 5, hours: 14)),
    pageSlug: 'control',
    metacritic: 85,
    rating: 4.3,
    aiRecommendation: 'シューターとRPG好きにおすすめ！SF超常現象の世界で念動力を使い敵と戦う独特の体験が楽しめます。',
  ),
  GameOffer(
    id: 'mock_3',
    title: 'Cyberpunk 2077',
    description: '近未来のナイトシティを舞台にしたオープンワールドRPG。V という傭兵を操り、巨大コーポレーションに立ち向かう。',
    platform: 'epic',
    status: 'upcoming',
    originalPrice: 7590,
    thumbnailUrl: 'https://cdn1.epicgames.com/offer/77f2b98e2cef40c8b839097106a72de3/EGS_Cyberpunk2077_CDPROJEKTRED_S1_2560x1440-45516940bdf53ba82c3fa19e0a60b1dc',
    genres: ['RPG', 'Action'],
    offerEnd: DateTime.now().add(const Duration(days: 12)),
    pageSlug: 'cyberpunk-2077',
    metacritic: 86,
    rating: 4.5,
  ),
  GameOffer(
    id: 'mock_4',
    title: 'Alien: Isolation',
    description: 'エイリアンシリーズの世界を体験できる本格ホラーサバイバルゲーム。宇宙ステーションを徘徊するエイリアンから生き延びろ。',
    platform: 'gog',
    status: 'free',
    originalPrice: 2980,
    thumbnailUrl: null,
    genres: ['Horror', 'Survival'],
    offerEnd: DateTime.now().add(const Duration(days: 2, hours: 3)),
    pageSlug: 'alien_isolation',
    metacritic: 79,
    rating: 4.4,
    aiRecommendation: 'ホラー好きに超おすすめ！映画の雰囲気を完璧に再現した緊張感あるサバイバル体験。',
  ),
  GameOffer(
    id: 'mock_5',
    title: 'Team Fortress 2',
    description: '9人のキャラクターが戦うチームシューター。今もアクティブなプレイヤーが多い定番F2Pゲーム。',
    platform: 'steam',
    status: 'free',
    originalPrice: 0,
    thumbnailUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/440/header.jpg',
    genres: ['Shooter', 'Action'],
    offerEnd: null,
    pageSlug: '440',
    rating: 4.2,
  ),
];
