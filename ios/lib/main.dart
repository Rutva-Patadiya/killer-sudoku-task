import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const KillerSudokuApp());
}

class KillerSudokuApp extends StatelessWidget {
  const KillerSudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Killer Sudoku',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F64B5),
        ),
      ),
      home: const KillerSudokuScreen(),
    );
  }
}

class KillerSudokuScreen extends StatefulWidget {
  const KillerSudokuScreen({super.key});

  @override
  State<KillerSudokuScreen> createState() => _KillerSudokuScreenState();
}

class _KillerSudokuScreenState extends State<KillerSudokuScreen> {
  // ------------------------------------------------------------
  // SELECTED CELL
  // ------------------------------------------------------------

  int selectedRow = 0;
  int selectedColumn = 0;

  // ------------------------------------------------------------
  // TIMER
  // ------------------------------------------------------------

  int seconds = 4;
  Timer? timer;

  // ------------------------------------------------------------
  // MISTAKES
  // ------------------------------------------------------------

  int mistakes = 0;

  // ------------------------------------------------------------
  // NOTES
  // ------------------------------------------------------------

  bool notesMode = false;

  // ------------------------------------------------------------
  // BOARD
  // 0 = empty
  // ------------------------------------------------------------

  final List<List<int>> board = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 4, 0, 1, 8, 0],
    [0, 0, 0, 6, 0, 0, 0, 7, 4],

    [0, 1, 0, 3, 0, 0, 4, 0, 0],
    [0, 3, 0, 0, 0, 0, 2, 1, 0],
    [8, 2, 4, 9, 0, 6, 0, 0, 3],

    [0, 0, 0, 0, 0, 0, 5, 0, 0],
    [0, 8, 0, 5, 2, 0, 6, 4, 0],
    [4, 0, 0, 1, 0, 3, 0, 0, 7],
  ];

  // ------------------------------------------------------------
  // ORIGINAL GIVEN NUMBERS
  // These numbers cannot be erased/changed.
  // ------------------------------------------------------------

  final Set<String> fixedCells = {
    '1-4',
    '1-6',
    '1-7',
    '2-3',
    '2-7',
    '2-8',
    '3-1',
    '3-6',
    '3-7',
    '4-1',
    '4-6',
    '5-1',
    '5-6',
    '5-7',
    '6-0',
    '6-1',
    '6-2',
    '6-3',
    '6-5',
    '6-8',
    '7-1',
    '7-3',
    '7-4',
    '7-6',
    '7-7',
    '8-0',
    '8-3',
    '8-5',
    '8-8',
  };

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {
          setState(() {
            seconds++;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  String get formattedTime {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool isFixed(int row, int column) {
    return fixedCells.contains('$row-$column');
  }

  bool isSelected(int row, int column) {
    return row == selectedRow && column == selectedColumn;
  }

  bool isSameRow(int row) {
    return row == selectedRow;
  }

  bool isSameColumn(int column) {
    return column == selectedColumn;
  }

  bool isSameBox(int row, int column) {
    final selectedBoxRow = selectedRow ~/ 3;
    final selectedBoxColumn = selectedColumn ~/ 3;

    return row ~/ 3 == selectedBoxRow &&
        column ~/ 3 == selectedBoxColumn;
  }

  // ------------------------------------------------------------
  // SNACKBAR
  // ------------------------------------------------------------

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: 95,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ------------------------------------------------------------
  // TOP ICON
  // ------------------------------------------------------------

  Widget topIcon({
    required IconData icon,
    required String message,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      onPressed: onPressed ?? () => showMessage(message),
      icon: Icon(
        icon,
        size: 28,
        color: const Color(0xFF858692),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM ACTION
  // ------------------------------------------------------------

  Widget bottomAction({
    required IconData icon,
    required String label,
    required String message,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed ?? () => showMessage(message),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 29,
                color: const Color(0xFF858692),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF858692),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // NUMBER BUTTON
  // ------------------------------------------------------------

  Widget numberButton(int number) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            if (!isFixed(selectedRow, selectedColumn)) {
              board[selectedRow][selectedColumn] = number;
            }
          });
        },
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3F64B5),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOARD CELL
  // ------------------------------------------------------------

  Widget buildCell(int row, int column) {
    final selected = isSelected(row, column);
    final sameRow = isSameRow(row);
    final sameColumn = isSameColumn(column);
    final sameBox = isSameBox(row, column);

    Color background = Colors.white;

    if (sameRow || sameColumn || sameBox) {
      background = const Color(0xFFEFF3FC);
    }

    if (selected) {
      background = const Color(0xFFD9E4FA);
    }

    final value = board[row][column];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRow = row;
          selectedColumn = column;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: background,

          // Thin internal grid lines.
          border: Border(
            top: BorderSide(
              color: row % 3 == 0
                  ? const Color(0xFF24263A)
                  : const Color(0xFFB9BBC4),
              width: row % 3 == 0 ? 2 : 0.7,
            ),
            left: BorderSide(
              color: column % 3 == 0
                  ? const Color(0xFF24263A)
                  : const Color(0xFFB9BBC4),
              width: column % 3 == 0 ? 2 : 0.7,
            ),
            right: BorderSide(
              color: column == 8
                  ? const Color(0xFF24263A)
                  : const Color(0xFFB9BBC4),
              width: column == 8 ? 2 : 0.7,
            ),
            bottom: BorderSide(
              color: row == 8
                  ? const Color(0xFF24263A)
                  : const Color(0xFFB9BBC4),
              width: row == 8 ? 2 : 0.7,
            ),
          ),
        ),
        child: Center(
          child: value == 0
              ? const SizedBox()
              : Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight:
              isFixed(row, column)
                  ? FontWeight.w500
                  : FontWeight.w400,
              color: isFixed(row, column)
                  ? const Color(0xFF202234)
                  : const Color(0xFF3F64B5),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SUDOKU BOARD
  // ------------------------------------------------------------

  Widget buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 81,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemBuilder: (context, index) {
          final row = index ~/ 9;
          final column = index % 9;

          return buildCell(row, column);
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 12),

        Row(
          children: [
            topIcon(
              icon: Icons.arrow_back,
              message: 'Back pressed',
            ),

            const Spacer(),

            const Text(
              'Score',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFF858692),
              ),
            ),

            const Spacer(),

            topIcon(
              icon: Icons.palette_outlined,
              message: 'Theme',
            ),

            topIcon(
              icon: Icons.open_in_new,
              message: 'Share',
            ),

            topIcon(
              icon: Icons.settings_outlined,
              message: 'Settings',
            ),
          ],
        ),

        const SizedBox(height: 2),

        const Text(
          '0',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w600,
            color: Color(0xFF202234),
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Text(
                'Easy',
                style: TextStyle(
                  fontSize: 23,
                  color: Color(0xFF858692),
                ),
              ),

              const Spacer(),

              Text(
                'Mistake: $mistakes/3',
                style: const TextStyle(
                  fontSize: 23,
                  color: Color(0xFF858692),
                ),
              ),

              const Spacer(),

              Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 23,
                  color: Color(0xFF858692),
                ),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () {
                  showMessage('Pause');
                },
                child: const Icon(
                  Icons.pause,
                  size: 26,
                  color: Color(0xFF858692),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // BOTTOM ACTIONS
  // ------------------------------------------------------------

  Widget buildBottomActions() {
    return Row(
      children: [
        bottomAction(
          icon: Icons.undo,
          label: 'Undo',
          message: 'Undo',
        ),

        bottomAction(
          icon: Icons.auto_fix_normal_outlined,
          label: 'Erase',
          message: 'Erase',
          onPressed: () {
            setState(() {
              if (!isFixed(selectedRow, selectedColumn)) {
                board[selectedRow][selectedColumn] = 0;
              }
            });

            showMessage('Cell erased');
          },
        ),

        bottomAction(
          icon: Icons.edit_outlined,
          label: 'Notes',
          message: 'Notes',
          onPressed: () {
            setState(() {
              notesMode = !notesMode;
            });

            showMessage(
              notesMode ? 'Notes ON' : 'Notes OFF',
            );
          },
        ),

        bottomAction(
          icon: Icons.lightbulb_outline,
          label: 'Hint',
          message: 'Hint',
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // NUMBER PAD
  // ------------------------------------------------------------

  Widget buildNumberPad() {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(
          9,
              (index) => numberButton(index + 1),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MAIN UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            buildHeader(),

            const SizedBox(height: 18),

            // BOARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: buildBoard(),
            ),

            const SizedBox(height: 18),

            // ACTION BUTTONS
            buildBottomActions(),

            const Spacer(),

            // NUMBER PAD
            buildNumberPad(),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}