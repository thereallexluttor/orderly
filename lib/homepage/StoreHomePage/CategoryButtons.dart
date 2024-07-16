import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          return const Center(
            
          );
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        onCategorySelected(category);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.purple, width: 3)
                              : Border.all(color: Colors.grey.shade300, width: 1),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                              : [],
                          color: isSelected ? Colors.purple.withOpacity(0.2) : Colors.transparent,
                        ),
                        child: AnimatedScale(
                          scale: isSelected ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: product['foto_producto'] ?? '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => FadeInImage.assetNetwork(
                                  placeholder: 'assets/placeholder.png', // Asegúrate de tener una imagen placeholder en tus assets
                                  image: '',
                                  fit: BoxFit.cover,
                                  fadeInDuration: Duration(milliseconds: 500),
                                  fadeOutDuration: Duration(milliseconds: 500),
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                fadeInDuration: Duration(milliseconds: 500),
                                fadeOutDuration: Duration(milliseconds: 500),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      category,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                      ),
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
