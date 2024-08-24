// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoreHeader extends StatelessWidget {
  final String bannerUrl;
  final String logoUrl;
  final String storeName;
  final String stars;
  final String sales;
  final int discount;
  final int minimumPurchase;
  final String description;

  const StoreHeader({
    super.key,
    required this.bannerUrl,
    required this.logoUrl,
    required this.storeName,
    required this.stars,
    required this.sales,
    required this.discount,
    required this.minimumPurchase,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              FutureBuilder(
                future: _precacheImage(context, bannerUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // Si la imagen ya está en caché, simplemente la mostramos sin animación.
                    return Container(
                      height: 100,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: bannerUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    );
                  } else {
                    // Si la imagen no está en caché, mostramos un placeholder mientras se carga.
                    return Container(
                      height: 100,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: bannerUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fadeInDuration: Duration(milliseconds: 500),
                        fadeOutDuration: Duration(milliseconds: 500),
                      ),
                    );
                  }
                },
              ),
              Positioned(
                bottom: -40,
                left: 20,
                child: FutureBuilder(
                  future: _precacheImage(context, logoUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // Si la imagen ya está en caché, simplemente la mostramos sin animación.
                      return CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 27,
                          backgroundImage: CachedNetworkImageProvider(logoUrl),
                          onBackgroundImageError: (_, __) => Icon(Icons.store),
                        ),
                      );
                    } else {
                      // Si la imagen no está en caché, mostramos un placeholder mientras se carga.
                      return CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.grey.shade200,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 40.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        storeName,
                        style: TextStyle(
                          letterSpacing: 1,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "⭐",
                          style: TextStyle(fontSize: 10, fontFamily: "Poppins"),
                        ),
                        SizedBox(width: 4),
                        Text(
                          stars,
                          style: TextStyle(fontSize: 10, fontFamily: "Poppins"),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "❤️",
                          style: TextStyle(fontSize: 10, fontFamily: "Poppins"),
                        ),
                        SizedBox(width: 4),
                        Text(
                          sales,
                          style: TextStyle(fontSize: 10, fontFamily: "Poppins"),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Center(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                      fontFamily: "Alef",
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Center(
                  child: AnimatedContainer(
                    duration: Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_offer_outlined, size: 18, color: Colors.purple),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'COP$discount de descuento por compras superiores a COP$minimumPurchase (Cupon de tienda)',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.black,
                                  fontFamily: "Alef",
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 18, color: Colors.purple),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Garantía de envío',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.black,
                                  fontFamily: "Alef",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Divider()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _precacheImage(BuildContext context, String imageUrl) async {
    final imageProvider = CachedNetworkImageProvider(imageUrl);
    await precacheImage(imageProvider, context);
  }
}
