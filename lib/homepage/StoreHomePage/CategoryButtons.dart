import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryButtons extends StatelessWidget {
  final DocumentReference storeReference;
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryButtons({
    required this.storeReference,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: storeReference.collection('items').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var items = snapshot.data!.docs;

        Map<String, dynamic> topProducts = {};

        for (var item in items) {
          var data = item.data() as Map<String, dynamic>;
          var category = data['category'];
          if (category != null) {
            if (!topProducts.containsKey(category) || (data['ventas'] ?? 0) > (topProducts[category]['ventas'] ?? 0)) {
              topProducts[category] = data;
            }
          }
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: topProducts.keys.map((category) {
              var product = topProducts[category];
              bool isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        onCategorySelected(category);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Color.fromARGB(57, 155, 39, 176), width: 3) : null,
                          color: isSelected ? Colors.purple.withOpacity(0.2) : Colors.transparent,
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(product['foto_producto'] ?? ''),
                          onBackgroundImageError: (error, stackTrace) {
                            // Manejar el error de carga de la imagen
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      category,
                      textAlign: TextAlign.center,
                      //maxLines: 1,
                      //overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8, fontFamily: "Poppins"),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
