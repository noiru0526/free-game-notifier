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
    description: '郵便配達者として荒廃したアメリカを旅し、分断された社会をつなぐ壮大なアクションゲーム。',
    platform: 'epic',
    status: 'free',
    originalPrice: 5980,
    thumbnailUrl: null,
    genres: ['Action', 'Adventure'],
    offerEnd: DateTime.now().add(const Duration(days: 5, hours: 14)),
    pageSlug: 'death-stranding',
  ),
  GameOffer(
    id: 'mock_2',
    title: 'Control Ultimate Edition',
    description: '連邦管理局の超自然的な謎を解き明かすアクションアドベンチャー。',
    platform: 'epic',
    status: 'free',
    originalPrice: 4200,
    thumbnailUrl: null,
    genres: ['Action', 'Shooter'],
    offerEnd: DateTime.now().add(const Duration(days: 5, hours: 14)),
    pageSlug: 'control',
  ),
  GameOffer(
    id: 'mock_3',
    title: 'Cyberpunk 2077',
    description: '近未来のナイトシティを舞台にしたオープンワールドRPG。',
    platform: 'epic',
    status: 'upcoming',
    originalPrice: 7590,
    thumbnailUrl: null,
    genres: ['RPG', 'Action'],
    offerEnd: DateTime.now().add(const Duration(days: 12)),
    pageSlug: 'cyberpunk-2077',
  ),
];
