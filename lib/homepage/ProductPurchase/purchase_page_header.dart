import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PurchasePageHeader extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const PurchasePageHeader({super.key, required this.itemData});

  @override
  Widget build(BuildContext context) {
    int sales = itemData['ventas'] ?? 0;

    return SliverAppBar(
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      expandedHeight: 300.0,
      pinned: true,
      leading: Container(
        width: 16, // Ajusta el ancho según sea necesario
        height: 16, // Ajusta la altura según sea necesario
        margin: const EdgeInsets.only(left: 25),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(178, 0, 0, 0),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18), // Ajusta el tamaño del icono
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: itemData['foto_producto'] != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: itemData['foto_producto'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    fadeInDuration: const Duration(milliseconds: 500),
                    fadeOutDuration: const Duration(milliseconds: 500),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(237, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '❤️',
                            style: TextStyle(fontSize: 12, fontFamily: "Poppins"),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${sales.toString()} ',
                            style: const TextStyle(fontSize: 12, fontFamily: "Poppins"),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            '⭐',
                            style: TextStyle(fontSize: 12, fontFamily: "Poppins"),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            itemData['valoracion'] != null
                                ? itemData['valoracion'].toStringAsFixed(1)
                                : 'N/A',
                            style: const TextStyle(fontSize: 12, fontFamily: "Poppins"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Container(color: Colors.white),
      ),
    );
  }
}
