import 'package:flutter/material.dart';
import 'package:orderly/Administrator/delivery_status.dart';

class NestedList extends StatelessWidget {
  final Map<String, dynamic> data;
  final String documentId;

  const NestedList({
    required this.data,
    required this.documentId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildNestedList(context, data),
    );
  }

  void navigateToDeliveryStatus(BuildContext context, String key, String parentId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DeliveryStatusPage(
          selectedKey: key,
          parentDocumentId: parentId,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  List<Widget> _buildNestedList(BuildContext context, Map<String, dynamic> data) {
    List<Widget> itemList = [];

    data.forEach((key, value) {
      if (value is Map) {
        itemList.add(
          GestureDetector(
            onTap: () {
              print('Selected Key: $key');
              print('Parent Document ID: $documentId');
              navigateToDeliveryStatus(context, key, documentId);
            },
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.all(10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(255, 212, 212, 212)),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    if (value.containsKey('foto_producto')) 
                      Image.network(
                        value['foto_producto'],
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 50),
                      ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value['nombre_producto'] ?? 'Producto',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: "Alef"),
                          ),
                          Text(
                            value['descripcion_producto'] ?? '',
                            style: const TextStyle(fontSize: 10, color: Colors.blue),
                          ),
                          Text(
                            'Precio: ${value['precio'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(
                            'Cantidad: ${value['cantidad'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(
                            'Total a pagar: ${value['total_pagar'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(
                            'Status: ${value['status'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(
                            'Delivery status: ${value['delivery_status'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else if (value is List) {
        itemList.add(
          Card(
            margin: const EdgeInsets.all(10),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 255, 62, 62)),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        'https://example.com/image.png',
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 50),
                      ),
                      SizedBox(width: 10),
                      Text(
                        key,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  ...value.map((item) {
                    if (item is Map) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildNestedList(context, Map<String, dynamic>.from(item)),
                      );
                    } else {
                      return Text('$item', style: const TextStyle(fontSize: 10));
                    }
                  }).toList()
                ],
              ),
            ),
          ),
        );
      } else if (key == 'foto_producto' && value is String) {
        itemList.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(value, height: 150),
            ),
          ),
        );
      } else if (key == 'delivery_status' && value is String) {
        itemList.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Text(
                  '$key: ',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      } else if (['precio', 'nombre_producto', 'cantidad', 'total_pagar', 'status'].contains(key)) {
        itemList.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              '$key: $value',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }
    });

    return itemList;
  }
}
