import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
            child: FadeTransition(
              opacity: AlwaysStoppedAnimation(0.5),
              child: SpinKitFadingCircle(
                color: Colors.grey,
                size: 50.0,
              ),
            ),
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
                child: GestureDetector(
                  onTap: () {
                    onCategorySelected(category);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15), // Bordes redondeados
                      border: isSelected
                          ? Border.all(color: Colors.purple.shade100, width: 0.05)
                          : Border.all(color: Colors.grey.shade300, width: 0.5),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          spreadRadius: 0.1,
                          blurRadius: 3,
                          offset: Offset(0, 0),
                        ),
                      ]
                          : [],
                    ),
                    width: 80,
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15), // Bordes redondeados para la imagen
                          child: CachedNetworkImage(
                            imageUrl: product['foto_producto'] ?? '',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: FadeTransition(
                                opacity: AlwaysStoppedAnimation(0.5),
                                child: SpinKitFadingCircle(
                                  color: Colors.grey,
                                  size: 24.0,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                            fadeInDuration: Duration(milliseconds: 500),
                            fadeOutDuration: Duration(milliseconds: 500),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
