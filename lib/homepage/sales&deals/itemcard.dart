import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ItemCard({Key? key, required this.itemData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image, size: 100);
                      },
                    ),
                  ),
                ),
                if (itemData['status'] == 'agotado')
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
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Center(
                          child: Text(
                            'Agotado',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins"
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (itemData['discount'] != null && itemData['discount'] > 0)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        //bottomLeft: Radius.circular(10.0),
                      ),
                      child: Container(
                        color: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Text(
                          '-${itemData['discount']}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins"
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              itemData['nombre'] != null && itemData['nombre'].length > 15
                  ? itemData['nombre'].substring(0, 15) + '...'
                  : itemData['nombre'] ?? 'Unnamed Item',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              'COP ${itemData['precio'] != null ? NumberFormat('#,##0', 'es_CO').format(itemData['precio']) : 'N/A'}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: "Poppins", color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

