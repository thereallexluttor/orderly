import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String imagePath;
  final String label;

  const CategoryButton({
    super.key,
    required this.imagePath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 23,
          backgroundImage: AssetImage(imagePath),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 50, // Ajusta el ancho para forzar el texto en dos líneas
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    
  }
}
