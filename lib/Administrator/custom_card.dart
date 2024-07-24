import 'package:flutter/material.dart';
import 'package:orderly/Administrator/nested_list.dart';

class CustomCard extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> value;
  final VoidCallback onTap;

  const CustomCard({
    required this.documentId,
    required this.value,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(10),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value.containsKey('foto_producto') && value['foto_producto'] is String)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    value['foto_producto'],
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    NestedList(data: value, documentId: documentId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
