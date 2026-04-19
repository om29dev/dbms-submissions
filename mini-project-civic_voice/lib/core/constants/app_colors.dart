import 'package:flutter/material.dart';

/// All color constants for the Civic Voice Interface design system.
/// "Bharat Silicon" Design Language — Dark Warm Teak Theme.
/// Philosophy: Dark warm background like Indian teak wood, saffron & gold glow from within.
abstract class AppColors {
  // ─── Core Brand — Saffron ────────────────────────────────────────────────────
  /// Saffron — Primary action / CTA
  static const Color saffron        = Color(0xFFFF6B1A);
  /// Saffron Deep — Pressed / gradient end
  static const Color saffronDeep    = Color(0xFFE8510A);
  /// Saffron Glow — Low opacity glow shadow
  static const Color saffronGlow    = Color(0x33FF6B1A);
  /// Saffron Pale — Tinted background
  static const Color saffronPale    = Color(0xFFFFF0E8);

  // ─── Gold — Premium Moments ──────────────────────────────────────────────────
  /// Gold — Rich Indian gold for premium UI
  static const Color gold           = Color(0xFFD4930A);
  /// Gold Light — Highlight / animation peak
  static const Color goldLight      = Color(0xFFF0B429);
  /// Gold Shimmer — Background shimmer wash
  static const Color goldShimmer    = Color(0xFFFFF3C4);

  // ─── India Green ─────────────────────────────────────────────────────────────
  /// Emerald — Deep India green for success / nature
  static const Color emerald        = Color(0xFF0A7A3E);
  /// Emerald Light — Active state
  static const Color emeraldLight   = Color(0xFF12A855);
  /// Emerald Pale — Green tint background
  static const Color emeraldPale    = Color(0xFFE6F7EE);

  // ─── Backgrounds — Layered Teak Depth ────────────────────────────────────────
  /// Near black, warm — page scaffold
  static const Color bgDeep         = Color(0xFF0C0A08);
  /// Dark card background
  static const Color bgDark         = Color(0xFF161210);
  /// Elevated surface
  static const Color bgMid          = Color(0xFF1E1814);
  /// Lighter surface
  static const Color bgLight        = Color(0xFF2A2118);

  // ─── Surfaces ────────────────────────────────────────────────────────────────
  /// Card surface
  static const Color surface        = Color(0xFF241C14);
  /// Subtle border
  static const Color surfaceBorder  = Color(0xFF3D2E1E);

  // ─── Text ────────────────────────────────────────────────────────────────────
  /// Warm white — headings, important labels
  static const Color textPrimary    = Color(0xFFFFF8F0);
  /// Muted warm — body copy, captions
  static const Color textSecondary  = Color(0xFFB8A898);
  /// Very muted — placeholders, hints
  static const Color textMuted      = Color(0xFF6B5A4A);
  /// Gold text — premium labels
  static const Color textGold       = Color(0xFFD4930A);

  // ─── Service Category Accents ────────────────────────────────────────────────
  /// Passport / Identity — mapped to saffron
  static const Color accentBlue     = Color(0xFFFF6B1A);
  /// Health services — mapped to gold
  static const Color accentTeal     = Color(0xFFD4930A);
  /// Education — mapped to saffron
  static const Color accentPurple   = Color(0xFFFF6B1A);
  /// Emergency / Destructive
  static const Color accentRed      = Color(0xFFC62828);
  /// Legacy accent aliases — mapped to emerald
  static const Color accentGreen    = Color(0xFF0A7A3E);
  static const Color accentOrange   = Color(0xFFE65100);
  static const Color accentAmber    = Color(0xFFF57F17);

  // ─── Gradients ───────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [saffron, saffronDeep],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, goldLight],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgDeep, Color(0xFF060402)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [saffron, gold],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [saffron, gold],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgDark, bgMid],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emerald, emeraldLight],
  );

  // ─── Semantic / Status ───────────────────────────────────────────────────────
  static const Color semanticError   = accentRed;
  static const Color semanticSuccess = emeraldLight;
  static const Color semanticWarning = gold;
  static const Color semanticInfo    = gold;
  static const Color success         = emeraldLight;
  static const Color error           = accentRed;
  static const Color warning         = gold;
  static const Color info            = gold;

  // ─── Feature-Specific Service Colors ─────────────────────────────────────────
  static const Color govtServices     = saffron;
  static const Color healthService    = gold;
  static const Color educationService = saffron;
  static const Color financeService   = gold;
  static const Color legalService     = accentOrange;

  // ─── Voice / Waveform ────────────────────────────────────────────────────────
  static const Color waveformActive   = saffron;
  static const Color waveformInactive = surfaceBorder;
  static const Color micActive        = emeraldLight;
  static const Color micIdle          = saffron;

  // ─── Glass (kept for backward compat) ────────────────────────────────────────
  static const Color glassWhite  = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassShine  = Color(0x26FFFFFF);

  // ─── Shadow Helpers ───────────────────────────────────────────────────────────
  static const Color shadowSaffron = Color(0x33FF6B1A);
  static const Color shadowGold    = Color(0x33D4930A);
  static const Color shadowDark    = Color(0x800C0A08);

  // ─── Legacy API Aliases ───────────────────────────────────────────────────────
  static const Color primary         = saffron;
  static const Color accent          = gold;
  static const Color accentGlow      = saffronGlow;
  static const Color accentDim       = surfaceBorder;
  static const Color primaryLight    = goldLight;
  static const Color border          = surfaceBorder;
  static const Color background      = bgDeep;
  static const Color backgroundLight = bgDark;
  static const Color backgroundCard  = bgMid;
  static const Color white           = Color(0xFFFFFFFF);
  static const Color secondary       = textSecondary;
  static const Color textBody        = textSecondary;
  static const Color textDisabled    = Color(0xFF4A3D30);
  static const Color textOnPrimary   = Colors.white;
}
