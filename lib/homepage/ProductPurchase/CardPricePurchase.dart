import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CardPricePurchase extends StatelessWidget {
  final double discountedPrice;
  final int discount;
  final double savings;

  const CardPricePurchase({
    super.key,
    required this.discountedPrice,
    required this.discount,
    required this.savings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        
      ),
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto al inicio
                children: [
                  Text(
                    'COP ${NumberFormat('#,##0', 'es_CO').format(discountedPrice)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Insanibc",
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              if (discount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        '-${discount.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Ahorraste COP ${savings.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: 200, // Ajusta el ancho según sea necesario para que coincida con el espacio ocupado por los textos de descuento y ahorro
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
