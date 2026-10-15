import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class FuelWalletScreen extends StatelessWidget {
  const FuelWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: isDark ? Colors.white : AppTheme.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Fuel Wallet',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
              height: 32,
              errorBuilder: (_, __, ___) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'X',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Express',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── Physical-looking Fuel Card ──────────────────────────────
              _PhysicalFuelCard(isDark: isDark),

              const SizedBox(height: 48),

              // ── Balance Info ────────────────────────────────────────────
              Text(
                'Fuel Wallet Balance',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'TZS 45,000',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Approx. 15 Litres remaining',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white38 : AppTheme.textLight,
                ),
              ),

              const Spacer(),

              // ── Buttons ─────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Top up fuel card'),
                      content: const Text('Chagua TZS 10,000, 20,000 au 50,000. Hii ni demo; malipo halisi yataunganishwa na backend.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Top-up imehifadhiwa kama ombi la demo.')));
                          },
                          child: const Text('Continue'),
                        ),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Top Up Card',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (context) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Fuel station history', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            const ListTile(leading: Icon(Icons.local_gas_station), title: Text('Mlimani Fuel Station'), subtitle: Text('Today · 8 Litres'), trailing: Text('TZS 24,000')),
                            const ListTile(leading: Icon(Icons.local_gas_station), title: Text('Kariakoo Fuel Station'), subtitle: Text('Yesterday · 5 Litres'), trailing: Text('TZS 15,000')),
                          ],
                        ),
                      ),
                    ),
                  ),
                  icon: Icon(Icons.history,
                      color: isDark ? Colors.white70 : AppTheme.textDark),
                  label: Text(
                    'Fuel Station History',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : AppTheme.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLoanDialog(context),
                  icon: const Icon(Icons.handshake_outlined, color: AppTheme.accentRed),
                  label: const Text(
                    'Request Fuel Loan',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.accentRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoanDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _FuelLoanFormSheet(),
    );
  }
}

// ── Fuel Loan Form Sheet ───────────────────────────────────────────────────

class _FuelLoanFormSheet extends StatefulWidget {
  const _FuelLoanFormSheet();

  @override
  State<_FuelLoanFormSheet> createState() => _FuelLoanFormSheetState();
}

class _FuelLoanFormSheetState extends State<_FuelLoanFormSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cardController = TextEditingController(text: '**** **** **** 4588'); // Auto-filled
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tafadhali weka kiasi (TZS)', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.accentRed),
      );
      return;
    }
    setState(() => _isLoading = true);
    
    // Simulate backend request
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maombi ya mkopo yametumwa kikamilifu! Tunasubiri majibu ya backend.'),
          backgroundColor: AppTheme.ecoGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: bottomInset + 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Request Fuel Loan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: isDark ? Colors.white54 : AppTheme.textLight),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Jaza fomu hii kuomba mkopo wa mafuta utakaokatwa kwenye malipo yako yajayo.',
            style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : AppTheme.textLight),
          ),
          const SizedBox(height: 24),
          
          // Card Number Field (Auto-filled)
          Text('Fuel Card Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppTheme.textDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _cardController,
            enabled: false, // Read-only since it's auto-filled
            style: TextStyle(color: isDark ? Colors.white54 : AppTheme.textLight),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.credit_card),
              filled: true,
              fillColor: isDark ? const Color(0xFF0D1117) : Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          
          // Amount Field
          Text('Kiasi Unachohitaji (TZS)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppTheme.textDark)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              prefixText: 'TZS ',
              hintText: 'Mfano: 10000',
              filled: true,
              fillColor: isDark ? const Color(0xFF0D1117) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accentRed, width: 2)),
            ),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Tuma Maombi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Physical Card Widget ────────────────────────────────────────────────────

class _PhysicalFuelCard extends StatefulWidget {
  final bool isDark;
  const _PhysicalFuelCard({required this.isDark});

  @override
  State<_PhysicalFuelCard> createState() => _PhysicalFuelCardState();
}

class _PhysicalFuelCardState extends State<_PhysicalFuelCard> {
  bool _isNumberVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Gradient border via outer container trick
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1565C0), // Blue
            Color(0xFF4CAF50), // Green
            Color(0xFFD32F2F), // Red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(isDark ? 0.5 : 0.25),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.5), // Border width
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A2340), const Color(0xFF243B6E)]
                : [const Color(0xFFB0C4DE), const Color(0xFFD6E4F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Glossy geometric background shapes ──────────────────
            Positioned(
              top: -30,
              right: -30,
              child: _glassDiamond(100, isDark),
            ),
            Positioned(
              bottom: -20,
              left: 40,
              child: _glassDiamond(80, isDark),
            ),
            Positioned(
              top: 10,
              left: -20,
              child: _glassDiamond(60, isDark),
            ),

            // ── Card content ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row: chip + logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // EMV chip icon
                      _ChipIcon(isDark: isDark),

                      // Logo
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Bodaboda',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black45,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentRed,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'X',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Express',
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppTheme.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Card number
                  Row(
                    children: [
                      Text(
                        _isNumberVisible ? '4588 1234 9876 5432' : '**** **** **** 4588',
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isNumberVisible = !_isNumberVisible),
                        child: Icon(
                          _isNumberVisible ? Icons.visibility_off : Icons.visibility,
                          color: isDark ? Colors.white54 : Colors.black45,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  // Card holder name
                  Text(
                    'Juma Ali',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.textDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassDiamond(double size, bool isDark) {
    return Transform.rotate(
      angle: 0.785398, // 45 degrees
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// ── EMV Chip Icon ───────────────────────────────────────────────────────────

class _ChipIcon extends StatelessWidget {
  final bool isDark;
  const _ChipIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final chipColor = isDark ? const Color(0xFFB8A96A) : const Color(0xFFD4A843);
    final lineColor = isDark ? const Color(0xFF8A7A50) : const Color(0xFFB8903A);

    return Container(
      width: 46,
      height: 34,
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          colors: [chipColor, lineColor, chipColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: CustomPaint(painter: _ChipPainter(lineColor: lineColor)),
    );
  }
}

class _ChipPainter extends CustomPainter {
  final Color lineColor;
  const _ChipPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    // Horizontal center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    // Top segment line
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.25, size.height * 0.45),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, 0),
      Offset(size.width * 0.75, size.height * 0.45),
      paint,
    );
    // Bottom segment line
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.55),
      Offset(size.width * 0.25, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, size.height * 0.55),
      Offset(size.width * 0.75, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ChipPainter oldDelegate) => false;
}
