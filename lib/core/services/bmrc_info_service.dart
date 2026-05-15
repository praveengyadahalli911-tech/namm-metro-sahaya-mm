/// BmrcInfoService: Provides real BMRC data extracted from bmrc.co.in
/// Sources:
///   • bmrc.co.in/metro-timings
///   • bmrc.co.in/fare-rules
///
/// NOTE: BMRC does NOT expose a public real-time API.
/// This service provides time-aware official data.
class BmrcInfoService {
  BmrcInfoService._();

  // ── Official Operating Hours (from bmrc.co.in/metro-timings) ──────────────
  static const BmrcTimeOfDay purpleFirstTrain = BmrcTimeOfDay(hour: 5, minute: 30);
  static const BmrcTimeOfDay purpleLastTrain  = BmrcTimeOfDay(hour: 23, minute: 30);
  static const BmrcTimeOfDay greenFirstTrain  = BmrcTimeOfDay(hour: 5, minute: 30);
  static const BmrcTimeOfDay greenLastTrain   = BmrcTimeOfDay(hour: 23, minute: 30);

  // Contact
  static const String helplineNumber    = '1800-425-12345';
  static const String travelHelpEmail   = 'travelhelp@bmrc.co.in';
  static const String contactEmail      = 'contactus@bmrc.co.in';
  static const String whatsappNumber    = '81055-56677';

  // ── Official Fare Table (from bmrc.co.in/fare-rules — revised Feb 2025) ──
  // Token fares by distance slab (₹)
  static const List<FareSlab> officialFareSlabs = [
    FareSlab(minKm: 0,  maxKm: 2,  tokenFare: 10, smartCardFare: 10),
    FareSlab(minKm: 2,  maxKm: 4,  tokenFare: 20, smartCardFare: 19),
    FareSlab(minKm: 4,  maxKm: 6,  tokenFare: 30, smartCardFare: 29),
    FareSlab(minKm: 6,  maxKm: 8,  tokenFare: 40, smartCardFare: 38),
    FareSlab(minKm: 8,  maxKm: 12, tokenFare: 50, smartCardFare: 48),
    FareSlab(minKm: 12, maxKm: 16, tokenFare: 60, smartCardFare: 57),
    FareSlab(minKm: 16, maxKm: 20, tokenFare: 70, smartCardFare: 67),
    FareSlab(minKm: 20, maxKm: 24, tokenFare: 80, smartCardFare: 76),
    FareSlab(minKm: 24, maxKm: 30, tokenFare: 90, smartCardFare: 86),
    FareSlab(minKm: 30, maxKm: 999, tokenFare: 100, smartCardFare: 95),
  ];

  // Smart card discount: 5% on token fare (official)
  static const double smartCardDiscountPercent = 5.0;

  // ── Official Rules (from bmrc.co.in/fare-rules) ────────────────────────────
  static const List<OfficialRule> officialRules = [
    OfficialRule(
      title: 'Children Free',
      titleKn: 'ಮಕ್ಕಳಿಗೆ ಉಚಿತ',
      detail: 'Children under 3 feet height travel free (no age restriction).',
      detailKn: '3 ಅಡಿಗಿಂತ ಕಡಿಮೆ ಎತ್ತರ ಇರುವ ಮಕ್ಕಳಿಗೆ ಟಿಕೆಟ್ ಬೇಡ.',
      icon: '👶',
    ),
    OfficialRule(
      title: 'Token Validity',
      titleKn: 'ಟೋಕನ್ ಮಾನ್ಯತೆ',
      detail: 'Token is valid only on the day of purchase. Must be used within 30 minutes of purchase to enter.',
      detailKn: 'ಟೋಕನ್ ಖರೀದಿಸಿದ 30 ನಿಮಿಷದಲ್ಲಿ ಗೇಟ್ ಪ್ರವೇಶಿಸಬೇಕು.',
      icon: '🎫',
    ),
    OfficialRule(
      title: 'Max Stay',
      titleKn: 'ಗರಿಷ್ಠ ಸಮಯ',
      detail: 'Must exit same station within 20 mins, other stations within 120 mins. Overstay: ₹50/hr (max ₹100).',
      detailKn: 'ಒಂದೇ ನಿಲ್ದಾಣ: 20 ನಿಮಿಷ. ಬೇರೆ ನಿಲ್ದಾಣ: 120 ನಿಮಿಷ. ₹50/ಗಂ ದಂಡ.',
      icon: '⏱️',
    ),
    OfficialRule(
      title: 'Lost Ticket Fine',
      titleKn: 'ಟಿಕೆಟ್ ಕಳೆದರೆ',
      detail: 'Fine: Maximum token fare + ₹200 penalty for ticket-less travel.',
      detailKn: 'ಗರಿಷ್ಠ ಟೋಕನ್ ದರ + ₹200 ದಂಡ.',
      icon: '💸',
    ),
    OfficialRule(
      title: 'Luggage Limit',
      titleKn: 'ಸಾಮಾನು ಮಿತಿ',
      detail: '1 bag per person (60×45×25 cm). Extra bag: ₹30. Oversized without ticket: ₹250 fine.',
      detailKn: '1 ಬ್ಯಾಗ್ (60×45×25 ಸೆಂ). ಹೆಚ್ಚುವರಿ: ₹30. ₹250 ದಂಡ.',
      icon: '🧳',
    ),
    OfficialRule(
      title: 'Mismatch Fine',
      titleKn: 'ಮಿಸ್ ಮ್ಯಾಚ್ ದಂಡ',
      detail: 'Not tapping at gate entry/exit: ₹10 fine + minimum fare.',
      detailKn: 'ಗೇಟ್‌ನಲ್ಲಿ ಟ್ಯಾಪ್ ಮಾಡದಿದ್ದರೆ: ₹10 + ಕನಿಷ್ಠ ದರ.',
      icon: '🚫',
    ),
    OfficialRule(
      title: 'Smart Card Discount',
      titleKn: 'ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್ ರಿಯಾಯಿತಿ',
      detail: '5% discount on token fares when using Smart Card.',
      detailKn: 'ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್ ಬಳಸಿದರೆ 5% ರಿಯಾಯಿತಿ.',
      icon: '💳',
    ),
    OfficialRule(
      title: 'Token per Passenger',
      titleKn: 'ಒಬ್ಬರಿಗೆ 6 ಟೋಕನ್',
      detail: 'Max 6 tokens can be bought per passenger per transaction.',
      detailKn: 'ಒಬ್ಬ ವ್ಯಕ್ತಿ ಗರಿಷ್ಠ 6 ಟೋಕನ್ ಖರೀದಿಸಬಹುದು.',
      icon: '🔢',
    ),
    OfficialRule(
      title: 'Smart Card Balance',
      titleKn: 'ಕನಿಷ್ಠ ಬ್ಯಾಲೆನ್ಸ್',
      detail: 'Minimum ₹90 balance needed to enter. Max load: ₹3000 (at station) or ₹2950 (online).',
      detailKn: 'ಕನಿಷ್ಠ ₹90 ಬ್ಯಾಲೆನ್ಸ್ ಬೇಕು. ಗರಿಷ್ಠ ₹3000.',
      icon: '💰',
    ),
  ];

