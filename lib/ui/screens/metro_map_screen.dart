import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/station_data_service.dart';

// ─── Simplified station layout for the visual map ────────────────────────────
class _MapStation {
  final String name;
  final Color color;
  final double x; // 0..1 normalized
  final double y;
  final bool isInterchange;
  const _MapStation(this.name, this.color, this.x, this.y,
      {this.isInterchange = false});
}

const Color _purple = Color(0xFFAB47BC);
const Color _green = Color(0xFF43A047);
const Color _yellow = Color(0xFFFDD835);
const Color _interchange = Color(0xFFE53935);

// Purple line — left (Challaghatta) to right (Whitefield), horizontal
final List<_MapStation> _purpleLine = [
  _MapStation('Challaghatta', _purple, 0.03, 0.38),
  _MapStation('Kengeri', _purple, 0.08, 0.38),
  _MapStation('Kengeri Bus Terminal', _purple, 0.12, 0.38),
  _MapStation('Pattanagere', _purple, 0.16, 0.38),
  _MapStation('Nayandahalli', _purple, 0.20, 0.38),
  _MapStation('Mysuru Road', _purple, 0.24, 0.38),
  _MapStation('Deepanjali Nagar', _purple, 0.27, 0.38),
  _MapStation('Attiguppe', _purple, 0.30, 0.36),
  _MapStation('Vijayanagar', _purple, 0.33, 0.34),
  _MapStation('Hosahalli', _purple, 0.36, 0.32),
  _MapStation('Magadi Road', _purple, 0.39, 0.30),
  _MapStation('City Railway Stn.', _purple, 0.43, 0.30),
  _MapStation('Sir M. Visvesvaraya', _purple, 0.48, 0.30),
  _MapStation('Vidhana Soudha', _purple, 0.51, 0.28),
  _MapStation('Cubbon Park', _purple, 0.54, 0.27),
  _MapStation('MG Road', _purple, 0.57, 0.28),
  _MapStation('Trinity', _purple, 0.60, 0.30),
  _MapStation('Halasuru', _purple, 0.63, 0.30),
  _MapStation('Indiranagar', _purple, 0.66, 0.30),
  _MapStation('Swami Vivekananda Rd', _purple, 0.70, 0.32),
  _MapStation('Baiyappanahalli', _purple, 0.74, 0.34),
  _MapStation('Benniganahalli', _purple, 0.77, 0.34),
  _MapStation('KR Puram area', _purple, 0.80, 0.34),
  _MapStation('Hoodi', _purple, 0.83, 0.36),
  _MapStation('Seetharampalya', _purple, 0.86, 0.36),
  _MapStation('Kundalahalli', _purple, 0.88, 0.36),
  _MapStation('Sri Sathya Sai Hosp.', _purple, 0.91, 0.34),
  _MapStation('Pattandur Agrahara', _purple, 0.93, 0.32),
  _MapStation('Kadugodi Tree Park', _purple, 0.95, 0.30),
  _MapStation('Hopefarm', _purple, 0.97, 0.28),
  _MapStation('Whitefield (Kadugodi)', _purple, 0.99, 0.26),
];

