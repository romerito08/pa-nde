
import 'package:flutter/material.dart';


class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xff1A1F16),
      body: Row(
        children: [
          Expanded (
            child: Container( 
              child:Stack(
                children: [
                  SizedBox.expand(
                  child: Image.asset('assets/imageninicio.png', 
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.5, 
                  child: Image.asset('assets/logo.png'),
                ),
              ),
            ],
          ),
        ),
          ),
      ],
    ),
    );
  }
}