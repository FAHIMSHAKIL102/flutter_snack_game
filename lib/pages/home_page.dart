import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_snack_game/pages/blank_pixel.dart';
import 'package:flutter_snack_game/pages/food_pixel.dart';
import 'package:flutter_snack_game/pages/snack_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SnackDirection { up, down, left, right }

class _HomePageState extends State<HomePage> {
  //grid dimeensions
  int rowSize = 10;
  int totalNumberOfSquares = 100;

  // snack position
  List<int> snackPosition = [0, 1];

  // snack initially direction
  var currentDirection = SnackDirection.right;

  // food position
  int foodPosition = 56;

  // game start
  void gameStart() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        moveSnack();
      });
    });
  }

  void moveSnack() {
    switch (currentDirection) {
      case SnackDirection.right:
        {
          // add head
          snackPosition.add(snackPosition.last + 1);
          // remove tail
          snackPosition.removeAt(0);
        }
      case SnackDirection.left:
        {
          // add head
          snackPosition.add(snackPosition.last - 1);
          // remove tail
          snackPosition.removeAt(0);
        }
      case SnackDirection.up:
        {
          // add head
          snackPosition.add(snackPosition.last - rowSize);
          // remove tail
          snackPosition.removeAt(0);
        }
      case SnackDirection.down:
        {
          // add head
          snackPosition.add(snackPosition.last + rowSize);
          // remove tail
          snackPosition.removeAt(0);
        }
    }
  }

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
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy > 0 &&
                    currentDirection != SnackDirection.up) {
                  currentDirection = SnackDirection.down;
                } else if (details.delta.dy < 0 &&
                    currentDirection != SnackDirection.down) {
                  currentDirection = SnackDirection.up;
                }
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 &&
                    currentDirection != SnackDirection.left) {
                  currentDirection = SnackDirection.right;
                } else if (details.delta.dx < 0 &&
                    currentDirection != SnackDirection.right) {
                  currentDirection = SnackDirection.left;
                }
              },
              child: GridView.builder(
                itemCount: totalNumberOfSquares,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowSize,
                ),
                itemBuilder: (context, index) {
                  if (snackPosition.contains(index)) {
                    return SnackPixel();
                  } else if (foodPosition == index) {
                    return FoodPixel();
                  } else {
                    return BlankPixel();
                  }
                },
              ),
            ),
          ),

          // play button
          Expanded(
            child: Center(
              child: MaterialButton(
                onPressed: gameStart,
                color: Colors.tealAccent,
                child: Text('Play'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
