
class Pos {
  final int r, c;
  const Pos(this.r, this.c);
}

class Cage {
  final int sum;
  final List<Pos> cells;
  const Cage(this.sum, this.cells);

  /// Cell where the small sum number is drawn (top-left-most cell).
  Pos get labelCell {
    final sorted = [...cells]..sort((a, b) => a.r != b.r ? a.r.compareTo(b.r) : a.c.compareTo(b.c));
    return sorted.first;
  }
}

class Puzzle {
  final List<Cage> cages;
  final List<List<int>> givens; // 0 = empty
  late final List<List<int>> cageOf; // cage index per cell, -1 = no cage
  late final List<List<int>> solution;

  Puzzle(this.cages, this.givens) {
    cageOf = List.generate(9, (_) => List.filled(9, -1));
    for (var i = 0; i < cages.length; i++) {
      for (final p in cages[i].cells) {
        cageOf[p.r][p.c] = i;
      }
    }
    solution = KillerSolver(this).solve() ?? givens;
  }

  /// Build givens from 9 strings, '.' = empty.
  static List<List<int>> parseGivens(List<String> rows) =>
      rows.map((s) => s.split('').map((ch) => ch == '.' ? 0 : int.parse(ch)).toList()).toList();
}

// ───────────────────────── SOLVER ─────────────────────────

class KillerSolver {
  final Puzzle p;
  late List<List<int>> g;
  KillerSolver(this.p);

  List<List<int>>? solve() {
    g = p.givens.map((r) => List<int>.from(r)).toList();
    return _go() ? g : null;
  }

  bool _ok(int r, int c, int v) {
    for (var i = 0; i < 9; i++) {
      if (g[r][i] == v || g[i][c] == v) return false;
    }
    final br = r ~/ 3 * 3, bc = c ~/ 3 * 3;
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        if (g[br + i][bc + j] == v) return false;
      }
    }
    final id = p.cageOf[r][c];
    if (id < 0) return true;
    final cage = p.cages[id];
    var sum = v, empty = 0;
    for (final q in cage.cells) {
      if (q.r == r && q.c == c) continue;
      final x = g[q.r][q.c];
      if (x == v) return false; // no repeat inside a cage
      if (x == 0) {
        empty++;
      } else {
        sum += x;
      }
    }
    return empty == 0 ? sum == cage.sum : sum < cage.sum;
  }

  bool _go() {
    var br = -1, bc = -1;
    List<int> best = [];
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (g[r][c] != 0) continue;
        final cands = [for (var v = 1; v <= 9; v++) if (_ok(r, c, v)) v];
        if (cands.isEmpty) return false;
        if (br == -1 || cands.length < best.length) {
          br = r;
          bc = c;
          best = cands;
        }
      }
    }
    if (br == -1) return true; // grid full
    for (final v in best) {
      g[br][bc] = v;
      if (_go()) return true;
    }
    g[br][bc] = 0;
    return false;
  }
}

// ───────────────────────── SCREEN ─────────────────────────

class _Move {
  final int r, c, oldValue;
  final Set<int> oldNotes;
  _Move(this.r, this.c, this.oldValue, this.oldNotes);
}

class KillerSudokuScreen extends StatefulWidget {
  const KillerSudokuScreen({super.key});
  @override
  State<KillerSudokuScreen> createState() => _KillerSudokuScreenState();
}

class _KillerSudokuScreenState extends State<KillerSudokuScreen> {
  // Demo puzzle: givens copied from your screenshot + 3 sample cages.
  // For the full game, define ALL cages (every cell in a cage).
  late final Puzzle puzzle = Puzzle(
    const [
      Cage(10, [Pos(0, 0), Pos(0, 1), Pos(0, 2)]),
      Cage(17, [Pos(1, 0), Pos(2, 0), Pos(2, 1)]),
      Cage(10, [Pos(1, 1), Pos(1, 2)]),
    ],
    Puzzle.parseGivens([
      '..5......',
      '67..4.18.',
      '...6...74',
      '.1.3..4..',
      '.3....21.',
      '8249.6..3',
      '......5..',
      '.8.52.64.',
      '4..1.3..7',
    ]),
  );

  late List<List<int>> values;
  late List<List<Set<int>>> notes;
  final List<_Move> undoStack = [];

