import 'package:flutter/material.dart';

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
      children: _buildNestedList(data),
    );
  }

  List<Widget> _buildNestedList(Map<String, dynamic> data) {
    List<Widget> itemList = [];

    data.forEach((key, value) {
      if (value is Map) {
        itemList.add(
          GestureDetector(
            onTap: () {
              print('Selected Key: $key');
              print('Parent Document ID: $documentId');
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
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    NestedList(data: Map<String, dynamic>.from(value), documentId: documentId),
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
                  Text(
                    key,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  ...value.map((item) {
                    if (item is Map) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildNestedList(Map<String, dynamic>.from(item)),
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
