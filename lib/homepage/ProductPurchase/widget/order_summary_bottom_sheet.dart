import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderSummaryBottomSheet extends StatelessWidget {
  final int totalPagar;
  final int quantity;
  final VoidCallback onConfirmOrder;

  const OrderSummaryBottomSheet({
    Key? key,
    required this.totalPagar,
    required this.quantity,
    required this.onConfirmOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Resumen del pedido', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: "Poppins", fontSize: 15)),
          const SizedBox(height: 20),
          _buildOrderSummaryRow('Cantidad:', '$quantity'),
          const SizedBox(height: 10),
          _buildOrderSummaryRow('Total a pagar:', 'COP ${NumberFormat('#,##0', 'es_CO').format(totalPagar)}'),
          const SizedBox(height: 30),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontFamily: "Poppins")),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Poppins")),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onConfirmOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          'Confirmar orden',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Poppins",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