  // ── Official Service Frequency (from bmrc.co.in/metro-timings) ─────────────
  static ServiceFrequency getFrequency(BmrcTimeOfDay now) {
    final mins = now.hour * 60 + now.minute;
    // Peak hours: 7:30–10:30am and 5:00–9:00pm
    if ((mins >= 450 && mins <= 630) || (mins >= 1020 && mins <= 1260)) {
      return const ServiceFrequency(
        label: 'Peak Hours',
        labelKn: 'ಪೀಕ್ ಸಮಯ',
        purpleFreqMins: 3,
        greenFreqMins: 4,
      );
    }
    // Night / off-peak
    if (mins < 330 || mins > 1380) {
      return const ServiceFrequency(
        label: 'Non-Operating',
        labelKn: 'ಸೇವೆ ಇಲ್ಲ',
        purpleFreqMins: 0,
        greenFreqMins: 0,
      );
    }
    return const ServiceFrequency(
      label: 'Off-Peak',
      labelKn: 'ಸಾಮಾನ್ಯ ಸಮಯ',
      purpleFreqMins: 6,
      greenFreqMins: 8,
    );
  }

  /// Is the metro currently running?
  static bool isMetroRunning({BmrcTimeOfDay? at}) {
    final now = at ?? _nowToD();
    final mins = now.hour * 60 + now.minute;
    return mins >= 330 && mins <= 1410;
  }

  /// Minutes until next train (approximate based on frequency)
  static int minutesToNextTrain(String lineId, {BmrcTimeOfDay? at}) {
    final now = at ?? _nowToD();
    if (!isMetroRunning(at: now)) return -1;
    final freq = getFrequency(now);
    final freqMins = lineId == 'purple' ? freq.purpleFreqMins : freq.greenFreqMins;
    if (freqMins == 0) return -1;
    // Simulate next arrival: use current minute modulo frequency
    final nowMinute = now.minute;
    final nextArrival = ((nowMinute ~/ freqMins) + 1) * freqMins;
    return (nextArrival - nowMinute) % freqMins == 0 ? freqMins : (nextArrival - nowMinute) % freqMins;
  }

  static BmrcTimeOfDay _nowToD() {
    final n = DateTime.now();
    return BmrcTimeOfDay(hour: n.hour, minute: n.minute);
  }
}

// ── Data Classes ──────────────────────────────────────────────────────────────

class FareSlab {
  final int minKm;
  final int maxKm;
  final int tokenFare;
  final int smartCardFare;
  const FareSlab({
    required this.minKm,
    required this.maxKm,
    required this.tokenFare,
    required this.smartCardFare,
  });

  String get slabLabel => maxKm >= 999 ? '>$minKm km' : '$minKm–$maxKm km';
}

class OfficialRule {
  final String title;
  final String titleKn;
  final String detail;
  final String detailKn;
  final String icon;
  const OfficialRule({
    required this.title,
    required this.titleKn,
    required this.detail,
    required this.detailKn,
    required this.icon,
  });
}

class ServiceFrequency {
  final String label;
  final String labelKn;
  final int purpleFreqMins;
  final int greenFreqMins;
  const ServiceFrequency({
    required this.label,
    required this.labelKn,
    required this.purpleFreqMins,
    required this.greenFreqMins,
  });
}

class BmrcTimeOfDay {
  final int hour;
  final int minute;
  const BmrcTimeOfDay({required this.hour, required this.minute});
}
