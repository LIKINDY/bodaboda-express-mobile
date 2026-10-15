import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

/// Representation of a street or route segment in Dar es Salaam
class StreetSegment {
  final String id;
  final String name;
  final List<Offset> points; // Normalized coordinates (0..1000)
  final Color trafficColor;
  final String trafficStatus; // 'Hakuna Foleni', 'Foleni Kubwa', etc.
  final bool isShortcut;
  final double strokeWidth;

  const StreetSegment({
    required this.id,
    required this.name,
    required this.points,
    required this.trafficColor,
    required this.trafficStatus,
    this.isShortcut = false,
    this.strokeWidth = 6.0,
  });
}

/// Representation of a demand hotspot in Dar es Salaam
class MapHotspot {
  final String id;
  final String name;
  final Offset position;
  final int waitingCount;
  final String surge;

  const MapHotspot({
    required this.id,
    required this.name,
    required this.position,
    required this.waitingCount,
    required this.surge,
  });
}

/// Representation of an active driver vehicle
class MapDriverMarker {
  final String id;
  final String name;
  final String type; // 'bodaboda' | 'bajaji'
  final Offset position;
  final double heading; // in radians

  const MapDriverMarker({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.heading = 0.0,
  });
}

class SmartStreetMapWidget extends StatefulWidget {
  final bool isLight;
  final bool showHotspots;
  final bool showTraffic;
  final bool showShortcuts;
  final Map<String, dynamic>? activeTrip;
  final VoidCallback? onToggleGoogleMap;

  const SmartStreetMapWidget({
    super.key,
    this.isLight = false,
    this.showHotspots = true,
    this.showTraffic = true,
    this.showShortcuts = true,
    this.activeTrip,
    this.onToggleGoogleMap,
  });

  @override
  State<SmartStreetMapWidget> createState() => _SmartStreetMapWidgetState();
}

