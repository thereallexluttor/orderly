// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class StoreHeader extends StatelessWidget {
  final String bannerUrl;
  final String logoUrl;
  final String storeName;
  final String stars;
  final String sales;
  final int discount;
  final int minimumPurchase;

  const StoreHeader({
    super.key,
    required this.bannerUrl,
    required this.logoUrl,
    required this.storeName,
    required this.stars,
    required this.sales,
    required this.discount,
    required this.minimumPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                child: Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(bannerUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 20,
              child: CircleAvatar(
                radius: 33,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(logoUrl),
                  onBackgroundImageError: (_, __) => Icon(Icons.store),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 30.0),
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
                        fontSize: 15,
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
                        style: TextStyle(fontSize: 12, fontFamily: "Poppins"),
                      ),
                      SizedBox(width: 4),
                      Text(
                        stars,
                        style: TextStyle(fontSize: 12, fontFamily: "Poppins"),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "❤️",
                        style: TextStyle(fontSize: 12, fontFamily: "Poppins"),
                      ),
                      SizedBox(width: 4),
                      Text(
                        sales,
                        style: TextStyle(fontSize: 12, fontFamily: "Poppins"),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15.0),
              Center(
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_offer_outlined, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'COP$discount de descuento por compras superiores a COP$minimumPurchase (Cupon de tienda)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontFamily: "Alef",
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Garantía de envío',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
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
            ],
          ),
        ),
      ],
    );
  }
}
