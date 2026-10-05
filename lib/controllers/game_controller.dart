import '../constants/puzzle_data.dart';

class GameController {
  int? selR, selC;
  final List<List<int>> entries = List.generate(9, (_) => List.filled(9, 0));

  void placeNumber(int n, Function(String) showToast) {
    if (selR == null || selC == null) {
      showToast('Select a cell first');
      return;
    }
    if (kGrid[selR!][selC!] != 0) {
      showToast('This cell is already filled');
      return;
    }
    entries[selR!][selC!] = n;
  }

  void selectCell(int row, int col) {
    selR = row;
    selC = col;
  }
}
