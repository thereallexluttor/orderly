import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class AdministratorHomePage extends StatelessWidget {
  const AdministratorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white, // Color de fondo suave
            child: const Center(
              child: Text('Administrador Home Page'), // Reemplaza esto con tu contenido
            ),
          ),
          Positioned(
            top: 14,
            left: 23,
            child: Image.asset(
              'lib/images/OrderlyLogoLogin.png',
              width: 63, // Ajusta el tamaño de la imagen según sea necesario
              height: 63,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 45,
        items: <Widget>[
          Icon(Icons.shopping_cart_checkout_outlined, size: 17),
          Icon(Icons.message_outlined, size: 17),
          Icon(Icons.qr_code_scanner_outlined, size: 23),
          Icon(Icons.edit_document, size: 17),
          Icon(Icons.data_exploration_outlined, size: 17),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.purple,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: Duration(milliseconds: 400),
        onTap: (index) {
          // Implementa la lógica de navegación aquí si es necesario
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
