import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snack_game/pages/blank_pixel.dart';
import 'package:flutter_snack_game/pages/food_pixel.dart';
import 'package:flutter_snack_game/pages/highest_scores_tile.dart';
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
  final _nameController = TextEditingController();

  bool gameHasStarted = false;
  //user score
  int currentScore = 0;

  // snack position
  List<int> snackPosition = [0, 1, 2];

  // snack initially direction
  var currentDirection = SnackDirection.right;

  // food position
  int foodPosition = Random().nextInt(100);

  // highest score list
  List<String> highestScore_DocIds = [];
  late final Future letGetDocIds = getDocId();

  @override
  void initState() {
    getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highestscores")
        .orderBy("score", descending: true)
        .limit(5)
        .get()
        .then(
          (onValue) => onValue.docs.forEach((action) {
            highestScore_DocIds.add(action.reference.id);
          }),
        );
  }

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
                          controller: _nameController,
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
  void submitScore() {
    var database = FirebaseFirestore.instance;
    database.collection('highestscores').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  // new game start
  Future newGameStart() async {
    highestScore_DocIds = [];
    await getDocId();
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
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) &&
              currentDirection != SnackDirection.up) {
            currentDirection = SnackDirection.down;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) &&
              currentDirection != SnackDirection.down) {
            currentDirection = SnackDirection.up;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight) &&
              currentDirection != SnackDirection.left) {
            currentDirection = SnackDirection.right;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft) &&
              currentDirection != SnackDirection.right) {
            currentDirection = SnackDirection.left;
          }
        },
        child: SizedBox(
          width: screenWidth > 426 ? 426 : screenWidth,
          child: Column(
            children: [
              // high scores
              Expanded(
                child: Column(
                  mainAxisAlignment: .end,
                  children: [
                    Expanded(
                      child: gameHasStarted
                          ? SizedBox()
                          : FutureBuilder(
                              future: letGetDocIds,
                              builder: (context, snapshot) {
                                return ListView.builder(
                                  itemBuilder: (context, index) {
                                    return HighestScoresTile(
                                      documentId: highestScore_DocIds[index],
                                    );
                                  },
                                  itemCount: highestScore_DocIds.length,
                                );
                              },
                            ),
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
        ),
      ),
    );
  }
}
