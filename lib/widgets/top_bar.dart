import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onTheme;
  final VoidCallback onShare;
  final VoidCallback onSettings;
  const TopBar({
    super.key,
    required this.onBack,
    required this.onTheme,
    required this.onShare,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1B1D36);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onBack,
            child: Container(
              width: 52,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: .15), blurRadius: 3, offset: const Offset(0, 1.5))
                ],
                color: Colors.white,
              ),
              child: const Icon(Icons.arrow_back, color: Color(0xFF6E7380)),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              const Text('Score',
                  style: TextStyle(color: Color(0xFF9A9CA5), fontSize: 18, fontWeight: FontWeight.w700)),
              Text('0', style: TextStyle(color: dark, fontSize: 26, fontWeight: FontWeight.w800)),
            ],
          ),
          const Spacer(),
          _topIcon(Icons.palette_outlined, onTheme),
          _topIcon(Icons.open_in_new, onShare),
          _topIcon(Icons.settings_outlined, onSettings),
        ],
      ),
    );
  }

  Widget _topIcon(IconData i, VoidCallback onTap) => IconButton(
    onPressed: onTap,
    icon: Icon(i, size: 28, color: const Color(0xFF6E7380)),
  );
}
