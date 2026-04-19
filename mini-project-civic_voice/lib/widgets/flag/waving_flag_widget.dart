import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WavingFlagWidget extends StatefulWidget {
  final Widget child;
  const WavingFlagWidget({required this.child, super.key});

  @override
  State<WavingFlagWidget> createState() => _WavingFlagWidgetState();
}

class _WavingFlagWidgetState extends State<WavingFlagWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0C0A08))
      ..loadFlutterAsset('assets/flag/flag.html');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 3D flag layer (bottom)
        WebViewWidget(controller: _controller),
        
        // Gradient overlay — keeps content readable
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFF6B1A).withValues(alpha: 0.15), // Saffron tint top
                const Color(0xFF0C0A08).withValues(alpha: 0.7),   // Dark middle
                const Color(0xFF138808).withValues(alpha: 0.15), // Emerald tint bottom
              ],
            ),
          ),
        ),
        // Additional dark overlay for readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0C0A08).withValues(alpha: 0.2),
                const Color(0xFF0C0A08).withValues(alpha: 0.6),
                const Color(0xFF0C0A08).withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
        
        // Dashboard content (top)
        widget.child,
      ],
    );
  }
}
