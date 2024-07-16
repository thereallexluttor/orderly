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
          return Center(
            child: FadeTransition(
              opacity: _fadeInAnimation(context),
              child: CircularProgressIndicator(),
            ),
          );
        }

        var items = snapshot.data!.docs;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: GridView.builder(
            key: ValueKey<String?>(selectedCategory),
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 0.0,
              childAspectRatio: 0.60,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              var itemData = items[index].data() as Map<String, dynamic>;
              return StoreItemCard(itemData: itemData);
            },
          ),
        );
      },
    );
  }

  Animation<double> _fadeInAnimation(BuildContext context) {
    final AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: Scaffold.of(context),
    );
    final Animation<double> animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    controller.forward();
    return animation;
  }
}
