import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic-Tac-Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TicTacToeGame(),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame>
    with TickerProviderStateMixin {
  late List<List<String>> board;
  late String currentPlayer;
  late bool gameOver;
  late AnimationController controller;
  late Animation<double> opacity;

  @override
  void initState() {
    super.initState();
    initializeBoard();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    opacity = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
  }

  void initializeBoard() {
    board = List.generate(3, (_) => List.generate(3, (_) => ""));
    currentPlayer = "X";
    gameOver = false;
  }

  void play(int row, int col) {
    if (!gameOver && board[row][col] == "") {
      setState(() {
        board[row][col] = currentPlayer;
        checkForWinner();
        currentPlayer = (currentPlayer == "X") ? "O" : "X";
      });
    }
  }

  void checkForWinner() {
    // Check rows, columns, and diagonals for a winner
    for (int i = 0; i < 3; i++) {
      if (board[i][0] != "" &&
          board[i][0] == board[i][1] &&
          board[i][1] == board[i][2]) {
        endGame();
        return;
      }
      if (board[0][i] != "" &&
          board[0][i] == board[1][i] &&
          board[1][i] == board[2][i]) {
        endGame();
        return;
      }
    }

    if (board[0][0] != "" &&
        board[0][0] == board[1][1] &&
        board[1][1] == board[2][2]) {
      endGame();
      return;
    }

    if (board[0][2] != "" &&
        board[0][2] == board[1][1] &&
        board[1][1] == board[2][0]) {
      endGame();
      return;
    }

    // Check for a tie
    if (!board.any((row) => row.any((cell) => cell == ""))) {
      endGame(draw: true);
    }
  }

  void resetGame() {
    setState(() {
      initializeBoard();
      controller.reverse();
      gameOver = false;
    });
  }

  void showResult(String result, Color color) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(result),
          backgroundColor: color,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                resetGame();
              },
              child: const Text('New Game'),
            ),
          ],
        );
      },
    );
  }

  void endGame({bool draw = false}) {
    setState(() {
      gameOver = true;
      if (draw) {
        showResult("It's a Draw!", Colors.yellow);
      } else {
        showResult("Player $currentPlayer Wins!", Colors.greenAccent);
      }
    });
    Timer(const Duration(milliseconds: 500), () {
      controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: opacity,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.withOpacity(opacity.value),
                      Colors.purple.withOpacity(opacity.value)
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Current Player ',
                          style: const TextStyle(fontSize: 20),
                          children: <TextSpan>[
                            TextSpan(
                              text: currentPlayer,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: currentPlayer == 'X'
                                      ? Colors.amber
                                      : Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        style: TextStyle(
                            fontSize: 20,
                            color: currentPlayer == 'X'
                                ? Colors.amber
                                : Colors.blue),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (row) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (col) {
                              return GestureDetector(
                                onTap: () => play(row, col),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Center(
                                    child: Text(
                                      board[row][col],
                                      style: TextStyle(
                                          color:
                                              board[row][col].toString() == 'X'
                                                  ? Colors.amber
                                                  : Colors.blue,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      if (gameOver)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResultScreen(
                                        winner: currentPlayer,
                                      )),
                            ).then((value) {
                              resetGame();
                            });
                          },
                          child: const Text('Show Result'),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Positioned(
            left: 10,
            child: Text(
              'Tic-Tac-Toe: Beat Boredom, Make Your Move!',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: Text.rich(
              const TextSpan(
                // text: 'Current Player ',
                style: TextStyle(fontSize: 20),
                children: <TextSpan>[
                  TextSpan(
                    text: 'by..',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '..♥\n',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  TextSpan(
                    text: '...Uday',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              style: TextStyle(
                  fontSize: 20,
                  color: currentPlayer == 'X' ? Colors.amber : Colors.blue),
            ),
          ),
          if (gameOver)
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ResultScreen(
                      winner: null,
                    )),
          ).then((value) {
            resetGame();
          });
        },
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final String? winner;

  const ResultScreen({super.key, required this.winner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (winner != null)
                Text(
                  '$winner Wins!',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              if (winner == null)
                const Text(
                  'It\'s a Draw!',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the result screen
                },
                child: const Text('Back to Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
