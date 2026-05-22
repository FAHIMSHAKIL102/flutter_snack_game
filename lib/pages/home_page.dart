import 'package:flutter/material.dart';
import 'package:flutter_snack_game/pages/blank_pixel.dart';
import 'package:flutter_snack_game/pages/snack_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //grid dimeensions
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  // snack position

  List<int> snackPosition = [0, 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // high scores
          Expanded(child: Container()),

          // game grid
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: totalNumberOfSquares,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowSize,
              ),
              itemBuilder: (context, index) {
                if (snackPosition.contains(index)) {
                  return SnackPixel();
                } else {
                  return BlankPixel();
                }
              },
            ),
          ),

          // play button
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
