// offers_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderly/homepage/sales&deals/itemcardoffers.dart';

class OffersTab extends StatelessWidget {
  final String searchQuery;

  const OffersTab({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collectionGroup('items').where('discount', isGreaterThan: 0).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget content;

        if (snapshot.connectionState == ConnectionState.waiting) {
          content = const Center(child: SizedBox.shrink());
        } else if (snapshot.hasError) {
          print(snapshot.error);
          content = Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          content = const Center(child: Text('No items available with discounts'));
        } else {
          var items = snapshot.data!.docs;
          var filteredItems = items.where((item) {
            var itemData = item.data() as Map<String, dynamic>;
            return itemData['nombre'].toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          content = GridView.builder(
            padding: const EdgeInsets.only(left: 15.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Número de columnas
              mainAxisSpacing: 0.0,
              crossAxisSpacing: 0.0,
              childAspectRatio: 0.5, // Ajusta esta relación según sea necesario
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              var item = filteredItems[index];
              var itemData = item.data() as Map<String, dynamic>;

              return ItemCardOffers(itemData: itemData); // Pasa el usuario a ItemCardOffers
            },
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: content,
        );
      },
    );
  }
}
