// ignore_for_file: prefer_const_constructors, use_super_parameters

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PurchasePageHeader extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const PurchasePageHeader({Key? key, required this.itemData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int sales = itemData['ventas'] ?? 0;
    double rating = itemData['valoracion'] ?? 0.0;

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 270.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Product Image
            Hero(
              tag: 'product-${itemData['id']}',
              child: CachedNetworkImage(
                imageUrl: itemData['foto_producto'] ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fadeInDuration: const Duration(milliseconds: 500),
                fadeOutDuration: const Duration(milliseconds: 500),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            // Stats Container
            Positioned(
  bottom: 16,
  left: 16,
  right: 16,
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Color.fromARGB(255, 156, 156, 156), // Borde negro
        width: 1.0, // Ancho del borde
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('❤️', sales.toString(), 'Ventas'),
        _buildStatItem('⭐', rating.toStringAsFixed(1), 'Valoración'),
      ],
    ),
  ),
),

          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 1),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                color: Colors.black
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",


              ),
            ),
          ],
        ),
      ],
    );
  }
}