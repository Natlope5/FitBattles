import 'package:flutter/material.dart';

class PersistentNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PersistentNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      color: const Color(0xfff8f8f8),
      child: IconTheme(
        data: const IconThemeData(color: Color(0xffabadb4)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => onTap(0),
              child: Icon(
                Icons.face,
                color: currentIndex == 0 ? Colors.blue : const Color(0xffabadb4),
              ),
            ),
            GestureDetector(
              onTap: () => onTap(1),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: currentIndex == 1
                      ? const LinearGradient(
                    begin: Alignment.topLeft,
                    colors: [
                      Color(0xff92e2ff),
                      Color(0xff1ebdf8),
                    ],
                  )
                      : null,
                ),
                child: Icon(
                  Icons.home,
                  color: currentIndex == 1 ? Colors.white : const Color(0xffabadb4),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => onTap(2),
              child: Icon(
                Icons.fitness_center,
                color: currentIndex == 2 ? Colors.blue : const Color(0xffabadb4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}