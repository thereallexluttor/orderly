import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orderly/homepage/StoreHomePage/StoreItemCard.dart';


class CategoryItems extends StatelessWidget {
  final DocumentReference storeReference;
  final String? selectedCategory;

  const CategoryItems({
    required this.storeReference,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: storeReference
          .collection('items')
          .where('category', isEqualTo: selectedCategory)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var items = snapshot.data!.docs;

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.70,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            var itemData = items[index].data() as Map<String, dynamic>;
            return StoreItemCard(itemData: itemData);
          },
        );
      },
    );
  }
}