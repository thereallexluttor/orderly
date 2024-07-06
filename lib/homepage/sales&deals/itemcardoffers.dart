// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:orderly/homepage/ProductPurchase/ProductPurchase.dart';

class ItemCardOffers extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ItemCardOffers({super.key, required this.itemData});

  @override
  Widget build(BuildContext context) {
    // Determinar el color del texto en función del estado del producto
    final bool isAgotado = itemData['status'] == 'agotado';
    final Color priceColor = isAgotado ? Colors.grey : const Color.fromARGB(255, 255, 17, 0);
    final Color priceColor2 = isAgotado ? Colors.grey : Color.fromARGB(255, 0, 0, 0);
    const Color infoColor = Colors.grey;

    // Calcular el precio con descuento si hay descuento
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
            transitionDuration: Duration(milliseconds: 200), // Ajusta la duración aquí
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
            crossAxisAlignment: CrossAxisAlignment.start, // Alinear contenido a la izquierda
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Color.fromARGB(255, 235, 235, 235)), // Agregar borde gris
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0), // Redondear la imagen
                      child: Image.network(
                        itemData['foto_producto'] ?? '',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image, size: 100);
                        },
                      ),
                    ),
                  ),
                  if (isAgotado)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: Container(
                          color: Colors.grey,
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Center(
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
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        child: Container(
                          color: const Color.fromARGB(255, 255, 17, 0),
                          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                          child: Text(
                            '-${itemData['discount']}%',
                            style: TextStyle(
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
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                        child: Container(
                          color: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                          child: Text(
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
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: Container(
                          color: Colors.purple,
                          padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                          child: Text(
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
              SizedBox(height: 15),
              Text(
                itemData['nombre'] != null && itemData['nombre'].length > 14
                    ? itemData['nombre'].substring(0, 14) + '...'
                    : itemData['nombre'] ?? 'Unnamed Item',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: "Poppins", color: priceColor2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left, // Alinear texto a la izquierda
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // Alinear a la izquierda
                children: [
                  Text(
                    'COP',
                    style: TextStyle(letterSpacing: 1, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: "Poppins", color: priceColor),
                  ),
                  SizedBox(width: 0.3),
                  Text(
                    discountedPrice != null ? NumberFormat('#,##0', 'es_CO').format(discountedPrice) : 'N/A',
                    style: TextStyle(letterSpacing: 1.0, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "Poppins-Black", color: priceColor),
                  ),
                  if (discount != null && discount > 0) ...[
                    SizedBox(width: 1),
                    Text(
                      originalPrice != null ? NumberFormat('#,##0', 'es_CO').format(originalPrice) : 'N/A',
                      style: TextStyle(
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
              SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Ventas: ${itemData['ventas'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, fontFamily: "Poppins", color: infoColor),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.star, size: 12, color: infoColor),
                  SizedBox(width: 2),
                  Text(
                    itemData['valoracion'] != null ? itemData['valoracion'].toStringAsFixed(1) : 'N/A',
                    style: TextStyle(fontSize: 12, fontFamily: "Poppins", color: infoColor),
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
