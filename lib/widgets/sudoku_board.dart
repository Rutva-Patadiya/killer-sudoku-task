import 'package:flutter/material.dart';
import 'board_painter.dart';

class SudokuBoard extends StatelessWidget {
  final int? selR;
  final int? selC;
  final List<List<int>> entries;
  final Function(int, int) onCellTap;
  const SudokuBoard({
    super.key,
    required this.selR,
    required this.selC,
    required this.entries,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cs = c.maxWidth / 9;
      return GestureDetector(
        onTapDown: (d) {
          final col = (d.localPosition.dx / cs).floor().clamp(0, 8);
          final row = (d.localPosition.dy / cs).floor().clamp(0, 8);
          onCellTap(row, col);
        },
        child: CustomPaint(
          size: Size.square(c.maxWidth),
          painter: BoardPainter(selR, selC, entries),
        ),
      );
    });
  }
}