  int? sr, sc; // selected cell
  bool notesMode = false;
  bool gameOver = false;
  int mistakes = 0, hints = 1, score = 0, seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _newGame() {
    values = puzzle.givens.map((r) => List<int>.from(r)).toList();
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    // undoStack.clear();
    sr = sc = null;
    notesMode = false;
    gameOver = false;
    mistakes = 0;
    hints = 1;
    score = 0;
    seconds = 0;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!gameOver && mounted) setState(() => seconds++);
    });
    setState(() {});
  }

  bool _isGiven(int r, int c) => puzzle.givens[r][c] != 0;
  bool _isLocked(int r, int c) => _isGiven(r, c) || values[r][c] == puzzle.solution[r][c];

  // void _push(int r, int c) => undoStack.add(_Move(r, c, values[r][c], {...notes[r][c]}));

  void _onNumber(int n) {
    final r = sr, c = sc;
    if (r == null || c == null || gameOver || _isLocked(r, c)) return;
    setState(() {
      _push(r, c);
      if (notesMode) {
        values[r][c] = 0;
        if (!notes[r][c].add(n)) notes[r][c].remove(n);
        return;
      }
      values[r][c] = n;
      notes[r][c].clear();
      if (n != puzzle.solution[r][c]) {
        mistakes++;
        if (mistakes >= 3) _end(false);
      } else {
        score += 10;
        _clearPeerNotes(r, c, n);
        if (_solved()) _end(true);
      }
    });
  }

  void _clearPeerNotes(int r, int c, int n) {
    for (var i = 0; i < 9; i++) {
      notes[r][i].remove(n);
      notes[i][c].remove(n);
    }
    final br = r ~/ 3 * 3, bc = c ~/ 3 * 3;
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        notes[br + i][bc + j].remove(n);
      }
    }
  }

  void _erase() {
    final r = sr, c = sc;
    if (r == null || c == null || gameOver || _isLocked(r, c)) return;
    setState(() {
      _push(r, c);
      values[r][c] = 0;
      notes[r][c].clear();
    });
  }

  void _undo() {

    SnackBar("undo called");
    // if (undoStack.isEmpty || gameOver) return;
    // setState(() {
    //   final m = undoStack.removeLast();
    //   values[m.r][m.c] = m.oldValue;
    //   notes[m.r][m.c] = m.oldNotes;
    });
  }

  void _hint() {
    final r = sr, c = sc;
    if (r == null || c == null || gameOver || hints <= 0 || _isLocked(r, c)) return;
    setState(() {
      _push(r, c);
      values[r][c] = puzzle.solution[r][c];
      notes[r][c].clear();
      _clearPeerNotes(r, c, values[r][c]);
      hints--;
      if (_solved()) _end(true);
    });
  }

  bool _solved() {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (values[r][c] != puzzle.solution[r][c]) return false;
      }
    }
    return true;
  }

  void _end(bool won) {
    gameOver = true;
    timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(won ? 'You won!' : 'Game over'),
          content: Text('Time ${_fmt(seconds)}  •  Score $score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _newGame();
              },
              child: const Text('Play again'),
            ),
          ],
        ),
      );
    });
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  // ───────────── UI ─────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text('Score', style: TextStyle(color: Colors.grey, fontSize: 18)),
              Text('$score', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Easy', style: TextStyle(color: Colors.grey)),
                  Text('Mistake: $mistakes/3', style: const TextStyle(color: Colors.grey)),
                  Text(_fmt(seconds), style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 6),
              AspectRatio(aspectRatio: 1, child: _board()),
              const SizedBox(height: 16),
              _actions(),
              const Spacer(),
              _numberPad(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _board() {
    return Stack(
      children: [
        GridView.count(
          crossAxisCount: 9,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [for (var r = 0; r < 9; r++) for (var c = 0; c < 9; c++) _cell(r, c)],
        ),
        // Lines on top, never steals taps
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: BoardPainter(puzzle))),
        ),
      ],
    );
  }

  Widget _cell(int r, int c) {
    final s = sr, t = sc;
    final v = values[r][c];
    final selected = s == r && t == c;
    final related = s != null &&
        t != null &&
        (s == r || t == c || (s ~/ 3 == r ~/ 3 && t ~/ 3 == c ~/ 3));
    final sameNumber = s != null && t != null && v != 0 && values[s][t] == v;

    Color bg = Colors.white;
    if (related) bg = Colors.blue.shade50;
    if (sameNumber) bg = Colors.blue.shade100;
    if (selected) bg = Colors.blue.shade200;

    final wrong = v != 0 && v != puzzle.solution[r][c];
    final textColor = wrong
        ? Colors.red
        : _isGiven(r, c)
        ? Colors.black87
        : Colors.blue.shade800;

    final id = puzzle.cageOf[r][c];
    final isLabel = id >= 0 &&
        puzzle.cages[id].labelCell.r == r &&
        puzzle.cages[id].labelCell.c == c;

    return GestureDetector(
      onTap: () => setState(() {
        sr = r;
        sc = c;
      }),
      child: Container(
        color: bg,
        child: Stack(
          children: [
            if (v != 0)
              Center(child: Text('$v', style: TextStyle(fontSize: 28, color: textColor)))
            else if (notes[r][c].isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 2, 2),
                child: Column(children: [
                  for (var i = 0; i < 3; i++)
                    Expanded(
                      child: Row(children: [
                        for (var j = 0; j < 3; j++)
                          Expanded(
                            child: Center(
                              child: Text(
                                notes[r][c].contains(i * 3 + j + 1) ? '${i * 3 + j + 1}' : '',
                                style: const TextStyle(fontSize: 8, color: Colors.grey),
                              ),
                            ),
                          ),
                      ]),
                    ),
                ]),
              ),
            if (isLabel)
              Positioned(
                left: 4,
                top: 2,
                child: Text('${puzzle.cages[id].sum}',
                    style: const TextStyle(fontSize: 10, color: Colors.black87)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actions() {
    Widget btn(IconData i, String label, VoidCallback f, {String? badge}) => InkWell(
      onTap: f,
      child: Column(children: [
        Stack(clipBehavior: Clip.none, children: [
          Icon(i, size: 28, color: Colors.grey.shade600),
          if (badge != null)
            Positioned(
              right: -10,
              top: -8,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: Colors.blue,
                child: Text(badge, style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ),
        ]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ]),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        btn(Icons.undo, 'Undo', _undo),
        btn(Icons.auto_fix_normal, 'Erase', _erase),
        btn(Icons.edit, notesMode ? 'Notes ON' : 'Notes OFF', () => setState(() => notesMode = !notesMode)),
        btn(Icons.lightbulb, 'Hint', _hint, badge: '$hints'),
      ],
    );
  }

  Widget _numberPad() {
    return Row(
      children: [
        for (var n = 1; n <= 9; n++)
          Expanded(
            child: TextButton(
              onPressed: () => _onNumber(n),
              child: Text('$n', style: TextStyle(fontSize: 32, color: Colors.indigo.shade600)),
            ),
          ),
      ],
    );
  }
}

// ───────────────────────── PAINTER ─────────────────────────

class BoardPainter extends CustomPainter {
  final Puzzle puzzle;
  BoardPainter(this.puzzle);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 9;

    final thin = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    final thick = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5;
    final dashPaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;

    // 1. Grid lines (thick every 3rd)
    for (var i = 0; i <= 9; i++) {
      final p = (i % 3 == 0) ? thick : thin;
      canvas.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), p);
      canvas.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), p);
    }

    // 2. Dashed cage borders
    const inset = 3.0;
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final id = puzzle.cageOf[r][c];
        if (id < 0) continue;
        bool diff(int rr, int cc) =>
            rr < 0 || rr > 8 || cc < 0 || cc > 8 || puzzle.cageOf[rr][cc] != id;

        final x = c * cell, y = r * cell;
        final l = diff(r, c - 1), rt = diff(r, c + 1), tp = diff(r - 1, c), bt = diff(r + 1, c);

        final xs = x + (l ? inset : 0), xe = x + cell - (rt ? inset : 0);
        final ys = y + (tp ? inset : 0), ye = y + cell - (bt ? inset : 0);

        if (tp) _dashed(canvas, Offset(xs, y + inset), Offset(xe, y + inset), dashPaint);
        if (bt) _dashed(canvas, Offset(xs, y + cell - inset), Offset(xe, y + cell - inset), dashPaint);
        if (l) _dashed(canvas, Offset(x + inset, ys), Offset(x + inset, ye), dashPaint);
        if (rt) _dashed(canvas, Offset(x + cell - inset, ys), Offset(x + cell - inset, ye), dashPaint);
      }
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint p) {
    const dash = 3.0, gap = 3.0;
    final total = (b - a).distance;
    if (total <= 0) return;
    final dir = (b - a) / total;
    double d = 0;
    while (d < total) {
      final e = math.min(d + dash, total);
      canvas.drawLine(a + dir * d, a + dir * e, p);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) => false;
}