// Green line — top (Madavara) going south through Majestic, to Silk Institute
final List<_MapStation> _greenLine = [
  _MapStation('Madavara', _green, 0.18, 0.06),
  _MapStation('Chikkabidarakallu', _green, 0.20, 0.09),
  _MapStation('Manjunathanagara', _green, 0.22, 0.11),
  _MapStation('Nagasandra', _green, 0.24, 0.13),
  _MapStation('Dasarahalli', _green, 0.26, 0.15),
  _MapStation('Jalahalli', _green, 0.28, 0.17),
  _MapStation('Peenya Industry', _green, 0.30, 0.19),
  _MapStation('Peenya', _green, 0.33, 0.20),
  _MapStation('Goraguntepalya', _green, 0.36, 0.21),
  _MapStation('Yeshwantpur', _green, 0.39, 0.22),
  _MapStation('Sandal Soap Factory', _green, 0.41, 0.22),
  _MapStation('Mahalakshmi', _green, 0.43, 0.22),
  _MapStation('Rajajinagar', _green, 0.44, 0.23),
  _MapStatement('Kuvempu Road', _green, 0.44, 0.24),
  _MapStation('Srirampura', _green, 0.44, 0.25),
  _MapStation('Sampige Road', _green, 0.45, 0.26),
  // MAJESTIC INTERCHANGE
  _MapStation('MAJESTIC', _interchange, 0.45, 0.30, isInterchange: true),
  _MapStation('National College', _green, 0.45, 0.35),
  _MapStation('Lalbagh', _green, 0.46, 0.38),
  _MapStation('South End Circle', _green, 0.46, 0.41),
  _MapStation('Jayanagar', _green, 0.46, 0.44),
  _MapStation('Rashtreeya Vidyalaya', _interchange, 0.46, 0.47, isInterchange: true),
  _MapStation('Banashankari', _green, 0.45, 0.50),
  _MapStation('JP Nagar', _green, 0.45, 0.53),
  _MapStation('Yelachenahalli', _green, 0.45, 0.56),
  _MapStation('Konanakunte Cross', _green, 0.44, 0.60),
  _MapStation('Doddakallasandra', _green, 0.43, 0.64),
  _MapStation('Vajarahalli', _green, 0.42, 0.68),
  _MapStation('Thalaghattapura', _green, 0.41, 0.72),
  _MapStation('Silk Institute', _green, 0.39, 0.76),
];

// Yellow line (Phase-2) — right side going south
final List<_MapStation> _yellowLine = [
  _MapStation('Central Silk Board', _yellow, 0.62, 0.48),
  _MapStation('BTM Layout', _yellow, 0.62, 0.51),
  _MapStation('Jayadeva Hospital', _yellow, 0.62, 0.54),
  _MapStation('Bommanahalli', _yellow, 0.63, 0.57),
  _MapStation('Hongasandra', _yellow, 0.64, 0.61),
  _MapStation('Kudlu Gate', _yellow, 0.65, 0.64),
  _MapStation('Singasandra', _yellow, 0.66, 0.67),
  _MapStation('Hosa Road', _yellow, 0.67, 0.70),
  _MapStation('Electronic City', _yellow, 0.68, 0.73),
  _MapStation('Beratena Agrahara', _yellow, 0.69, 0.76),
  _MapStation('Infosys Konappana', _yellow, 0.70, 0.79),
  _MapStation('Huskur Road', _yellow, 0.71, 0.82),
  _MapStation('Biocon Hebbagodi', _yellow, 0.72, 0.85),
  _MapStation('Delta Bommasandra', _yellow, 0.73, 0.88),
];

// Fix typo in helper
_MapStation _MapStatement(String n, Color c, double x, double y) =>
    _MapStation(n, c, x, y);

// ─── Main Screen ──────────────────────────────────────────────────────────────
class MetroMapScreen extends StatefulWidget {
  const MetroMapScreen({super.key});

  @override
  State<MetroMapScreen> createState() => _MetroMapScreenState();
}

