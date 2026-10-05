import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/puzzle_data.dart';

class BoardPainter extends CustomPainter {
  final int? sr, sc;
  final List<List<int>> entries;
  BoardPainter(this.sr, this.sc, this.entries);

  int _val(int r, int c) => kGrid[r][c] != 0 ? kGrid[r][c] : entries[r][c];

  // true if v repeats in the same row, column, box or cage
  bool _conflict(int r, int c, int v) {
    for (var k = 0; k < 9; k++) {
      if (k != c && _val(r, k) == v) return true;
      if (k != r && _val(k, c) == v) return true;
    }
    final br = r ~/ 3 * 3, bc = c ~/ 3 * 3;
    for (var a = br; a < br + 3; a++) {
      for (var b = bc; b < bc + 3; b++) {
        if ((a != r || b != c) && _val(a, b) == v) return true;
      }
    }
    final cage = kCages[_cageOf[r][c]];
    for (var k = 1; k < cage.length; k += 2) {
      if ((cage[k] != r || cage[k + 1] != c) && _val(cage[k], cage[k + 1]) == v) return true;
    }
    return false;
  }

  static final List<List<int>> _cageOf = () {
    final m = List.generate(9, (_) => List.filled(9, -1));
    for (var i = 0; i < kCages.length; i++) {
      for (var k = 1; k < kCages[i].length; k += 2) {
        m[kCages[i][k]][kCages[i][k + 1]] = i;
      }
    }
    return m;
  }();

  bool _same(int r, int c, int id) => r >= 0 && r < 9 && c >= 0 && c < 9 && _cageOf[r][c] == id;

  void _dash(Canvas canvas, Offset a, Offset b, Paint p) {
    final len = (b - a).distance;
    if (len <= 0) return;
    final dir = (b - a) / len;
    double d = 0;
    while (d < len) {
      final e = math.min(d + 3, len);
      canvas.drawLine(a + dir * d, a + dir * e, p);
      d += 6;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cs = size.width / 9;

    // highlights: row, column, box, then selected cell
    if (sr != null && sc != null) {
      final peer = Paint()..color = const Color(0xFFE4ECF7);
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          final inBox = r ~/ 3 == sr! ~/ 3 && c ~/ 3 == sc! ~/ 3;
          if (r == sr || c == sc || inBox) {
            canvas.drawRect(Rect.fromLTWH(c * cs, r * cs, cs, cs), peer);
          }
        }
      }
      canvas.drawRect(Rect.fromLTWH(sc! * cs, sr! * cs, cs, cs), Paint()..color = const Color(0xFFBBD6F5));
    }

    // thin grid
    final thin = Paint()
      ..color = const Color(0xFFD3D5DB)
      ..strokeWidth = 1;
    for (var i = 1; i < 9; i++) {
      canvas.drawLine(Offset(i * cs, 0), Offset(i * cs, size.height), thin);
      canvas.drawLine(Offset(0, i * cs), Offset(size.width, i * cs), thin);
    }

    // dotted cages
    final dp = Paint()
      ..color = const Color(0xFF3A3A4A)
      ..strokeWidth = 1.1;
    final i = cs * 0.1;
    double ext(bool along, bool diag) => !along ? i : (diag ? -i : 0);
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final id = _cageOf[r][c];
        bool s(int dr, int dc) => _same(r + dr, c + dc, id);
        final x0 = c * cs, y0 = r * cs, x1 = x0 + cs, y1 = y0 + cs;
        if (!s(-1, 0)) {
          _dash(canvas, Offset(x0 + ext(s(0, -1), s(-1, -1)), y0 + i), Offset(x1 - ext(s(0, 1), s(-1, 1)), y0 + i), dp);
        }
        if (!s(1, 0)) {
          _dash(canvas, Offset(x0 + ext(s(0, -1), s(1, -1)), y1 - i), Offset(x1 - ext(s(0, 1), s(1, 1)), y1 - i), dp);
        }
        if (!s(0, -1)) {
          _dash(canvas, Offset(x0 + i, y0 + ext(s(-1, 0), s(-1, -1))), Offset(x0 + i, y1 - ext(s(1, 0), s(1, -1))), dp);
        }
        if (!s(0, 1)) {
          _dash(canvas, Offset(x1 - i, y0 + ext(s(-1, 0), s(-1, 1))), Offset(x1 - i, y1 - ext(s(1, 0), s(1, 1))), dp);
        }
      }
    }

    // thick box lines + outer border
    final thick = Paint()
      ..color = const Color(0xFF1B1D36)
      ..strokeWidth = 2.5;
    for (var k = 0; k <= 9; k += 3) {
      canvas.drawLine(Offset(k * cs, 0), Offset(k * cs, size.height), thick);
      canvas.drawLine(Offset(0, k * cs), Offset(size.width, k * cs), thick);
    }

    // cage sums
    for (final cage in kCages) {
      final r = cage[1], c = cage[2];
      _text(canvas, '${cage[0]}', Offset(c * cs + i + 1, r * cs + i - 1), cs * 0.27,
          const Color(0xFF2B2B38), FontWeight.w500, false, 0);
    }

    // digits
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final v = _val(r, c);
        if (v == 0) continue;
        final given = kGrid[r][c] != 0;
        final color = given
            ? const Color(0xFF1B1D36)
            : (_conflict(r, c, v) ? const Color(0xFFE53935) : const Color(0xFF3F55A5));
        _text(canvas, '$v', Offset(c * cs + cs / 2, r * cs + cs / 2 + cs * 0.04), cs * 0.68,
            color, FontWeight.w400, true, cs);
      }
    }
  }

  void _text(Canvas canvas, String t, Offset o, double fs, Color col, FontWeight w, bool center, double cs) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(fontSize: fs, color: col, fontWeight: w, height: 1)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center ? o - Offset(tp.width / 2, tp.height / 2) : o);
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) => true;
}
