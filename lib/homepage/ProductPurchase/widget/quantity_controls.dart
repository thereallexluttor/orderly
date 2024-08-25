import 'package:flutter/material.dart';

class QuantityControls extends StatelessWidget {
  final int quantity;
  final VoidCallback increment;
  final VoidCallback decrement;
  final Animation<double> animation;

  const QuantityControls({
    Key? key,
    required this.quantity,
    required this.increment,
    required this.decrement,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove, color: Colors.purple),
          onPressed: decrement,
          tooltip: 'Disminuir cantidad',
          iconSize: 20,
        ),
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: animation.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  '$quantity',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.add, color: Colors.purple),
          onPressed: increment,
          iconSize: 20,
          tooltip: 'Aumentar cantidad',
        ),
      ],
    );
  }
}
