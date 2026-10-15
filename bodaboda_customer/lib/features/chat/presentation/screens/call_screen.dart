import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _muted = false;
  bool _speaker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Calling...',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 24),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 80),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Juma Rajab',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bodaboda Driver',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallButton(_muted ? Icons.mic_off : Icons.mic, _muted ? AppTheme.accentRed : Colors.white24, Colors.white, onPressed: () => setState(() => _muted = !_muted)),
                  _buildCallButton(Icons.call_end, AppTheme.accentRed, Colors.white, size: 72, onPressed: () {
                    Navigator.pop(context);
                  }),
                  _buildCallButton(_speaker ? Icons.volume_up : Icons.hearing, _speaker ? AppTheme.ecoGreen : Colors.white24, Colors.white, onPressed: () => setState(() => _speaker = !_speaker)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton(IconData icon, Color bgColor, Color iconColor, {double size = 56, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}
