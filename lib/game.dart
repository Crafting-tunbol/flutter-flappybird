import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/bird.dart';
import 'package:my_app/pipe.dart';

class Game extends StatefulWidget {
  const Game(
    this.screenWidth,
    this.screenHeight,
    {Key? key}
  ): super(key: key);

  final double screenWidth;
  final double screenHeight;

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  List<double> getNextPipe() {
    List<double> pipes = [];
    double spaceBetweenPipes = 150;

    double rn = Random().nextDouble() * ((widget.screenHeight-200) - 100) + 100;
    pipes.add(rn);
    pipes.add(widget.screenHeight-rn-spaceBetweenPipes);
    return pipes;
  }
  void start() {
    point = 0;
    _birdY = widget.screenHeight/2;
    _birdVelocity = 0;
    _birdIsDead = false;

    List<double> xPipes = [];
    for (int i = 0; i < (widget.screenWidth/400).ceil(); i++) {
      xPipes.add(widget.screenWidth/2+400*(i+2));
    }
    xPipeAlignment = xPipes;
    debugPrint((widget.screenWidth/400).toString());
    debugPrint((widget.screenWidth/400).ceil().toString());
    debugPrint(xPipeAlignment.toString());

    List<double> yPipes = [];
    for (int i = 0; i < xPipeAlignment.length; i++) {
      List<double> pipes = getNextPipe();
      yPipes.add(pipes[0]);
      yPipes.add(pipes[1]);
    }
    yPipeHeight = yPipes;

    setState(() {
      _gameStarted = true;
    });
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      for (int i = 0; i < xPipeAlignment.length*2; i++) {
        int realInt = (i.toDouble()/2).floor();

        // Move pipes
        xPipeAlignment[realInt] -= 1;

        // Check for repeat
        if (xPipeAlignment[realInt] <= -80 && i % 2 == 0) {
          xPipeAlignment[realInt] = xPipeAlignment.reduce(max)+400;
          List<double> pipes = getNextPipe();
          yPipeHeight[i] = pipes[0];
          yPipeHeight[i+1] = pipes[1];
        }

        // Point check
        if (xPipeAlignment[realInt] == widget.screenWidth/2) {
          AudioPlayer().play("assets/coin.mp3");
          point++;
        }

        // Collision check
        // Y check
        bool yCheck = false;
        if (i % 2 == 0) {
          if (_birdY-birdHeight/2 <= yPipeHeight[i]) {
            yCheck = true;
          }
        } else {
          if (_birdY+birdHeight/2 >= widget.screenHeight-yPipeHeight[i]) {
            yCheck = true;
          }
        }
        
        if (yCheck) {

          // X check
          if (xPipeAlignment[realInt] >= widget.screenWidth/2-80 && xPipeAlignment[realInt] <= widget.screenWidth/2+birdWidth/2) {
            AudioPlayer().play("assets/hit.mp3");
            _birdIsDead = true;
          }
        }
      }
      if (_birdVelocity > -4) {
        _birdVelocity -= 0.05;
      }
      setState(() {
        _birdY -= _birdVelocity;
      });
      if (_birdY+birdHeight/2 >= widget.screenHeight) {
        AudioPlayer().play("assets/hit.mp3");
        _birdIsDead = true;
      }
      if (_birdIsDead) {
        timer.cancel();
      }
    });
  }
  bool _birdIsDead = false;
  void jump() {
    if (_birdY > birdHeight*3) {
      setState(() {
        _birdVelocity = 3;
      });
    }
  }
  int point = 0;
  double _birdVelocity = 0;
  double birdHeight = 35;
  double birdWidth = 50;
  late double _birdY = widget.screenHeight/2;
  var cursorPosition = {'x': 0.0, 'y': 0.0};
  bool _gameStarted = false;
  late List<double> xPipeAlignment = [];
  List<double> yPipeHeight = [300, 200, 200, 200, 200, 200];

  void _handleKeyDown(RawKeyEvent value) {
    if (value.isKeyPressed(LogicalKeyboardKey.space) || value.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      jumpKeyPressed();
    }
  }
  void jumpKeyPressed() {
    if (!_gameStarted || _birdIsDead) start();
    jump();
  }

  @override
  Widget build(BuildContext context) {
    RawKeyboard.instance.addListener(_handleKeyDown);
    return Stack(
      children: [
        Positioned(
            top: _birdY-birdHeight/2,
            left: widget.screenWidth/2-birdWidth/2,
            child: Bird(
              birdHeight,
              birdWidth
            ),
          ),
          for (int i = 0; i < xPipeAlignment.length*2; i++)
            Pipe(
              xPipeAlignement: xPipeAlignment[(i.toDouble()/2).floor()],
              pipeHeight: yPipeHeight[i],
              isBottomPipe: (i % 2 == 0),
            ),
          if (!_gameStarted)
            const Align(
              alignment: Alignment(0, -0.4),
              child:Text(
                "TAP TO PLAY",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 50, fontFamily: "Poppins"),
              ),
            ),
          if (_birdIsDead)
            const Align(
              alignment: Alignment(0, -0.4),
              child:Text(
                "YOU LOOSE",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 50, fontFamily: "Poppins"),
              ),
            ),
          Align(
            alignment: const Alignment(1, 1),
            child: Text(
              cursorPosition.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontFamily: "Poppins"),
            )
          ),
          Align(
            alignment: const Alignment(-1, -1),
            child: Text(
              point.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 50, fontFamily: "Poppins"),
            )
          ),
          GestureDetector(
            onTap: () {
              jumpKeyPressed();
            }
          ),
          MouseRegion(
            onHover: (event) {
              setState(() {
                cursorPosition['x'] = event.position.dx.floorToDouble(); 
                cursorPosition['y'] = event.position.dy.floorToDouble(); 
              });
            },
          )
      ],
    );
  }
}