class _MetroMapScreenState extends State<MetroMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _trainPurple; // train on purple line
  late AnimationController _trainGreen; // train on green line
  late AnimationController _pulseCtrl; // station pulse
  late AnimationController _entryCtrl; // entry animation

  _MapStation? _selected;
  final TransformationController _transform = TransformationController();

  @override
  void initState() {
    super.initState();

    _trainPurple = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _trainGreen = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _trainPurple.dispose();
    _trainGreen.dispose();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = StationDataService();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: Text(
          '🗺️ Namma Metro Map',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Data source badge
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: svc.isLive
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: svc.isLive ? Colors.greenAccent : Colors.orange,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  svc.isLive ? Icons.wifi : Icons.wifi_off,
                  size: 12,
                  color: svc.isLive ? Colors.greenAccent : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  svc.isLive ? 'LIVE' : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: svc.isLive ? Colors.greenAccent : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Legend bar
          _buildLegend(),

          // MAP
          Expanded(
            child: Stack(
              children: [
                // Pinch-zoom + pan map
                InteractiveViewer(
                  transformationController: _transform,
                  minScale: 0.6,
                  maxScale: 4.0,
                  child: FadeTransition(
                    opacity: _entryCtrl,
                    child: AnimatedBuilder(
                      animation: Listenable.merge(
                          [_trainPurple, _trainGreen, _pulseCtrl]),
                      builder: (ctx, _) {
                        return CustomPaint(
                          painter: _MetroMapPainter(
                            purpleT: _trainPurple.value,
                            greenT: _trainGreen.value,
                            pulse: _pulseCtrl.value,
                            selected: _selected,
                          ),
                          child: GestureDetector(
                            onTapUp: (d) => _onTap(d.localPosition, context),
                            child: const SizedBox(
                              width: 1200,
                              height: 900,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Hint overlay
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '👆 Tap any station  •  🤏 Pinch to zoom',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ).animate().fadeIn(delay: 1.seconds),
                ),
              ],
            ),
          ),

          // Selected station info panel
          if (_selected != null) _buildInfoPanel(_selected!),
        ],
      ),
    );
  }

  // ── Legend ────────────────────────────────────────────────────────────────
  Widget _buildLegend() {
    return Container(
      color: const Color(0xFF161B22),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _legendItem(_purple, '🟣 Purple Line'),
          const SizedBox(width: 16),
          _legendItem(_green, '🟢 Green Line'),
          const SizedBox(width: 16),
          _legendItem(_yellow, '🟡 Yellow Line'),
          const SizedBox(width: 16),
          _legendItem(_interchange, '🔴 Interchange'),
        ],
      ),
    )
        .animate()
        .slideY(begin: -1, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _legendItem(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 8,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // ── Info Panel (slides up when station tapped) ────────────────────────────
  Widget _buildInfoPanel(_MapStation st) {
    final lineLabel = st.color == _purple
        ? 'Purple Line'
        : st.color == _green
            ? 'Green Line'
            : st.color == _yellow
                ? 'Yellow Line (Phase-2)'
                : 'Interchange Station';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border(
          top: BorderSide(color: st.color.withValues(alpha: 0.6), width: 2),
        ),
      ),
      child: Row(
        children: [
          // Colored circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: st.color.withValues(alpha: 0.2),
              border: Border.all(color: st.color, width: 3),
              boxShadow: [
                BoxShadow(
                    color: st.color.withValues(alpha: 0.4), blurRadius: 12)
              ],
            ),
            child: Icon(
              st.isInterchange
                  ? Icons.sync_alt_rounded
                  : Icons.train_rounded,
              color: st.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  st.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.circle, color: st.color, size: 10),
                    const SizedBox(width: 6),
                    Text(lineLabel,
                        style: TextStyle(
                            color: st.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    if (st.isInterchange) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: const Text('INTERCHANGE',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _selected = null),
            icon: const Icon(Icons.close, color: Colors.white54, size: 20),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 1, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  // ── Tap detection ─────────────────────────────────────────────────────────
  void _onTap(Offset localPos, BuildContext context) {
    const w = 1200.0;
    const h = 900.0;
    final all = [..._purpleLine, ..._greenLine, ..._yellowLine];

    for (final st in all) {
      final sx = st.x * w;
      final sy = st.y * h;
      if ((localPos - Offset(sx, sy)).distance < 22) {
        setState(() => _selected = st);
        return;
      }
    }
    setState(() => _selected = null);
  }
}

// ─── Custom Painter ───────────────────────────────────────────────────────────
class _MetroMapPainter extends CustomPainter {
  final double purpleT;
  final double greenT;
  final double pulse;
  final _MapStation? selected;

  const _MetroMapPainter({
    required this.purpleT,
    required this.greenT,
    required this.pulse,
    this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawLine(canvas, size, _purpleLine, _purple);
    _drawLine(canvas, size, _greenLine, _green);
    _drawLine(canvas, size, _yellowLine, _yellow);
    _drawStations(canvas, size, _purpleLine, _purple);
    _drawStations(canvas, size, _greenLine, _green);
    _drawStations(canvas, size, _yellowLine, _yellow);
    _drawTrain(canvas, size, _purpleLine, _purple, purpleT);
    _drawTrain(canvas, size, _greenLine, _green, greenT);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Dark grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawLine(Canvas canvas, Size s, List<_MapStation> line, Color c) {
    if (line.length < 2) return;
    // Glow
    final glowPaint = Paint()
      ..color = c.withValues(alpha: 0.25)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // Main line
    final mainPaint = Paint()
      ..color = c
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(line[0].x * s.width, line[0].y * s.height);
    for (int i = 1; i < line.length; i++) {
      path.lineTo(line[i].x * s.width, line[i].y * s.height);
    }
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, mainPaint);
  }

  void _drawStations(Canvas canvas, Size s, List<_MapStation> line, Color c) {
    for (final st in line) {
      final cx = st.x * s.width;
      final cy = st.y * s.height;
      final isSelected = selected?.name == st.name;

      // Pulse ring for interchange or selected
      if (st.isInterchange || isSelected) {
        final pulseR = (isSelected ? 18 : 12) + pulse * 6;
        canvas.drawCircle(
          Offset(cx, cy),
          pulseR,
          Paint()
            ..color = st.color.withValues(alpha: (1 - pulse) * 0.4)
            ..style = PaintingStyle.fill,
        );
      }

      // Outer ring
      canvas.drawCircle(
        Offset(cx, cy),
        st.isInterchange ? 10 : 7,
        Paint()
          ..color = st.color
          ..style = PaintingStyle.fill,
      );
      // White inner dot
      canvas.drawCircle(
        Offset(cx, cy),
        st.isInterchange ? 5 : 3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );

      // Station name label
      _drawLabel(canvas, st.name, cx, cy, c, isSelected);
    }
  }

  void _drawLabel(
      Canvas canvas, String text, double cx, double cy, Color c, bool big) {
    // Clip name to max 14 chars
    final label =
        text.length > 14 ? '${text.substring(0, 13)}…' : text;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: big ? c : Colors.white70,
          fontSize: big ? 11 : 8.5,
          fontWeight: big ? FontWeight.bold : FontWeight.normal,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy + 10));
  }

  void _drawTrain(Canvas canvas, Size s, List<_MapStation> line, Color c,
      double t) {
    if (line.length < 2) return;

    // Position train along path segments
    final totalSeg = line.length - 1;
    final progress = t * totalSeg;
    final idx = progress.floor().clamp(0, totalSeg - 1);
    final frac = progress - idx;

    final a = line[idx];
    final b = line[idx + 1];
    final tx = (a.x + (b.x - a.x) * frac) * s.width;
    final ty = (a.y + (b.y - a.y) * frac) * s.height;

    // Glow
    canvas.drawCircle(
      Offset(tx, ty),
      14,
      Paint()..color = c.withValues(alpha: 0.3),
    );
    // Train body
    canvas.drawCircle(
      Offset(tx, ty),
      9,
      Paint()..color = c,
    );
    // Train headlight
    canvas.drawCircle(
      Offset(tx, ty),
      4,
      Paint()..color = Colors.white,
    );
    // Train emoji text
    final tp = TextPainter(
      text: const TextSpan(text: '🚇', style: TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(tx - 7, ty - 18));
  }

  @override
  bool shouldRepaint(_MetroMapPainter old) => true;
}
