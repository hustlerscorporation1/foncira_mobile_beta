import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — User Mode Provider (Buyer/Seller)
// ══════════════════════════════════════════════════════════════

enum UserMode { buyer, seller }

class UserModeProvider with ChangeNotifier {
  static const String _modeKey = 'user_mode';
  static const String _modeTooltipSeenKey = 'mode_badge_tooltip_seen';

  UserMode _currentMode = UserMode.buyer;
  bool _modeTooltipSeen = false;
  SharedPreferences? _prefs;
  Future<void>? _initFuture;

  UserMode get currentMode => _currentMode;
  bool get isBuyerMode => _currentMode == UserMode.buyer;
  bool get isSellerMode => _currentMode == UserMode.seller;
  bool get shouldShowModeTooltip => !_modeTooltipSeen;
  bool get sellerTooltipSeen => _modeTooltipSeen;

  UserModeProvider() {
    _initFuture = _initializeMode();
  }

  Future<void> _initializeMode() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();

    // Load saved mode
    final savedMode = _prefs!.getString(_modeKey);
    if (savedMode == 'seller') {
      _currentMode = UserMode.seller;
    } else {
      _currentMode = UserMode.buyer;
    }

    // Load tooltip state (mode badge tooltip)
    _modeTooltipSeen = _prefs!.getBool(_modeTooltipSeenKey) ?? false;

    notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    _initFuture ??= _initializeMode();
    await _initFuture;
  }

  Future<void> switchMode(UserMode mode) async {
    await _ensureInitialized();
    if (_currentMode == mode) return;

    _currentMode = mode;

    // Save mode preference
    final modeString = mode == UserMode.seller ? 'seller' : 'buyer';
    await _prefs!.setString(_modeKey, modeString);

    notifyListeners();
  }

  Future<void> markModeTooltipSeen() async {
    await _ensureInitialized();
    _modeTooltipSeen = true;
    await _prefs!.setBool(_modeTooltipSeenKey, true);
    notifyListeners();
  }

  Future<void> markSellerTooltipSeen() async {
    await markModeTooltipSeen();
  }

  Future<void> resetMode() async {
    await _ensureInitialized();
    _currentMode = UserMode.buyer;
    _modeTooltipSeen = false;
    await _prefs!.setString(_modeKey, 'buyer');
    await _prefs!.setBool(_modeTooltipSeenKey, false);
    notifyListeners();
  }
}
