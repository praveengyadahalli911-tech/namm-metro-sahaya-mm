import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A Station entry parsed from the official BMRCL GeoJSON
class MetroStation {
  final String name;
  final String lineColor; // 'purple' | 'green' | 'yellow' | 'interchange'
  final double lat;
  final double lng;
  final bool isInterchange;

  const MetroStation({
    required this.name,
    required this.lineColor,
    required this.lat,
    required this.lng,
    this.isInterchange = false,
  });

  String get lineLabel {
    switch (lineColor) {
      case 'purple':
      case '#e542de':
        return 'Purple Line';
      case 'green':
      case '#009933':
        return 'Green Line';
      case 'yellow':
      case '#FFD700':
        return 'Yellow Line (Phase-2)';
      default:
        return 'Interchange';
    }
  }

  String get emoji {
    switch (lineColor) {
      case 'purple':
      case '#e542de':
        return '🟣';
      case 'green':
      case '#009933':
        return '🟢';
      case 'yellow':
      case '#FFD700':
        return '🟡';
      default:
        return '🔴';
    }
  }
}

/// StationDataService
///
/// Fetches REAL station data from:
///   Vonter/transitrouter — GeoJSON sourced directly from BMRCL official maps
///   URL: https://raw.githubusercontent.com/Vonter/transitrouter/main/data/blr/rail.json
///
/// Falls back to bundled offline data if network is unavailable.
/// This is NOT scraped or dummy data — it is the actual operational BMRCL
/// network used by transit planning tools.
class StationDataService {
  static final StationDataService _instance = StationDataService._internal();
  factory StationDataService() => _instance;
  StationDataService._internal();

  static const String _liveUrl =
      'https://raw.githubusercontent.com/Vonter/transitrouter/main/data/blr/rail.json';

  List<MetroStation> _stations = [];
  bool _isLoaded = false;
  bool _isLive = false; // true = fetched from network, false = offline fallback

  List<MetroStation> get stations => List.unmodifiable(_stations);
  bool get isLoaded => _isLoaded;
  bool get isLive => _isLive;

  /// Total station count by line
  int get purpleCount =>
      _stations.where((s) => s.lineColor == '#e542de').length;
  int get greenCount => _stations.where((s) => s.lineColor == '#009933').length;
  int get yellowCount => _stations.where((s) => s.lineColor == '#FFD700').length;

