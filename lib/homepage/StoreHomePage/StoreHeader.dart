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
      color: Colors.white, // Fondo blanco para todo el StoreHeader
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.2),
                  //     spreadRadius: 2,
                  //     blurRadius: 7,
                  //     offset: Offset(0, 3),
                  //   ),
                  // ],
                  // borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(20.0),
                  //   bottomRight: Radius.circular(20.0),
                  // ),
                ),
                child: ClipRRect(
                  // borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(20.0),
                  //   bottomRight: Radius.circular(20.0),
                  // ),
                  child: Container(
                    height: 140,
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
                bottom: -40,
                left: 20,
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(logoUrl),
                    onBackgroundImageError: (_, __) => Icon(Icons.store),
                  ),
                ),
              ),
              Positioned(
                top: 45,
                left: 20,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(134, 0, 0, 0),
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
                      color: Colors.white,
                    ),
                  ),
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
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontFamily: "Insanibc",
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
                      fontSize: 9,
                      color: Colors.black87,
                      fontFamily: "Alef",
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
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
                            Icon(Icons.local_offer_outlined, size: 18, color: Colors.grey),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'COP$discount de descuento por compras superiores a COP$minimumPurchase (Cupon de tienda)',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Color.fromARGB(221, 104, 104, 104),
                                  fontFamily: "Alef",
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 18, color: Colors.grey),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Garantía de envío',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Color.fromARGB(221, 104, 104, 104),
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
      ),
    );
  }
}
