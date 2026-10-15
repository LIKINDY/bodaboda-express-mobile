import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService extends ChangeNotifier {
  static final UserProfileService instance = UserProfileService._internal();
  UserProfileService._internal();

  static const String _keyFullName = 'customer_full_name';
  static const String _keyPhone = 'customer_phone';
  static const String _keyPhotoUrl = 'customer_photo_url';
  static const String _keyLastRideTimestamp = 'customer_last_ride_timestamp';
  static const String _keyCancellationDebt = 'customer_cancellation_debt';
  static const String _keyIsVerified = 'customer_is_verified';

  String _fullName = 'Juma Ali';
  String _phone = '+255 712 345 670';
  String? _photoPath;
  DateTime? _lastRideRequestDate;
  int _cancellationDebt = 0;
  bool _isVerified = true;

  String get fullName => _fullName;
  String get phone => _phone;
  String? get photoPath => _photoPath;
  DateTime? get lastRideRequestDate => _lastRideRequestDate;
  int get cancellationDebt => _cancellationDebt;
  bool get isVerified => _isVerified;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fullName = prefs.getString(_keyFullName) ?? 'Juma Ali';
      _phone = prefs.getString(_keyPhone) ?? '+255 712 345 670';
      _photoPath = prefs.getString(_keyPhotoUrl);
      _cancellationDebt = prefs.getInt(_keyCancellationDebt) ?? 0;
      _isVerified = prefs.getBool(_keyIsVerified) ?? true;

      final lastTimeStr = prefs.getString(_keyLastRideTimestamp);
      if (lastTimeStr != null) {
        _lastRideRequestDate = DateTime.tryParse(lastTimeStr);
      } else {
        // Default to now for new users
        _lastRideRequestDate = DateTime.now();
        await prefs.setString(_keyLastRideTimestamp, _lastRideRequestDate!.toIso8601String());
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  /// Checks if customer has been inactive for 7 or more days (1 week) without requesting a ride.
  bool isReverificationRequired() {
    if (_lastRideRequestDate == null) return false;
    final difference = DateTime.now().difference(_lastRideRequestDate!);
    return difference.inDays >= 7;
  }

  /// Record that user performed a ride request or reverified via OTP today
  Future<void> recordRideActivityOrVerification() async {
    _lastRideRequestDate = DateTime.now();
    _isVerified = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastRideTimestamp, _lastRideRequestDate!.toIso8601String());
      await prefs.setBool(_keyIsVerified, true);
    } catch (e) {
      debugPrint('Error saving ride activity timestamp: $e');
    }
  }

  /// Save new customer sign up profile
  Future<void> saveProfile({
    required String fullName,
    required String phone,
    String? photoPath,
  }) async {
    _fullName = fullName;
    _phone = phone;
    _photoPath = photoPath;
    _lastRideRequestDate = DateTime.now();
    _isVerified = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyFullName, fullName);
      await prefs.setString(_keyPhone, phone);
      if (photoPath != null) {
        await prefs.setString(_keyPhotoUrl, photoPath);
      }
      await prefs.setString(_keyLastRideTimestamp, _lastRideRequestDate!.toIso8601String());
      await prefs.setBool(_keyIsVerified, true);
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  /// Add cancellation penalty/debt if user cancelled after driver already moved
  Future<void> addCancellationDebt(int amount) async {
    _cancellationDebt += amount;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCancellationDebt, _cancellationDebt);
    } catch (e) {
      debugPrint('Error saving cancellation debt: $e');
    }
  }

  /// Clear cancellation debt upon payment
  Future<void> clearCancellationDebt() async {
    _cancellationDebt = 0;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyCancellationDebt, 0);
    } catch (e) {
      debugPrint('Error clearing debt: $e');
    }
  }
}
