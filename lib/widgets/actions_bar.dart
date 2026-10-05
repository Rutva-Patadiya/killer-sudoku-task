import 'package:flutter/material.dart';

class ActionsBar extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onErase;
  final VoidCallback onNotes;
  final VoidCallback onHint;
  const ActionsBar({
    super.key,
    required this.onUndo,
    required this.onErase,
    required this.onNotes,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    const gray = Color(0xFF7A7D8A);
    Widget item(IconData icon, String label, VoidCallback onTap, {Widget? badge}) => Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 34,
              width: 60,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 30, color: gray),
                  if (badge != null) Positioned(top: -2, right: 4, child: badge),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: gray, fontSize: 16)),
          ],
        ),
      ),
    );

    return Row(
      children: [
        item(Icons.undo, 'Undo', onUndo),
        item(Icons.auto_fix_normal, 'Erase', onErase),
        item(Icons.edit, 'Notes', onNotes,
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFDADADD), borderRadius: BorderRadius.circular(10)),
              child: const Text('OFF', style: TextStyle(fontSize: 10, color: Color(0xFF6E7380), fontWeight: FontWeight.w600)),
            )),
        item(Icons.lightbulb, 'Hint', onHint,
            badge: Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFF2F80ED), shape: BoxShape.circle),
              child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            )),
      ],
    );
  }
}
