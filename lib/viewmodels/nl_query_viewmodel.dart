import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// UC-NMS-06 / FR-NMS-12/13: Natural Language Query ViewModel.
///
/// - Sends user's free-text query to Gemini API.
/// - Falls back gracefully when API key is missing or offline (BR-01).
/// - System prompt constrains answers to Namma Metro context only (FR-NMS-13).
/// - Message history kept in-memory for chat continuity.
class NLQueryViewModel extends ChangeNotifier {
  /// Replace with a real key from https://aistudio.google.com/
  /// In production, load from flutter_dotenv or environment config.
  static const _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '', // Empty = offline fallback mode
  );

  GenerativeModel? _model;
  ChatSession? _chat;

  final List<NLMessage> _messages = [];
  bool _isLoading = false;
  DateTime? _lastQueryTime; // CVE-10: rate-limit guard

  NLQueryViewModel() {
    _initModel();
    _loadPreloadedData();
  }

  void _loadPreloadedData() {
    // CVE-1 FIX: removed hardcoded local filesystem paths
    _messages.add(const NLMessage(
      text: '🚇 Hello! I am your Namma Metro Sahaya assistant. Ask me about routes, fares, or token machines!',
      role: MessageRole.assistant,
      timestamp: null, // will be filled at runtime
    ));
  }

  void _initModel() {
    if (_apiKey.isEmpty) return; // Graceful offline fallback
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );
    _chat = _model!.startChat();
  }

  // ── System prompt constrains answers to metro domain ─────────────────
  static const _systemPrompt = '''
You are "Namma Metro Sahaya", an AI assistant for the Bangalore Namma Metro system.

ONLY answer questions related to:
- Namma Metro routes (Purple Line & Green Line)
- Station names and locations
- Fare information
- Token machine usage
- Exit gates and landmarks
- Journey planning help
- Interchange at Majestic (KSR Railway Station)

If the user asks anything unrelated to Namma Metro, politely redirect them.

Key facts:
- Purple Line: Whitefield (Kadugodi) ↔ Mysuru Road (23 stations, East-West)
- Green Line: Nagasandra ↔ Yelachenahalli (23 stations, North-South)  
- Interchange station: Majestic (KSR Railway Station) — transfer takes ~5 minutes
- Fare bands: ≤10 min → ₹10, ≤20 min → ₹20, ≤30 min → ₹30, ≤40 min → ₹40, >40 min → ₹50
- Operational hours: 5:00 AM to 11:00 PM daily

Be concise, friendly, and helpful. If asked in Kannada, respond in Kannada.
''';

  // ── Getters ────────────────────────────────────────────────────────────
  List<NLMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isOnline => _apiKey.isNotEmpty && _model != null;

  // ── Send query ─────────────────────────────────────────────────────────
  Future<void> sendQuery(String userText) async {
    if (userText.trim().isEmpty) return;

    // CVE-10 FIX: rate-limit — minimum 2 seconds between requests
    final now = DateTime.now();
    if (_lastQueryTime != null &&
        now.difference(_lastQueryTime!) < const Duration(seconds: 2)) {
      return; // silently ignore rapid-fire taps
    }
    _lastQueryTime = now;

    // Add user message
    _messages.add(NLMessage(
      text: userText.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    // Offline fallback — no API key configured
    if (!isOnline) {
      await Future.delayed(const Duration(milliseconds: 500));
      _messages.add(NLMessage(
        text: _offlineFallbackResponse(userText),
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Send to Gemini
    try {
      final response = await _chat!.sendMessage(Content.text(userText));
      final reply = response.text ?? 'Sorry, I could not understand that.';
      _messages.add(NLMessage(
        text: reply,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      ));
    } on GenerativeAIException catch (e) {
      // CVE-8 FIX: never expose raw API exception details to users
      if (kDebugMode) debugPrint('🤖 Gemini error: ${e.message}');
      _messages.add(NLMessage(
        text: '⚠️ The AI service is temporarily unavailable. Please try again in a moment.',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        isError: true,
      ));
    } catch (e) {
      _messages.add(NLMessage(
        text: _offlineFallbackResponse(userText),
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// BR-01: Offline fallback — rule-based responses for common queries
  String _offlineFallbackResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('fare') || q.contains('price') || q.contains('ದರ') || q.contains('ಬೆಲೆ')) {
      return 'Metro fares: ₹10 (≤10 min), ₹20 (≤20 min), ₹30 (≤30 min), ₹40 (≤40 min), ₹50 (>40 min). '
          'Use the Plan Journey screen for an exact fare.';
    }
    if (q.contains('token') || q.contains('ಟೋಕನ್')) {
      return 'To get a token: Go to the Token Machine → Select Destination → Choose Quantity → '
          'Pay Cash or Card → Collect Token. Use "Plan Journey" to find the right destination fare.';
    }
    if (q.contains('majestic') || q.contains('interchange') || q.contains('ಬದಲಾವಣೆ')) {
      return 'Majestic (KSR Railway Station) is the Interchange between the Purple and Green lines. '
          'Walking time between platforms is approximately 5 minutes. Follow the "Interchange" signs.';
    }
    if (q.contains('purple') || q.contains('ಪರ್ಪಲ್')) {
      return 'The Purple Line (East-West) runs from Whitefield (Kadugodi) to Mysuru Road with 23 stations. '
          'Key stops: Indiranagar, MG Road, Cubbon Park, Vidhana Soudha, Majestic.';
    }
    if (q.contains('green') || q.contains('ಗ್ರೀನ್')) {
      return 'The Green Line (North-South) runs from Nagasandra to Yelachenahalli with 23 stations. '
          'Key stops: Yeshwanthpur, Rajajinagar, Mantri Square, Majestic, Jayanagar, Banashankari.';
    }
    if (q.contains('timing') || q.contains('hours') || q.contains('time') || q.contains('ಸಮಯ')) {
      return 'Namma Metro operates from 5:00 AM to 11:00 PM daily (including weekends and holidays).';
    }
    if (q.contains('exit') || q.contains('gate') || q.contains('ದ್ವಾರ') || q.contains('ನಿರ್ಗಮನ')) {
      return 'Use the "Which Gate?" button after planning your journey to find the nearest exit gate '
          'to your destination landmark.';
    }

    // Generic offline response
    return '⚠️ You are currently offline or the AI service is unavailable. '
        'Please use the Route Planner for journey information, or try this question '
        'when connected to the internet.';
  }

  void clear() {
    _messages.clear();
    // Restart chat session to clear context
    if (_model != null) {
      _chat = _model!.startChat();
    }
    notifyListeners();
  }
}

// ── Data Classes ───────────────────────────────────────────────────────────

enum MessageRole { user, assistant }

class NLMessage {
  final String text;
  final MessageRole role;
  final DateTime? timestamp;
  final bool isError;
  final String? imageUrl; // PRD enhancement: reference images

  const NLMessage({
    required this.text,
    required this.role,
    this.timestamp,
    this.isError = false,
    this.imageUrl,
  });
}
