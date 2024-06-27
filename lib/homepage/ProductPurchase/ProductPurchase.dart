import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductPurchase extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ProductPurchase({super.key, required this.itemData});

  @override
  Widget build(BuildContext context) {
    int price = itemData['precio'] ?? 0;
    int discount = itemData['discount'] ?? 0;
    double discountedPrice = price * ((100 - discount) / 100);
    double savings = price - discountedPrice;
    int sales = itemData['ventas'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (itemData['foto_producto'] != null)
              Stack(
                children: [
                  Image.network(itemData['foto_producto']),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(237, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '❤️',
                            style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                          ),
                          const SizedBox(width: 2,),
                          Text(
                            '${sales.toString()} ',
                            style: const TextStyle(fontSize: 14, fontFamily: "Poppins"),
                          ),
                          const SizedBox(width: 5,),
                          const Text(
                            '⭐',
                            style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                          ),
                          const SizedBox(width: 2,),
                          Text(
                            itemData['valoracion'] != null ? itemData['valoracion'].toStringAsFixed(1) : 'N/A',
                            style: const TextStyle(fontSize: 14, fontFamily: "Poppins"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                                itemData['nombre'],
                                style: const TextStyle(fontSize: 15, fontFamily: "Alef", fontWeight: FontWeight.bold),
                              ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: discount > 0 ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Text(
                            '',
                            style: TextStyle(fontSize: 20, fontFamily: "Poppins"),
                          ),
                          Text(
                            'COP ${NumberFormat('#,##0', 'es_CO').format(discountedPrice)}',
                            style: const TextStyle(fontSize: 25, fontFamily: "Poppins"),
                          ),
                        ],
                      ),
                      if (discount > 0) ...[
                        const SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: "Poppins"),
                              ),
                            ),
                            const SizedBox(height: 3), // Cambiado a height para espacio vertical
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Ahorraste COP ${savings.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: "Poppins"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const Divider(), // Divider agregado aquí

                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                                    itemData['descripcion'],
                                    style: const TextStyle(color: Colors.black, fontSize: 10, fontFamily: "Poppins"),
                                  ),
                    ),
                  ),

                  const Divider(), // Divider agregado aquí

                  const SizedBox(height: 4,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Especificaciones',
                        style: TextStyle(fontSize: 14, fontFamily: "Poppins"),
                      ),
                      Container(
                        width: 20, // Ajusta el tamaño según sea necesario
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),

                  Divider(thickness: 8, color: Color.fromARGB(255, 235, 235, 235),),

                  

                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
              icon: Image.asset('lib/images/interfaceicons/shop.png', height: 25,),
              onPressed: () {
                // Acción para Tienda
              },
              tooltip: 'Tienda',
            ),

              IconButton(
                icon: Image.asset('lib/images/interfaceicons/message.png', height: 25,),
                onPressed: () {
                  // Acción para Mensaje
                },
                tooltip: 'Mensaje',
              ),
              ElevatedButton(
  onPressed: () {
    // Acción para agregar al carrito
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    side: const BorderSide(color: Colors.black),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), // Ajusta el padding para hacer el botón más compacto
    minimumSize: const Size(50, 36), // Tamaño mínimo del botón
  ),
  child: const Text(
    'Agregar al carrito',
    style: TextStyle(color: Colors.black, fontSize: 12, fontFamily: "Poppins"),
  ),
),
const SizedBox(width: 5,),
ElevatedButton(
  onPressed: () {
    // Acción para comprar
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.purpleAccent,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Ajusta el padding para hacer el botón más compacto
    minimumSize: const Size(50, 36), // Tamaño mínimo del botón
  ),
  child: const Text(
    'Comprar!',
    style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: "Poppins", fontWeight: FontWeight.bold),
  
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}
