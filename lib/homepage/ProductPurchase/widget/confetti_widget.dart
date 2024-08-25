import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class CustomConfettiWidget extends StatelessWidget {
  final ConfettiController controller;

  const CustomConfettiWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: controller,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      emissionFrequency: 0.05,
      numberOfParticles: 30,
      maxBlastForce: 100,
      minBlastForce: 80,
      gravity: 0.3,
    );
  }
}
