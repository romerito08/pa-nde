import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final String title;
  final bool isMobile;
  
  final VoidCallback onTap;
  const Footer({super.key,
    required this.title,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    
  return InkWell(
    onTap: onTap, // <--- Aquí se ejecuta la acción personalizada
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 13 : 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  }
}
