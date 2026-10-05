import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberPressed;
  const NumberPad({super.key, required this.onNumberPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: List.generate(9, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Material(
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.black38,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onNumberPressed(i + 1),
                  child: SizedBox(
                    height: 56,
                    child: Center(
                      child: Text('${i + 1}',
                          style: const TextStyle(fontSize: 34, color: Color(0xFF3F55A5), fontWeight: FontWeight.w400)),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
