import 'package:flutter/material.dart';

class SaleButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const SaleButton({
    Key? key,
    required this.label,
    required this.color,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 16),
      ),
    );
  }
}