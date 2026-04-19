import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

/// Drop-in replacement for [Text] that auto-translates via Google Translate.
///
/// Usage:
///   // Before:
///   Text('Quick Actions', style: ...)
///   // After:
///   TText('Quick Actions', style: ...)
///
/// How it works:
///   1. If current language is English, renders [text] directly.
///   2. If a translation is already cached, renders it instantly.
///   3. Otherwise, renders English while LanguageProvider fetches translation in the background.
///   4. Rebuilds automatically when translation completes (via LanguageProvider.notifyListeners).
///
/// The widget itself is stateless — all state lives in LanguageProvider's cache.
class TText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final double? textScaleFactor;

  const TText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final translated = lang.translateSync(text);

    return Text(
      translated,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      // ignore: deprecated_member_use
      textScaleFactor: textScaleFactor,
    );
  }
}
