import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  
  final bool isMobile;

  const Header({
    super.key,
    required this.selectedIndex,
    required this.isMobile,
  });

  // Color global o copiado de tu configuración
  static const Color primaryYellow = Color(0xffE2E600);
  static const Color bgColor = Color(0xff1A1F16);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Image.asset('assets/Logo.png', width: 100),
        centerTitle: true,
      );
    }

    // Header para Escritorio
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/Logo.png', width: 120),
          Row(
            children: [
              _navLink(context, 'Inicio', 0),
              _navLink(context, 'Alojamientos', 1),
              _navLink(context, 'Experiencias', 2),
              _navLink(context, 'Destinos', 3),
              _navLink(context, 'Reservas', 4),
            ],
          ),
          TextButton.icon(
            onPressed: () => _manejarNavegacion(context, 5),
            icon: const Text(
              'Mi perfil',
              style: TextStyle(
                color: primaryYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            label: const Icon(
              Icons.account_circle_outlined,
              color: primaryYellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navLink(BuildContext context, String text, int index) {
    final bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => _manejarNavegacion(context, index), // Pasamos el contexto
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? primaryYellow : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Función lógica que maneja a dónde ir según el índice pulsado
  void _manejarNavegacion(BuildContext context, int index) {
    if (index == selectedIndex)
      return; // Si ya está en la pantalla, no hace nada

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/inicio');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/alojamientos');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/experiencias');
        break;
      // Añade los demás casos cuando crees tus pantallas correspondientes
    }
  }
  @override
  Size get preferredSize => Size.fromHeight(isMobile ? kToolbarHeight : 70.0);
}