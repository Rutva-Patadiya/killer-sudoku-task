import 'package:flutter/material.dart';
import 'controllers/game_controller.dart';
import 'pages/game_screen.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: KillerSudokuPage(),
));


class KillerSudokuPage extends StatefulWidget {
  const KillerSudokuPage({super.key});
  @override
  State<KillerSudokuPage> createState() => _KillerSudokuPageState();
}

class _KillerSudokuPageState extends State<KillerSudokuPage> {
  final GameController _controller = GameController();

  void _showToast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 900),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GameScreen(
          controller: _controller,
          showToast: _showToast,
        ),
      ),
    );
  }

}
