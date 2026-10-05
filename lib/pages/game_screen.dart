import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../widgets/top_bar.dart';
import '../widgets/actions_bar.dart';
import '../widgets/number_pad.dart';
import '../widgets/sudoku_board.dart';

class GameScreen extends StatefulWidget {
  final GameController controller;
  final Function(String) showToast;
  const GameScreen({
    super.key,
    required this.controller,
    required this.showToast,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  void _handleAction(String action) => widget.showToast('$action clicked');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TopBar(
          onBack: () => _handleAction('Back'),
          onTheme: () => _handleAction('Theme'),
          onShare: () => _handleAction('Share'),
          onSettings: () => _handleAction('Settings'),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AspectRatio(
            aspectRatio: 1,
            child: SudokuBoard(
              selR: widget.controller.selR,
              selC: widget.controller.selC,
              entries: widget.controller.entries,
              onCellTap: (row, col) {
                setState(() => widget.controller.selectCell(row, col));
              },
            ),
          ),
        ),
        const Spacer(),
        ActionsBar(
          onUndo: () => _handleAction('Undo'),
          onErase: () => _handleAction('Erase'),
          onNotes: () => _handleAction('Notes'),
          onHint: () => _handleAction('Hint'),
        ),
        const SizedBox(height: 14),
        NumberPad(onNumberPressed: (n) {
          setState(() => widget.controller.placeNumber(n, widget.showToast));
        }),
        const SizedBox(height: 28),
      ],
    );
  }
}
