import 'package:flutter/material.dart';
import 'package:orderly/homepage/ProductPurchase/CardPricePurchase.dart';

class ProductDetails extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final int quantity;

  const ProductDetails({
    Key? key,
    required this.itemData,
    required this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int price = itemData['precio'] ?? 0;
    int discount = itemData['discount'] ?? 0;
    double discountedPrice = price * ((100 - discount) / 100);
    double savings = price - discountedPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(itemData['nombre'] ?? '', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: "Poppins", fontSize: 15)),
        const SizedBox(height: 16),
        CardPricePurchase(discountedPrice: discountedPrice, discount: discount, savings: savings),
        const SizedBox(height: 16),
        _buildTextSection(itemData['descripcion'] ?? '', textAlign: TextAlign.justify),
        const SizedBox(height: 24),
        _buildTextSection('Compatible', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildTextSection(itemData['compatible'] ?? '', textAlign: TextAlign.justify),
        const SizedBox(height: 24),
        _buildTextSection('Especificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildTextSection(itemData['especificaciones'] ?? '', textAlign: TextAlign.justify),
        const SizedBox(height: 24),
        _buildInfoSection(icon: Icons.credit_card, title: 'Métodos de pago', subtitle: 'Nequi • PSE • Crédito • Débito • Efectivo'),
      ],
    );
  }

  Widget _buildTextSection(String text, {TextAlign? textAlign, TextStyle? style}) {
    return Text(text, style: style ?? TextStyle(fontFamily: "Poppins"), textAlign: textAlign ?? TextAlign.left);
  }

  Widget _buildInfoSection({required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontFamily: "Poppins")),
                ],
              ),
            ),
            if (onTap != null) Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
