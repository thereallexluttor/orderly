// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:orderly/homepage/ProductPurchase/ProductPurchase.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ItemCardOffers extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ItemCardOffers({super.key, required this.itemData});

  @override
  Widget build(BuildContext context) {
    final bool isAgotado = itemData['status'] == 'agotado';
    final Color priceColor = isAgotado ? Colors.grey : const Color.fromARGB(255, 255, 17, 0);
    final Color priceColor2 = isAgotado ? Colors.grey : const Color.fromARGB(255, 0, 0, 0);
    const Color infoColor = Colors.grey;

    final int? discount = itemData['discount'];
    final int? originalPrice = itemData['precio'];
    final double? discountedPrice = (discount != null && discount > 0 && originalPrice != null)
        ? originalPrice * (1 - discount / 100)
        : originalPrice?.toDouble();

    return InkWell(
      highlightColor: Colors.white,
      hoverColor: Colors.white,
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ProductPurchase(itemData: itemData),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 200),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromARGB(255, 235, 235, 235)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        imageUrl: itemData['foto_producto'] ?? '',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: FadeTransition(
                            opacity: AlwaysStoppedAnimation(0.5),
                            child: SpinKitFadingCircle(
                              color: Colors.grey,
                              size: 50.0,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.image, size: 100),
                        fadeInDuration: Duration(milliseconds: 500),
                        fadeOutDuration: Duration(milliseconds: 500),
                      ),
                    ),
                  ),
                  if (isAgotado)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: Container(
                          color: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: const Center(
                            child: Text(
                              'Agotado',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (itemData['discount'] != null && itemData['discount'] > 0)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        child: Container(
                          color: const Color.fromARGB(255, 255, 17, 0),
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                          child: Text(
                            '-${itemData['discount']}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins"
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (itemData['delivery_fee_status'] == true)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                        child: Container(
                          color: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                          child: const Text(
                            'Delivery Free',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (itemData['cash_back'] == true)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: Container(
                          color: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                          child: const Text(
                            'Cash Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                itemData['nombre'] != null && itemData['nombre'].length > 14
                    ? itemData['nombre'].substring(0, 14) + '...'
                    : itemData['nombre'] ?? 'Unnamed Item',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: "Poppins", color: priceColor2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'COP',
                    style: TextStyle(letterSpacing: 1, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: "Poppins", color: priceColor),
                  ),
                  const SizedBox(width: 0.3),
                  Text(
                    discountedPrice != null ? NumberFormat('#,##0', 'es_CO').format(discountedPrice) : 'N/A',
                    style: TextStyle(letterSpacing: 1.0, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "Poppins-Black", color: priceColor),
                  ),
                  if (discount != null && discount > 0) ...[
                    const SizedBox(width: 1),
                    Text(
                      originalPrice != null ? NumberFormat('#,##0', 'es_CO').format(originalPrice) : 'N/A',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Ventas: ${itemData['ventas'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 12, fontFamily: "Poppins", color: infoColor),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, size: 12, color: infoColor),
                  const SizedBox(width: 2),
                  Text(
                    itemData['valoracion'] != null ? itemData['valoracion'].toStringAsFixed(1) : 'N/A',
                    style: const TextStyle(fontSize: 12, fontFamily: "Poppins", color: infoColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