  /// Fetch real data from the live GeoJSON endpoint.
  /// Falls back to offline seed data on any network error.
  Future<void> init() async {
    try {
      final response = await http
          .get(Uri.parse(_liveUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // CVE-4 FIX: guard against oversized responses (>5MB = likely error page or attack)
        if (response.bodyBytes.length > 5 * 1024 * 1024) {
          if (kDebugMode) debugPrint('⚠️  StationDataService: response too large (${response.bodyBytes.length} bytes), using fallback');
          throw Exception('Response too large');
        }
        final ct = response.headers['content-type'] ?? '';
        if (!ct.contains('json') && !ct.contains('octet-stream') && !ct.contains('text')) {
          if (kDebugMode) debugPrint('⚠️  StationDataService: unexpected content-type: $ct');
          throw Exception('Unexpected content-type: $ct');
        }
        final parsed = _parseGeoJson(response.body);
        if (parsed.isNotEmpty) {
          _stations = parsed;
          _isLive = true;
          _isLoaded = true;
          if (kDebugMode) debugPrint('✅ StationDataService: loaded ${_stations.length} stations from LIVE source');
          return;
        }
      }
    } catch (e) {
      // CVE-7 FIX: only log in debug mode
      if (kDebugMode) debugPrint('⚠️  StationDataService: network fetch failed ($e), using offline fallback');
    }

    // Offline fallback — full Phase-1 + Phase-2A operational network
    _stations = _offlineFallback();
    _isLive = false;
    _isLoaded = true;
    if (kDebugMode) debugPrint('📦 StationDataService: loaded ${_stations.length} stations from OFFLINE fallback');
  }

  /// Parse the Vonter/transitrouter GeoJSON — only Point features = stations
  List<MetroStation> _parseGeoJson(String raw) {
    final result = <MetroStation>[];
    try {
      final Map<String, dynamic> fc = jsonDecode(raw);
      final List features = fc['features'] as List;
      for (final f in features) {
        final geom = f['geometry'] as Map<String, dynamic>;
        if (geom['type'] != 'Point') continue;

        final props = f['properties'] as Map<String, dynamic>;
        final name = props['name'] as String? ?? '';
        if (name.isEmpty) continue;

        final color = props['station-color'] as String? ?? '';
        final coords = geom['coordinates'] as List;
        final lng = (coords[0] as num).toDouble();
        final lat = (coords[1] as num).toDouble();
        final isInterchange = props['interchange'] == true;

        result.add(MetroStation(
          name: name,
          lineColor: _normalizeColor(color),
          lat: lat,
          lng: lng,
          isInterchange: isInterchange,
        ));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ StationDataService: GeoJSON parse error: $e');
    }
    return result;
  }

  String _normalizeColor(String raw) {
    switch (raw.toLowerCase()) {
      case '#e542de':
        return '#e542de'; // Purple
      case '#009933':
        return '#009933'; // Green
      case '#ffd700':
        return '#FFD700'; // Yellow
      case '#ff2600':
        return 'interchange'; // Red = interchange (Majestic, RV Road)
      default:
        return raw;
    }
  }

  /// Get all station names (for search/autocomplete)
  List<String> get allStationNames =>
      _stations.map((s) => s.name).toList()..sort();

  /// Find stations by line
  List<MetroStation> byLine(String lineColor) =>
      _stations.where((s) => s.lineColor == lineColor).toList();

  /// Search stations by name (case-insensitive partial match)
  List<MetroStation> search(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _stations
        .where((s) => s.name.toLowerCase().contains(q))
        .toList();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // OFFLINE FALLBACK — Full Phase-1 + Phase-2A operational network
  // Source: BMRCL official network map (bmrc.co.in), accurate as of May 2025
  // ──────────────────────────────────────────────────────────────────────────
  List<MetroStation> _offlineFallback() => [
        // ── Purple Line (Challaghatta → Whitefield Kadugodi) ──────────────
        const MetroStation(name: 'Challaghatta', lineColor: '#e542de', lat: 12.89731, lng: 77.46123),
        const MetroStation(name: 'Kengeri', lineColor: '#e542de', lat: 12.90791, lng: 77.47658),
        const MetroStation(name: 'Kengeri Bus Terminal', lineColor: '#e542de', lat: 12.91469, lng: 77.48785),
        const MetroStation(name: 'Pattanagere', lineColor: '#e542de', lat: 12.92425, lng: 77.49835),
        const MetroStation(name: 'Pantharapalya - Nayandahalli', lineColor: '#e542de', lat: 12.94167, lng: 77.52512),
        const MetroStation(name: 'Mysuru Road', lineColor: '#e542de', lat: 12.94668, lng: 77.53008),
        const MetroStation(name: 'Deepanjali Nagar', lineColor: '#e542de', lat: 12.95204, lng: 77.53702),
        const MetroStation(name: 'Attiguppe', lineColor: '#e542de', lat: 12.96187, lng: 77.53357),
        const MetroStation(name: 'Vijayanagar', lineColor: '#e542de', lat: 12.97095, lng: 77.53741),
        const MetroStation(name: 'Sri Balagangadharanatha Swamiji Stn., Hosahalli', lineColor: '#e542de', lat: 12.97420, lng: 77.54562),
        const MetroStation(name: 'Magadi Road', lineColor: '#e542de', lat: 12.97564, lng: 77.55536),
        const MetroStation(name: 'Krantivira Sangolli Rayanna Railway Station', lineColor: '#e542de', lat: 12.97588, lng: 77.56538),
        const MetroStation(name: 'Sir M. Visvesvaraya Stn., Central College', lineColor: '#e542de', lat: 12.97453, lng: 77.58422),
        const MetroStation(name: 'Dr. B. R. Ambedkar Station, Vidhana Soudha', lineColor: '#e542de', lat: 12.97849, lng: 77.59148),
        const MetroStation(name: 'Cubbon Park', lineColor: '#e542de', lat: 12.98094, lng: 77.59757),
        const MetroStation(name: 'Mahatma Gandhi Road', lineColor: '#e542de', lat: 12.97553, lng: 77.60678),
        const MetroStation(name: 'Trinity', lineColor: '#e542de', lat: 12.97302, lng: 77.61702),
        const MetroStation(name: 'Halasuru', lineColor: '#e542de', lat: 12.97650, lng: 77.62669),
        const MetroStation(name: 'Indiranagar', lineColor: '#e542de', lat: 12.97833, lng: 77.63866),
        const MetroStation(name: 'Swami Vivekananda Road', lineColor: '#e542de', lat: 12.98593, lng: 77.64490),
        const MetroStation(name: 'Baiyappanahalli', lineColor: '#e542de', lat: 12.99069, lng: 77.65239),
        const MetroStation(name: 'Benniganahalli', lineColor: '#e542de', lat: 12.99652, lng: 77.66847),
        const MetroStation(name: 'Krishnarajapura', lineColor: '#e542de', lat: 12.99991, lng: 77.67788),
        const MetroStation(name: 'Singayyanapalya', lineColor: '#e542de', lat: 12.99658, lng: 77.69260),
        const MetroStation(name: 'Garudacharpalya', lineColor: '#e542de', lat: 12.99343, lng: 77.70370),
        const MetroStation(name: 'Hoodi', lineColor: '#e542de', lat: 12.98884, lng: 77.71139),
        const MetroStation(name: 'Seetharampalya', lineColor: '#e542de', lat: 12.98095, lng: 77.70875),
        const MetroStation(name: 'Kundalahalli', lineColor: '#e542de', lat: 12.97757, lng: 77.71559),
        const MetroStation(name: 'Nallur Halli', lineColor: '#e542de', lat: 12.97660, lng: 77.72481),
        const MetroStation(name: 'Sri Sathya Sai Hospital', lineColor: '#e542de', lat: 12.97757, lng: 77.72877),
        const MetroStation(name: 'Pattandur Agrahara', lineColor: '#e542de', lat: 12.98762, lng: 77.73780),
        const MetroStation(name: 'Kadugodi Tree Park', lineColor: '#e542de', lat: 12.98564, lng: 77.74705),
        const MetroStation(name: 'Hopefarm Channasandra', lineColor: '#e542de', lat: 12.98737, lng: 77.75391),
        const MetroStation(name: 'Whitefield (Kadugodi)', lineColor: '#e542de', lat: 12.99558, lng: 77.75790),
        const MetroStation(name: 'Jnanabharathi', lineColor: '#e542de', lat: 12.93543, lng: 77.51241),
        const MetroStation(name: 'Rajarajeshwari Nagar', lineColor: '#e542de', lat: 12.93665, lng: 77.51966),

        // ── Majestic Interchange ───────────────────────────────────────────
        const MetroStation(
          name: 'Nadaprabhu Kempegowda Station, Majestic',
          lineColor: 'interchange',
          lat: 12.97561,
          lng: 77.57288,
          isInterchange: true,
        ),

        // ── Green Line (Madavara → Silk Institute) ────────────────────────
        const MetroStation(name: 'Madavara', lineColor: '#009933', lat: 13.05742, lng: 77.47280),
        const MetroStation(name: 'Chikkabidarakallu', lineColor: '#009933', lat: 13.05236, lng: 77.48792),
        const MetroStation(name: 'Manjunathanagara', lineColor: '#009933', lat: 13.05009, lng: 77.49445),
        const MetroStation(name: 'Nagasandra', lineColor: '#009933', lat: 13.04796, lng: 77.50014),
        const MetroStation(name: 'Dasarahalli', lineColor: '#009933', lat: 13.04326, lng: 77.51253),
        const MetroStation(name: 'Jalahalli', lineColor: '#009933', lat: 13.03941, lng: 77.51974),
        const MetroStation(name: 'Peenya Industry', lineColor: '#009933', lat: 13.03631, lng: 77.52551),
        const MetroStation(name: 'Peenya', lineColor: '#009933', lat: 13.03302, lng: 77.53320),
        const MetroStation(name: 'Goraguntepalya', lineColor: '#009933', lat: 13.02833, lng: 77.54105),
        const MetroStation(name: 'Yeshwantpur', lineColor: '#009933', lat: 13.02333, lng: 77.54973),
        const MetroStation(name: 'Sandal Soap Factory', lineColor: '#009933', lat: 13.01470, lng: 77.55401),
        const MetroStation(name: 'Mahalakshmi', lineColor: '#009933', lat: 13.00815, lng: 77.54881),
        const MetroStation(name: 'Rajajinagar', lineColor: '#009933', lat: 13.00040, lng: 77.54968),
        const MetroStation(name: 'Mahakavi Kuvempu Road', lineColor: '#009933', lat: 12.99848, lng: 77.55691),
        const MetroStation(name: 'Srirampura', lineColor: '#009933', lat: 12.99650, lng: 77.56333),
        const MetroStation(name: 'Mantri Square Sampige Road', lineColor: '#009933', lat: 12.99040, lng: 77.57071),
        const MetroStation(name: 'Yelachenahalli', lineColor: '#009933', lat: 12.89604, lng: 77.57019),
        const MetroStation(name: 'Jaya Prakash Nagar', lineColor: '#009933', lat: 12.90746, lng: 77.57312),
        const MetroStation(name: 'Banashankari', lineColor: '#009933', lat: 12.91532, lng: 77.57362),
        const MetroStation(name: 'Jayanagar', lineColor: '#009933', lat: 12.92954, lng: 77.58015),
        const MetroStation(name: 'South End Circle', lineColor: '#009933', lat: 12.93826, lng: 77.58006),
        const MetroStation(name: 'Lalbagh', lineColor: '#009933', lat: 12.94641, lng: 77.58001),
        const MetroStation(name: 'National College', lineColor: '#009933', lat: 12.95051, lng: 77.57369),
        const MetroStation(name: 'Krishna Rajendra Market', lineColor: '#009933', lat: 12.96070, lng: 77.57463),
        const MetroStation(name: 'Chickpete', lineColor: '#009933', lat: 12.96684, lng: 77.57455),
        const MetroStation(name: 'Konanakunte Cross', lineColor: '#009933', lat: 12.88898, lng: 77.56270),
        const MetroStation(name: 'Doddakallasandra', lineColor: '#009933', lat: 12.88466, lng: 77.55277),
        const MetroStation(name: 'Vajarahalli', lineColor: '#009933', lat: 12.87753, lng: 77.54478),
        const MetroStation(name: 'Thalaghattapura', lineColor: '#009933', lat: 12.87140, lng: 77.53838),
        const MetroStation(name: 'Silk Institute', lineColor: '#009933', lat: 12.86160, lng: 77.52989),

        // ── RV Road Interchange (Green/Yellow) ────────────────────────────
        const MetroStation(
          name: 'Rashtreeya Vidyalaya Road',
          lineColor: 'interchange',
          lat: 12.92137,
          lng: 77.58017,
          isInterchange: true,
        ),

        // ── Yellow Line (Phase-2 — operational as of 2024) ────────────────
        const MetroStation(name: 'Delta Electronics Bommasandra', lineColor: '#FFD700', lat: 12.81942, lng: 77.68832),
        const MetroStation(name: 'Biocon Hebbagodi', lineColor: '#FFD700', lat: 12.82902, lng: 77.68139),
        const MetroStation(name: 'Huskur Road', lineColor: '#FFD700', lat: 12.83907, lng: 77.67743),
        const MetroStation(name: 'Infosys Foundation Konappana Agrahara', lineColor: '#FFD700', lat: 12.84644, lng: 77.67119),
        const MetroStation(name: 'Electronic City', lineColor: '#FFD700', lat: 12.85654, lng: 77.66349),
        const MetroStation(name: 'Beratena Agrahara', lineColor: '#FFD700', lat: 12.86390, lng: 77.65789),
        const MetroStation(name: 'Hosa Road', lineColor: '#FFD700', lat: 12.87074, lng: 77.65245),
        const MetroStation(name: 'Singasandra', lineColor: '#FFD700', lat: 12.88081, lng: 77.64486),
        const MetroStation(name: 'Kudlu Gate', lineColor: '#FFD700', lat: 12.88994, lng: 77.63921),
        const MetroStation(name: 'Hongasandra', lineColor: '#FFD700', lat: 12.90173, lng: 77.63197),
        const MetroStation(name: 'Bommanahalli', lineColor: '#FFD700', lat: 12.91075, lng: 77.62641),
        const MetroStation(name: 'Central Silk Board', lineColor: '#FFD700', lat: 12.91657, lng: 77.62057),
        const MetroStation(name: 'BTM Layout', lineColor: '#FFD700', lat: 12.91659, lng: 77.60813),
        const MetroStation(name: 'Ragigudda', lineColor: '#FFD700', lat: 12.91708, lng: 77.58824),
        const MetroStation(name: 'Jayadeva Hospital', lineColor: '#FFD700', lat: 12.91675, lng: 77.60009),
      ];
}
