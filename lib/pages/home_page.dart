import 'dart:async';
import 'dart:math';

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

  bool gameHasStarted = false;
  //user score
  int currentScore = 0;

  // snack position
  List<int> snackPosition = [0, 1, 2];

  // snack initially direction
  var currentDirection = SnackDirection.right;

  // food position
  int foodPosition = Random().nextInt(99);

  // game start
  void gameStart() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 400), (timer) {
      setState(() {
        // moving snack
        moveSnack();

        // game over
        if (gameOver()) {
          timer.cancel();
          // user message
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('Game Over'),
                content: SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      Text(
                        'Your Score: $currentScore',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 80,
                        width: double.infinity,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Enter Your Name',
                            focusedBorder: OutlineInputBorder(),
                            //enabledBorder: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      MaterialButton(
                        color: Colors.pink,
                        onPressed: () {
                          submitScore();
                          newGameStart();
                          Navigator.pop(context);
                        },
                        child: Text('Ok'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        // eating snack
        //eatFood();
      });
    });
  }

  // add data to firebase
  void submitScore() {}

  // new game start
  void newGameStart() {
    setState(() {
      snackPosition = [0, 1, 2];
      currentDirection = SnackDirection.right;
      //foodPosition = Random().nextInt(totalNumberOfSquares);
      gameHasStarted = false;
    });
  }

  void eatFood() {
    currentScore++;
    // new food position
    while (snackPosition.contains(foodPosition)) {
      foodPosition = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnack() {
    switch (currentDirection) {
      case SnackDirection.right:
        {
          // add head
          if (snackPosition.last % rowSize == 9) {
            snackPosition.add(snackPosition.last + 1 - rowSize);
          } else {
            snackPosition.add(snackPosition.last + 1);
          }
        }
      case SnackDirection.left:
        {
          // add head
          if (snackPosition.last % rowSize == 0) {
            snackPosition.add(snackPosition.last - 1 + rowSize);
          } else {
            snackPosition.add(snackPosition.last - 1);
          }
        }
      case SnackDirection.up:
        {
          // add head
          if (snackPosition.last < rowSize) {
            snackPosition.add(
              snackPosition.last - rowSize + totalNumberOfSquares,
            );
          } else {
            snackPosition.add(snackPosition.last - rowSize);
          }
        }
      case SnackDirection.down:
        {
          // add head
          if (snackPosition.last + rowSize >= totalNumberOfSquares) {
            snackPosition.add(
              snackPosition.last + rowSize - totalNumberOfSquares,
            );
          } else {
            snackPosition.add(snackPosition.last + rowSize);
          }
        }
    }
    if (snackPosition.last == foodPosition) {
      eatFood();
    } else {
      // remove tail
      snackPosition.removeAt(0);
    }
  }

  // game over
  bool gameOver() {
    List<int> snackBody = snackPosition.sublist(0, snackPosition.length - 1);
    if (snackBody.contains(snackPosition.last)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // high scores
          Expanded(
            child: Column(
              mainAxisAlignment: .end,
              children: [
                Text(
                  'Highest Score: $currentScore',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                Text(
                  'Score: $currentScore',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ],
            ),
          ),

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
                onPressed: gameHasStarted ? () {} : gameStart,
                color: gameHasStarted ? Colors.grey : Colors.tealAccent,
                child: Text('Play'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
