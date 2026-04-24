import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  FONCIRA — Design System Colors & Constants
// ══════════════════════════════════════════════════════════════

// ── Currency Conversion (Centralized) ────────────────────────
// All prices in DB are stored in FCFA
// Conversion rate: 1 USD = ~655.957 XOF (fixed, updated periodically)
const double kFcfaToUsdRate = 655.957;

// ── Service Pricing ──────────────────────────────────────────
const int kVerificationPriceFCFA = 250000; // 250,000 XOF
const int kVerificationPriceUSD = 380; // $380

// ── Primary ──────────────────────────────────────────────────
const Color kPrimary = Color(0xFF0A6847);
const Color kPrimaryLight = Color(0xFF14A76C);
const Color kPrimaryDark = Color(0xFF064E35);
const Color kPrimarySurface = Color(0x1A0A6847); // 10% opacity

// ── Accent / Gold ────────────────────────────────────────────
const Color kGold = Color(0xFFC8A951);
const Color kGoldLight = Color(0xFFE0C97A);
const Color kGoldDark = Color(0xFF9E8338);
const Color kGoldSurface = Color(0x1AC8A951);

// ── Dark Surfaces ────────────────────────────────────────────
const Color kDarkBg = Color(0xFF0B1215);
const Color kDarkCard = Color(0xFF141E22);
const Color kDarkCardLight = Color(0xFF1C2A30);
const Color kDarkSurface = Color(0xFF0F1A1E);
const Color kDarkElevated = Color(0xFF1E2E34);

// ── Light Surfaces ───────────────────────────────────────────
const Color kLightBg = Color(0xFFF5F7FA);
const Color kLightCard = Colors.white;
const Color kLightSurface = Color(0xFFF0F2F5);

// ── Text Colors ──────────────────────────────────────────────
const Color kTextPrimary = Color(0xFFFFFFFF);
const Color kTextSecondary = Color(0xB3FFFFFF); // 70% white
const Color kTextMuted = Color(0x80FFFFFF); // 50% white
const Color kTextDark = Color(0xFF1A2332);
const Color kTextDarkSecondary = Color(0xFF5A6B7D);
const Color kTextDarkMuted = Color(0xFF8A95A5);

// ── Semantic Colors ──────────────────────────────────────────
const Color kSuccess = Color(0xFF22C55E);
const Color kSuccessLight = Color(0xFF86EFAC);
const Color kSuccessSurface = Color(0x1A22C55E);

const Color kWarning = Color(0xFFF59E0B);
const Color kWarningLight = Color(0xFFFCD34D);
const Color kWarningSurface = Color(0x1AF59E0B);

const Color kDanger = Color(0xFFEF4444);
const Color kDangerLight = Color(0xFFFCA5A5);
const Color kDangerSurface = Color(0x1AEF4444);

const Color kInfo = Color(0xFF3B82F6);
const Color kInfoLight = Color(0xFF93C5FD);
const Color kInfoSurface = Color(0x1A3B82F6);

// ── Borders & Dividers ───────────────────────────────────────
const Color kBorderDark = Color(0x1AFFFFFF);
const Color kBorderLight = Color(0xFFE2E8F0);
const Color kDivider = Color(0x0DFFFFFF);

// ── Glass ────────────────────────────────────────────────────
const Color kGlassBg = Color(0x14FFFFFF); // 8% white
const Color kGlassBorder = Color(0x33FFFFFF); // 20% white
const Color kGlassHighlight = Color(0x0DFFFFFF); // 5% white

// ── Verification Status Colors ───────────────────────────────
const Color kVerifNone = Color(0xFF6B7280);
const Color kVerifRequested = Color(0xFFF59E0B);
const Color kVerifInProgress = Color(0xFF3B82F6);
const Color kVerifDoneLow = Color(0xFF22C55E);
const Color kVerifDoneMedium = Color(0xFFF59E0B);
const Color kVerifDoneHigh = Color(0xFFEF4444);

// ── Gradients ────────────────────────────────────────────────
const LinearGradient kGradientPrimary = LinearGradient(
  colors: [kPrimary, kPrimaryLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kGradientGold = LinearGradient(
  colors: [kGold, kGoldLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kGradientDark = LinearGradient(
  colors: [Color(0xFF0B1215), Color(0xFF162025)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const LinearGradient kGradientCTA = LinearGradient(
  colors: [kPrimary, Color(0xFF0D8F5E)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const LinearGradient kGradientGoldCTA = LinearGradient(
  colors: [kGold, Color(0xFFD4B65E)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// ── Legacy aliases (for backward compatibility) ──────────────
const Color kGreen = kPrimary;
const Color kLightBackground = kLightBg;
const Color kFontColor = kTextDark;
