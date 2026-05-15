/// FeedbackEntry: immutable data model for user feedback.
/// Stored locally (in-memory list, offline-first).
class FeedbackEntry {
  final String id;
  final int rating; // 1–5 stars
  final String category; // 'route', 'exit', 'token', 'general'
  final String message;
  final String stationName; // optional context
  final DateTime submittedAt;
  final bool isAnonymous;

  const FeedbackEntry({
    required this.id,
    required this.rating,
    required this.category,
    required this.message,
    required this.stationName,
    required this.submittedAt,
    required this.isAnonymous,
  });

  /// Human-readable category label
  String get categoryLabel {
    switch (category) {
      case 'route':
        return 'Route Planning';
      case 'exit':
        return 'Exit Finder';
      case 'token':
        return 'Token Machine';
      case 'visual':
        return 'Visual Guide';
      case 'general':
        return 'General';
      default:
        return category;
    }
  }

  /// Emoji for rating
  String get ratingEmoji {
    switch (rating) {
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '😊';
    }
  }
}
