
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  
  const CustomDrawer({
    super.key,
    required this.selectedIndex,});

  static const Color primaryYellow = Color(0xffE2E600);
  static const Color bgColor = Color(0xff1A1F16);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xff252B20),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: bgColor),
            child: Center(
              child: Image.asset('assets/Logo.png', width: 120),
            ),
          ),
          _drawerLink(context, 'Inicio', 0, Icons.home_outlined),
          _drawerLink(context, 'Alojamientos', 1, Icons.hotel_outlined),
          _drawerLink(context, 'Experiencias', 2, Icons.explore_outlined),
          _drawerLink(context, 'Destinos', 3, Icons.map_outlined),
          _drawerLink(context, 'Reservas', 4, Icons.book_online_outlined),
          const Divider(color: Colors.white12, height: 20),
          _drawerLink(context, 'Mi perfil', 5, Icons.account_circle_outlined),
        ],
      ),
    );
  }

  Widget _drawerLink(BuildContext context, String text, int index, IconData icon) {
    final bool isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? primaryYellow : Colors.white70),
      title: Text(
        text,
        style: TextStyle(
          color: isSelected ? primaryYellow : Colors.white,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        
        Navigator.pop(context); // Cierra el drawer
        _manejarNavegacion(context, index); // Navega a la pantalla correspondiente
      },
    );
  }
  void _manejarNavegacion(BuildContext context, int index) {
    if (index == selectedIndex) return; 

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
      
    }
  }
}
