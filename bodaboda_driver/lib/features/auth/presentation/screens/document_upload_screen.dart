import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bodaboda_driver/core/theme/app_theme.dart';

enum IdDocumentType { nida, voterCard, localLetter }

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  bool _isFaceUploaded = true;
  IdDocumentType _selectedIdType = IdDocumentType.nida;
  bool _isIdUploaded = false;
  final TextEditingController _idNumberController = TextEditingController();

  @override
  void dispose() {
    _idNumberController.dispose();
    super.dispose();
  }

  void _onCaptureFace() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.face_retouching_natural, color: AppTheme.primaryBlue, size: 44),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Uhakiki wa Uso (Face Photo)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hakikisha uso wako unaonekana vizuri bila miwani ya giza au kofia. Mwanga uwe wa kutosha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _isFaceUploaded = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Picha ya uso imepigwa na kuhakikiwa kikamilifu!'),
                          backgroundColor: AppTheme.ecoGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Piga Picha ya Uso Sasa'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onUploadIdDoc() {
    setState(() => _isIdUploaded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_idTypeLabel(_selectedIdType)} imepakiwa kikamilifu!'),
        backgroundColor: AppTheme.ecoGreen,
      ),
    );
  }

  String _idTypeLabel(IdDocumentType type) {
    switch (type) {
      case IdDocumentType.nida:
        return 'Kitambulisho cha NIDA';
      case IdDocumentType.voterCard:
        return 'Kadi ya Kupiga Kura';
      case IdDocumentType.localLetter:
        return 'Barua ya Sheha / Mwenyekiti';
    }
  }

  void _onContinue() {
    if (!_isFaceUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali piga picha ya uso (Face photo)'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    if (!_isIdUploaded && _idNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tafadhali weka angalau kimoja kati ya NIDA, Kadi ya Kura, au Barua ya Sheha'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    context.push('/set-password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Pakia Nyaraka za Utambulisho',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pakia picha ya uso na uchague kimoja kati ya vitambulisho vitatu vilivyoainishwa ili kuthibitisha akaunti yako ya udereva.',
                style: TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),

              // ── 1. Face Photo (Picha ya Uso - live verification) ─────────
              const Text(
                '1. Picha Halisi ya Uso (Face Photo)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              const Text(
                'Picha iwe ya uso mzima (sio passport ya karatasi tu), piga moja kwa moja.',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: _onCaptureFace,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.inputBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isFaceUploaded ? AppTheme.ecoGreen : AppTheme.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isFaceUploaded ? AppTheme.ecoGreen.withOpacity(0.12) : AppTheme.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFaceUploaded ? Icons.verified_user : Icons.face,
                          color: _isFaceUploaded ? AppTheme.ecoGreen : AppTheme.primaryBlue,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Picha ya Uso (Live Face Selfie)',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isFaceUploaded ? 'Uso umethibitishwa kikamilifu ✓' : 'Gusa hapa kupiga picha ya uso',
                              style: TextStyle(
                                color: _isFaceUploaded ? AppTheme.ecoGreen : AppTheme.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isFaceUploaded ? Icons.check_circle : Icons.camera_alt,
                        color: _isFaceUploaded ? AppTheme.ecoGreen : AppTheme.primaryBlue,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── 2. Identification Document (Choose 1 of 3) ─────────────────
              Row(
                children: const [
                  Text(
                    '2. Kitambulisho Kikuu ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                  ),
                  Text(
                    '(Chagua kimoja kati ya hivi 3)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Weka namba na picha ya kitambulisho ulichonacho.',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 12),

              // Radio Options for 3 ID types
              _buildIdOptionTile(
                type: IdDocumentType.nida,
                title: 'NIDA (Kitambulisho cha Taifa)',
                hint: 'Namba ya NIDA (mfano: 19900101-...)',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 8),
              _buildIdOptionTile(
                type: IdDocumentType.voterCard,
                title: 'Kadi ya Kupiga Kura (Voter Card)',
                hint: 'Namba ya Kadi ya Kura (mfano: T-1234-...)',
                icon: Icons.how_to_vote_outlined,
              ),
              const SizedBox(height: 8),
              _buildIdOptionTile(
                type: IdDocumentType.localLetter,
                title: 'Barua ya Sheha / Mwenyekiti wa Mtaa',
                hint: 'Jina la Mtaa & Kumbukumbu ya Barua',
                icon: Icons.mark_email_read_outlined,
              ),

              const SizedBox(height: 16),

              // Document input & upload card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jaza Namba ya ${_idTypeLabel(_selectedIdType)}:',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _idNumberController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Weka namba au maelezo ya utambulisho...',
                        prefixIcon: const Icon(Icons.pin, color: AppTheme.primaryBlue, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _onUploadIdDoc,
                        icon: Icon(
                          _isIdUploaded ? Icons.check_circle : Icons.upload_file,
                          color: _isIdUploaded ? AppTheme.ecoGreen : AppTheme.primaryBlue,
                          size: 18,
                        ),
                        label: Text(
                          _isIdUploaded ? 'Picha ya Kitambulisho Imepakiwa ✓' : 'Pakia Picha ya ${_idTypeLabel(_selectedIdType)}',
                          style: TextStyle(
                            color: _isIdUploaded ? AppTheme.ecoGreen : AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: _isIdUploaded ? AppTheme.ecoGreen : AppTheme.primaryBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Notice explaining Driving License & LATRA are inside Profile
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Taarifa Muhimu: Leseni ya Udereva na Cheti cha LATRA sasa utavijaza ndani ya Wasifu (Profile) mara baada ya kuingia kwenye app ili akaunti yako iwe hai.',
                        style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Continue Button
              ElevatedButton(
                onPressed: _onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                child: const Text('Endelea (Continue)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdOptionTile({
    required IdDocumentType type,
    required String title,
    required String hint,
    required IconData icon,
  }) {
    final isSelected = _selectedIdType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIdType = type;
          _isIdUploaded = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: isSelected ? AppTheme.primaryBlue : Colors.black54, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                  color: isSelected ? AppTheme.primaryBlue : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
