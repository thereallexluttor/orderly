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
          clipBehavior: Clip.none, // Allows the logo to overlap the banner
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    spreadRadius: 2, // Spread radius
                    blurRadius: 7, // Blur radius
                    offset: Offset(0, 3), // Shadow offset
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
                  height: 130, // Reduced banner size
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
              bottom: -20, // Logo overlaps 20 pixels from the banner
              left: 15,
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
              top: 25, // Adjust the position as needed
              left: 15,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white, // White background
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: Colors.black, // Black icon
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.0), // Adjust space for the logo overlap
        Padding(
          padding: EdgeInsets.only(top: 14.0, left: 18, right: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    storeName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: "Poppins-Black",
                    ),
                  ),
                  SizedBox(width: 60),
                  Text(
                    '⭐',
                    style: TextStyle(fontSize: 12, fontFamily: "Poppins"),
                  ),
                  SizedBox(width: 4),
                  Text(
                    stars,
                    style: TextStyle(fontSize: 12, fontFamily: "Poppins"),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '❤️',
                    style: TextStyle(fontSize: 12, fontFamily: "Poppins"),
                  ),
                  SizedBox(width: 4),
                  Text(
                    sales,
                    style: TextStyle(fontSize: 12, fontFamily: "Poppins"),
                  ),
                ],
              ),
              SizedBox(height: 25.0),
              Center(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_offer_outlined, size: 15),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'COP${discount.toString()} de descuento por compras superiores a COP${minimumPurchase.toString()} (Cupon de tienda)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 27, 27, 27),
                                fontFamily: "Alef",
                                //fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 15),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Garantia de envio',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 27, 27, 27),
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
