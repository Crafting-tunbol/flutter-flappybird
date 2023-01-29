import 'package:flutter/material.dart';

class Pipe extends StatelessWidget {

  const Pipe({
    Key? key,
    required this.xPipeAlignement,
    required this.isBottomPipe,
    required this.pipeHeight
    }
  ) : super(key: key);

  final pipeWidth = 80.0;
  final double pipeHeight;
  final double xPipeAlignement;
  final bool isBottomPipe;

  @override
  Widget build(BuildContext context) {
    //Alignment(xPipeAlignement, isBottomPipe ? 1 : -1);
    return Positioned(
      top: isBottomPipe ? 0 : MediaQuery.of(context).size.height-pipeHeight,
      left: xPipeAlignement,
      child: Container(
        height: pipeHeight,
        width: pipeWidth,
        //color: Colors.green,
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border.all(color: const Color.fromARGB(255, 55, 128, 58), width: 5)
        ),
      )
    );
  }
}