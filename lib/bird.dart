import 'package:flutter/material.dart';

class Bird extends StatefulWidget {
  final double height;
  final double width;

  const Bird(
    this.height,
    this.width,
    {Key? key}
  ) : super(key: key);

  @override
  State<Bird> createState() => _BirdState();
}

class _BirdState extends State<Bird> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          width: widget.width,
          /*decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
          )*/
        ),
        SizedBox(
          child: Image.asset("assets/bird.png"),
          height: widget.height,
          width: widget.width,
        ),
      ]
    );
  }
}