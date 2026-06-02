import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselSection extends StatefulWidget {
  final String title;
  final double height;
  final double viewportFraction;
  final List<Widget> items;
  final bool isSubSection;

  const CarouselSection({
    super.key,
    required this.title,
    required this.height,
    required this.viewportFraction,
    required this.items,
    this.isSubSection = false,
  });

  @override
  State<CarouselSection> createState() => _CustomCarouselSectionState();
}

class _CustomCarouselSectionState extends State<CarouselSection> {
  // Cada carrusel maneja internamente su propio controlador de animaciones
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CABECERA DEL CARRUSEL (Título + Flechas) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: widget.isSubSection ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white70,
                    size: 18,
                  ),
                  onPressed: () => _carouselController.previousPage(
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 18,
                  ),
                  onPressed: () => _carouselController.nextPage(
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // --- CUERPO DEL CARRUSEL ---
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: widget.viewportFraction,
            padEnds: false, // Alineación a la izquierda estilo Figma
            enableInfiniteScroll: false,
            initialPage: 0,
            disableCenter: true,
          ),
          items: widget.items,
        ),
      ],
    );
  }
}