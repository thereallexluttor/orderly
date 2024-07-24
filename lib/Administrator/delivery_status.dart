import 'package:flutter/material.dart';

class DeliveryStatusPage extends StatelessWidget {
  final String selectedKey;
  final String parentDocumentId;

  const DeliveryStatusPage({
    required this.selectedKey,
    required this.parentDocumentId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Status'),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Key: $selectedKey',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Parent Document ID: $parentDocumentId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Aquí puedes agregar más widgets para mostrar más detalles o acciones
          ],
        ),
      ),
    );
  }
}
