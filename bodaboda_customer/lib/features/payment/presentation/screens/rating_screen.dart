import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 5;
  int? _selectedTip;
  final _reviewController = TextEditingController();
  final _customTipController = TextEditingController();

  final List<String> _tipAmounts = ['TSH 500', 'TSH 1,000', 'TSH 2,000', 'TSH 5,000', 'TSH 10,000'];

  @override
  void dispose() {
    _reviewController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  String get _ratingLabel {
    switch (_rating) {
      case 5: return 'Excellent';
      case 4: return 'Good';
      case 3: return 'Average';
      case 2: return 'Poor';
      case 1: return 'Terrible';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox(),
        title: const Text('Payment', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => context.goNamed('dashboard'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              _ratingLabel,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              'You rated Juma Rajab $_rating star${_rating > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 28),

            // Review text field
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your review...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Tip section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Give some tips to Juma Rajab',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 15),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_tipAmounts.length, (index) {
                final isSelected = _selectedTip == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTip = _selectedTip == index ? null : index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      _tipAmounts[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final amount = await showDialog<int>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Other tip amount'),
                    content: TextField(
                      controller: _customTipController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount (TZS)'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(dialogContext, int.tryParse(_customTipController.text)), child: const Text('Set tip')),
                    ],
                  ),
                );
                if (amount != null && amount > 0) {
                  if (!mounted) return;
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  if (messenger == null) return;
                  messenger.showSnackBar(SnackBar(content: Text('Tip set to TZS $amount (demo).')));
                  setState(() {});
                }
              },
              child: const Text('Enter other amount', style: TextStyle(color: AppTheme.primaryBlue)),
            ),

            const SizedBox(height: 28),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.pushNamed('thank-you'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