class _SmartStreetMapWidgetState extends State<SmartStreetMapWidget>
    with SingleTickerProviderStateMixin {
  final TransformationController _transController =
      TransformationController();
  late AnimationController _pulseController;
  Timer? _driverMovementTimer;

  // Active driver animated positions
  double _tripProgress = 0.25; // 0.0 (at driver start) -> 1.0 (at pickup)

  // Real Dar es Salaam streets mapped to a 1000x1000 canvas
  late List<StreetSegment> _streets;
  late List<MapHotspot> _hotspots;
  late List<MapDriverMarker> _nearbyDrivers;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _initializeDarEsSalaamMapData();
    _fetchBackendMapData();

    // Setup active trip animation if active trip data provided
    if (widget.activeTrip != null) {
      _driverMovementTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (mounted) {
          setState(() {
            _tripProgress = (_tripProgress + 0.05);
            if (_tripProgress > 0.95) _tripProgress = 0.15;
          });
        }
      });
    }

    // Default view centered on Kariakoo / Posta area
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetView();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _driverMovementTimer?.cancel();
    _transController.dispose();
    super.dispose();
  }

  void _resetView() {
    // Zoom slightly into central Dar es Salaam (Kariakoo - Posta corridor)
    final matrix = Matrix4.identity()
      ..translate(-120.0, -160.0)
      ..scale(1.35);
    _transController.value = matrix;
  }

  void _zoomIn() {
    final current = _transController.value;
    final zoomed = current.scaled(1.25, 1.25);
    setState(() => _transController.value = zoomed);
  }

  void _zoomOut() {
    final current = _transController.value;
    final zoomed = current.scaled(0.8, 0.8);
    setState(() => _transController.value = zoomed);
  }

  void _initializeDarEsSalaamMapData() {
    // Canvas reference: (0,0) is North-West (Mwenge/Ubungo), (1000,1000) is South-East (Kivukoni/Ocean)
    _streets = [
      // 1. Morogoro Road (Major spine: Ubungo -> Magomeni -> Fire -> Kariakoo -> Posta)
      const StreetSegment(
        id: 'morogoro_1',
        name: 'Morogoro Road (Ubungo - Magomeni)',
        points: [
          Offset(180, 220), // Ubungo
          Offset(300, 310), // Shekilango
          Offset(430, 420), // Magomeni Mapipa
        ],
        trafficColor: Color(0xFF00E676), // Green = Hakuna Foleni
        trafficStatus: 'Hakuna Foleni • 45 km/h',
        strokeWidth: 9.0,
      ),
      const StreetSegment(
        id: 'morogoro_2',
        name: 'Morogoro Road (Fire - Kariakoo Msimbazi)',
        points: [
          Offset(430, 420), // Magomeni
          Offset(520, 500), // Fire Junction
          Offset(580, 560), // Kariakoo Msimbazi
        ],
        trafficColor: Color(0xFFFF5252), // Red = Foleni Kubwa
        trafficStatus: 'Foleni Kubwa 🔴 +15 min',
        strokeWidth: 9.0,
      ),
      const StreetSegment(
        id: 'morogoro_3',
        name: 'Morogoro Road -> Samora (Posta)',
        points: [
          Offset(580, 560), // Kariakoo
          Offset(690, 610), // Clocktower
          Offset(780, 660), // Posta Mpya
        ],
        trafficColor: Color(0xFF00E676), // Green
        trafficStatus: 'Hakuna Foleni • 40 km/h',
        strokeWidth: 8.0,
      ),

      // 2. Ali Hassan Mwinyi Road (Mwenge -> Morocco -> Selander -> Posta)
      const StreetSegment(
        id: 'mwinyi_1',
        name: 'Ali Hassan Mwinyi Rd (Mwenge - Morocco)',
        points: [
          Offset(380, 140), // Mwenge Stand
          Offset(490, 240), // Morocco
          Offset(610, 360), // Kinondoni Makaburini
        ],
        trafficColor: Color(0xFF00E676), // Green
        trafficStatus: 'Hakuna Foleni • 50 km/h',
        strokeWidth: 8.0,
      ),
      const StreetSegment(
        id: 'mwinyi_2',
        name: 'Ali Hassan Mwinyi Rd (Selander Bridge)',
        points: [
          Offset(610, 360), // Kinondoni
          Offset(710, 470), // Selander Bridge
          Offset(780, 590), // Upanga / Ocean Rd
          Offset(780, 660), // Posta Mpya
        ],
        trafficColor: Color(0xFF00E676), // Green
        trafficStatus: 'Hakuna Foleni • 50 km/h',
        strokeWidth: 8.0,
      ),

      // 3. Msimbazi Street (Kariakoo Center) - RED
      const StreetSegment(
        id: 'msimbazi',
        name: 'Msimbazi Street (Kariakoo)',
        points: [
          Offset(510, 620), // Jangwani
          Offset(580, 560), // Kariakoo Msimbazi
          Offset(640, 520), // DDC / Mnazi Mmoja
        ],
        trafficColor: Color(0xFFFF5252), // Red
        trafficStatus: 'Msongamano wa Magari 🔴',
        strokeWidth: 7.0,
      ),

      // 4. Samora Avenue (Posta CBD) - GREEN
      const StreetSegment(
        id: 'samora',
        name: 'Samora Avenue (Posta)',
        points: [
          Offset(690, 610), // Clocktower
          Offset(760, 640), // Askari Monument
          Offset(830, 680), // Kivukoni Ferry
        ],
        trafficColor: Color(0xFF00E676), // Green
        trafficStatus: 'Hakuna Foleni • 40 km/h',
        strokeWidth: 7.0,
      ),

      // 5. Nyerere Road (Posta -> Tazara -> Uwanja wa Ndege)
      const StreetSegment(
        id: 'nyerere',
        name: 'Julius Nyerere Road',
        points: [
          Offset(690, 610), // Clocktower
          Offset(580, 720), // Kamata / Vingunguti junction
          Offset(420, 830), // Tazara
        ],
        trafficColor: Color(0xFF00E676), // Green
        trafficStatus: 'Hakuna Foleni • 55 km/h',
        strokeWidth: 8.0,
      ),

      // 6. SPECIAL BODABODA SHORTCUT: Kisutu Shortcut (⚡ Okoa Dakika 10)
      const StreetSegment(
        id: 'shortcut_kisutu',
        name: 'Njia ya Mkato (Kisutu Shortcut ⚡)',
        points: [
          Offset(580, 560), // Kariakoo
          Offset(630, 580), // Kisutu Market
          Offset(700, 630), // Posta Sokoine
        ],
        trafficColor: Color(0xFFFFB300), // Amber / Gold = Njia ya Mkato
        trafficStatus: 'Njia ya Mkato ⚡ Hakuna Foleni (Okoa 10 min)',
        isShortcut: true,
        strokeWidth: 6.0,
      ),
    ];

    // High Passenger Demand Hotspots
    _hotspots = const [
      MapHotspot(
        id: 'kariakoo',
        name: 'Kariakoo Msimbazi',
        position: Offset(580, 560),
        waitingCount: 18,
        surge: '1.3x',
      ),
      MapHotspot(
        id: 'posta',
        name: 'Posta Mpya / Kivukoni',
        position: Offset(780, 660),
        waitingCount: 12,
        surge: '1.0x',
      ),
      MapHotspot(
        id: 'ubungo',
        name: 'Ubungo Bus Terminal',
        position: Offset(180, 220),
        waitingCount: 24,
        surge: '1.5x',
      ),
      MapHotspot(
        id: 'mwenge',
        name: 'Mwenge Stand',
        position: Offset(380, 140),
        waitingCount: 15,
        surge: '1.2x',
      ),
    ];

    // Nearby Active Bodaboda and Bajaji Drivers
    _nearbyDrivers = [
      const MapDriverMarker(
        id: 'drv_1',
        name: 'Juma Rajab • MC 123 ABC',
        type: 'bodaboda',
        position: Offset(550, 520),
        heading: 0.75,
      ),
      const MapDriverMarker(
        id: 'drv_2',
        name: 'Bakari Said • MC 789 XYZ',
        type: 'bodaboda',
        position: Offset(630, 590),
        heading: 1.2,
      ),
      const MapDriverMarker(
        id: 'drv_3',
        name: 'Hamis Ally • Bajaji Comfort',
        type: 'bajaji',
        position: Offset(720, 630),
        heading: 2.1,
      ),
      const MapDriverMarker(
        id: 'drv_4',
        name: 'Salum K • MC 445 DEF',
        type: 'bodaboda',
        position: Offset(480, 450),
        heading: 0.4,
      ),
    ];
  }

  /// Attempts to fetch live map text/JSON data from the backend server
  Future<void> _fetchBackendMapData() async {
    try {
      final res = await http
          .get(Uri.parse('http://127.0.0.1:3000/api/map/dar-es-salaam'))
          .timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          debugPrint('Driver Map: Loaded live backend text data: ${data['city']}');
        }
      }
    } catch (_) {
      // Graceful offline fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = !widget.isLight;

    return ClipRect(
      child: Stack(
        children: [
          // ── Interactive Map Canvas ──────────────────────────────────────────
          GestureDetector(
            child: InteractiveViewer(
              transformationController: _transController,
              minScale: 0.6,
              maxScale: 3.5,
              boundaryMargin: const EdgeInsets.all(250),
              child: SizedBox(
                width: 1000,
                height: 1000,
                child: CustomPaint(
                  painter: _DarEsSalaamMapPainter(
                    isDark: isDark,
                    streets: _streets,
                    hotspots: _hotspots,
                    nearbyDrivers: _nearbyDrivers,
                    showHotspots: widget.showHotspots,
                    showTraffic: widget.showTraffic,
                    showShortcuts: widget.showShortcuts,
                    activeTrip: widget.activeTrip,
                    tripProgress: _tripProgress,
                    pulseValue: _pulseController.value,
                  ),
                ),
              ),
            ),
          ),

          // ── Top Status Badges / Traffic Legend ──────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Backend Text Map Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00E676),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '🗺️ Ramani ya Mfumo (Dar es Salaam Live)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (widget.onToggleGoogleMap != null) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: widget.onToggleGoogleMap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Google Map',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Traffic Legend Row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildStatusPill(
                        color: const Color(0xFF00E676),
                        label: 'Kijani: Hakuna Foleni',
                        isDark: isDark,
                      ),
                      _buildStatusPill(
                        color: const Color(0xFFFF5252),
                        label: 'Nyekundu: Foleni Kali',
                        isDark: isDark,
                      ),
                      if (widget.showShortcuts)
                        _buildStatusPill(
                          color: const Color(0xFFFFB300),
                          label: '⚡ Njia ya Mkato',
                          isDark: isDark,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Map Floating Controls (Zoom & Reset) ─────────────────────────────
          Positioned(
            right: 14,
            bottom: widget.activeTrip != null ? 220 : 180,
            child: Column(
              children: [
                _buildMapControlBtn(
                  icon: Icons.add,
                  onTap: _zoomIn,
                  isDark: isDark,
                  tooltip: 'Kuza Ramani',
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.remove,
                  onTap: _zoomOut,
                  isDark: isDark,
                  tooltip: 'Punguza Ramani',
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.my_location,
                  onTap: _resetView,
                  isDark: isDark,
                  tooltip: 'Katikati (Dar es Salaam)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill({
    required Color color,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.9) : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

/// CustomPainter rendering Dar es Salaam geographical features, streets, traffic & markers
class _DarEsSalaamMapPainter extends CustomPainter {
  final bool isDark;
  final List<StreetSegment> streets;
  final List<MapHotspot> hotspots;
  final List<MapDriverMarker> nearbyDrivers;
  final bool showHotspots;
  final bool showTraffic;
  final bool showShortcuts;
  final Map<String, dynamic>? activeTrip;
  final double tripProgress;
  final double pulseValue;

  _DarEsSalaamMapPainter({
    required this.isDark,
    required this.streets,
    required this.hotspots,
    required this.nearbyDrivers,
    required this.showHotspots,
    required this.showTraffic,
    required this.showShortcuts,
    required this.activeTrip,
    required this.tripProgress,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Land Background
    final landPaint = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), landPaint);

    // 2. Draw Indian Ocean / Kivukoni Coastline
    _drawOcean(canvas, size);

    // 3. Draw City Grid
    _drawCityGrid(canvas, size);

    // 4. Draw Major Arteries & Colored Traffic Lines
    _drawStreets(canvas);

    // 5. Draw Active Trip Route
    if (activeTrip != null) {
      _drawActiveTripRoute(canvas);
    }

    // 6. Draw Demand Hotspot Heatmaps with Pulsing Rings
    if (showHotspots) {
      _drawHotspots(canvas);
    }

    // 7. Draw Active Bodaboda and Bajaji Drivers
    _drawDrivers(canvas);

    // 8. Draw Active Trip Moving Driver Marker & Pickup Pin
    if (activeTrip != null) {
      _drawActiveTripMarkers(canvas);
    }
  }

  void _drawOcean(Canvas canvas, Size size) {
    final oceanPaint = Paint()
      ..color = isDark ? const Color(0xFF082F49) : const Color(0xFFBAE6FD)
      ..style = PaintingStyle.fill;

    final coastPath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(750, 0)
      ..cubicTo(740, 180, 820, 320, 770, 480)
      ..cubicTo(730, 560, 820, 620, 840, 680)
      ..cubicTo(860, 750, 920, 800, 900, 1000)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(coastPath, oceanPaint);

    final wavePaint = Paint()
      ..color = isDark ? const Color(0xFF0369A1).withOpacity(0.3) : Colors.blue.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawPath(coastPath, wavePaint);

    final oceanText = TextPainter(
      text: TextSpan(
        text: '🌊 BAHARI YA HINDI (INDIAN OCEAN)',
        style: TextStyle(
          color: isDark ? const Color(0xFF38BDF8).withOpacity(0.4) : const Color(0xFF0369A1).withOpacity(0.5),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    oceanText.paint(canvas, const Offset(820, 180));
  }

  void _drawCityGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B).withOpacity(0.6) : Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.5;

    for (double x = 100; x < 900; x += 75) {
      canvas.drawLine(Offset(x, 100), Offset(x + 50, 850), gridPaint);
    }
    for (double y = 100; y < 850; y += 75) {
      canvas.drawLine(Offset(100, y), Offset(850, y + 40), gridPaint);
    }
  }

  void _drawStreets(Canvas canvas) {
    for (final street in streets) {
      if (street.isShortcut && !showShortcuts) continue;

      final path = Path();
      if (street.points.isNotEmpty) {
        path.moveTo(street.points.first.dx, street.points.first.dy);
        for (int i = 1; i < street.points.length; i++) {
          path.lineTo(street.points[i].dx, street.points[i].dy);
        }
      }

      final casingPaint = Paint()
        ..color = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = street.strokeWidth + 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, casingPaint);

      final trafficColor = showTraffic ? street.trafficColor : const Color(0xFF94A3B8);
      final linePaint = Paint()
        ..color = trafficColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = street.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (street.isShortcut) {
        _drawDashedPath(canvas, path, linePaint, dashLength: 10, dashSpace: 6);
      } else {
        canvas.drawPath(path, linePaint);
      }

      if (street.points.length >= 2) {
        final midIdx = street.points.length ~/ 2;
        final labelPos = street.points[midIdx];
        final textPainter = TextPainter(
          text: TextSpan(
            text: street.name,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              backgroundColor: isDark
                  ? const Color(0xFF0F172A).withOpacity(0.7)
                  : Colors.white.withOpacity(0.8),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(labelPos.dx - (textPainter.width / 2), labelPos.dy - 16));
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint,
      {required double dashLength, required double dashSpace}) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double end = math.min(distance + dashLength, metric.length);
        final extract = metric.extractPath(distance, end);
        canvas.drawPath(extract, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  void _drawActiveTripRoute(Canvas canvas) {
    final greenPath = Path()
      ..moveTo(520, 500)
      ..lineTo(580, 560);
    final greenPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(greenPath, greenPaint);

    final redPath = Path()
      ..moveTo(580, 560)
      ..lineTo(680, 610)
      ..lineTo(780, 660);
    final redPaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(redPath, redPaint);
  }

  void _drawHotspots(Canvas canvas) {
    for (final h in hotspots) {
      final radarRadius = 35.0 + (pulseValue * 25.0);
      final radarPaint = Paint()
        ..color = const Color(0xFFFF1744).withOpacity((1.0 - pulseValue) * 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(h.position, radarRadius, radarPaint);

      final corePaint = Paint()
        ..color = const Color(0xFFFF5252).withOpacity(0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(h.position, 28, corePaint);

      final borderPaint = Paint()
        ..color = const Color(0xFFFF1744)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(h.position, 28, borderPaint);

      final labelPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '🔥 ${h.name}\n',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
            TextSpan(
              text: '${h.waitingCount} abiria • ${h.surge} surge',
              style: const TextStyle(
                color: Color(0xFFFFD54F),
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final bgRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(h.position.dx, h.position.dy + 38),
          width: labelPainter.width + 12,
          height: labelPainter.height + 6,
        ),
        const Radius.circular(6),
      );

      final bgPaint = Paint()..color = const Color(0xFF1E293B).withOpacity(0.9);
      canvas.drawRRect(bgRect, bgPaint);
      canvas.drawRRect(bgRect, borderPaint..strokeWidth = 1);
      labelPainter.paint(
        canvas,
        Offset(h.position.dx - (labelPainter.width / 2), h.position.dy + 35),
      );
    }
  }

  void _drawDrivers(Canvas canvas) {
    for (final d in nearbyDrivers) {
      _drawMotorcycleMarker(canvas, d.position, d.name, d.type == 'bajaji');
    }
  }

  void _drawActiveTripMarkers(Canvas canvas) {
    final pickupPos = const Offset(580, 560);
    _drawLocationPin(
      canvas,
      pickupPos,
      '📍 Kituo Chako',
      const Color(0xFF00E676),
    );

    final dropoffPos = const Offset(780, 660);
    _drawLocationPin(
      canvas,
      dropoffPos,
      '🏁 Mwisho wa Safari',
      const Color(0xFF2979FF),
    );

    final currentRiderPos = Offset(
      520 + (60 * tripProgress),
      500 + (60 * tripProgress),
    );

    _drawMovingRider(canvas, currentRiderPos, '🏍️ Juma (Dereva Yupo Njiani)');
  }

  void _drawLocationPin(Canvas canvas, Offset pos, String title, Color pinColor) {
    final pinPaint = Paint()..color = pinColor;
    canvas.drawCircle(pos, 10, pinPaint);

    final whiteCenter = Paint()..color = Colors.white;
    canvas.drawCircle(pos, 4, whiteCenter);

    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: const Color(0xFF0F172A).withOpacity(0.85),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - (tp.width / 2), pos.dy - 22));
  }

  void _drawMotorcycleMarker(
      Canvas canvas, Offset pos, String label, bool isBajaji) {
    final haloPaint = Paint()
      ..color = (isBajaji ? Colors.purple : AppTheme.primaryBlue).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 14, haloPaint);

    final basePaint = Paint()
      ..color = isBajaji ? const Color(0xFF7C3AED) : const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 9, basePaint);

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(pos, 9, outlinePaint);

    final labelTp = TextPainter(
      text: TextSpan(
        text: isBajaji ? '🛺 Bajaji' : '🏍️ Boda',
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelTp.paint(canvas, Offset(pos.dx - (labelTp.width / 2), pos.dy + 12));
  }

  void _drawMovingRider(Canvas canvas, Offset pos, String title) {
    final haloRadius = 16.0 + (pulseValue * 12.0);
    final haloPaint = Paint()
      ..color = const Color(0xFF2979FF).withOpacity((1.0 - pulseValue) * 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, haloRadius, haloPaint);

    final corePaint = Paint()..color = const Color(0xFF2979FF);
    canvas.drawCircle(pos, 14, corePaint);

    final whiteRing = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(pos, 14, whiteRing);

    final tp = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          backgroundColor: Color(0xFF1E293B),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - (tp.width / 2), pos.dy - 26));
  }

  @override
  bool shouldRepaint(covariant _DarEsSalaamMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.tripProgress != tripProgress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.showTraffic != showTraffic;
  }
}
