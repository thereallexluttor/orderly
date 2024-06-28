// offers_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderly/homepage/sales&deals/itemcardoffers.dart';

class OffersTab extends StatelessWidget {
  const OffersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collectionGroup('items').where('discount', isGreaterThan: 0).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No items available with discounts'));
        }

        var items = snapshot.data!.docs;
        return Center(
          child: GridView.builder(
            padding: const EdgeInsets.only(left: 15.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Número de columnas
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 0.0,
              childAspectRatio: 0.67, // Ajusta esta relación según sea necesario
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              var item = items[index];
              var itemData = item.data() as Map<String, dynamic>;
          
              return ItemCardOffers(itemData: itemData);
            },
          ),
        );
      },
    );
  }
}
