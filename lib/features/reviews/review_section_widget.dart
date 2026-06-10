import 'package:flutter/material.dart';
import 'review_controller.dart';
import '../../models/review.dart';

class ReviewSectionWidget extends StatefulWidget {
  final String hotelId;
  const ReviewSectionWidget({super.key, required this.hotelId});

  @override
  State<ReviewSectionWidget> createState() => _ReviewSectionWidgetState();
}

class _ReviewSectionWidgetState extends State<ReviewSectionWidget> {
  final _reviewController = ReviewController();
  final _commentController = TextEditingController();
  int _selectedRating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);

    final success = await _reviewController.crearResena(
      hotelId: widget.hotelId,
      comentario: _commentController.text.trim(),
      calificacion: _selectedRating,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success == true) {
        _commentController.clear();
        setState(() {
          _selectedRating = 5;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('🎉 ¡Gracias por tu opinión!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.redAccent, content: Text('⚠️ Inicia sesión para comentar o verifica tu conexión.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandYellow = Color(0xffE2E600);

    return StreamBuilder<List<Review>>(
      stream: _reviewController.streamReviews(widget.hotelId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: brandYellow)),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Error en la base de datos: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          );
        }
        
        final reviews = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reseñas de otros exploradores',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.black,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),

            // CAJA DE COMENTARIOS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '¿Qué tal fue tu experiencia?', 
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)
                      ),
                      DropdownButton<int>(
                        value: _selectedRating,
                        underline: const SizedBox(),
                        items: List.generate(5, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Row(
                              children: [
                                Text('${index + 1} '),
                                const Icon(Icons.star, color: brandYellow, size: 18),
                              ],
                            ),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRating = val);
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu opinión aquí...',
                      hintStyle: const TextStyle(color: Colors.black38),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: brandYellow))
                        : TextButton(
                            onPressed: _submitReview,
                            child: const Text(
                              'Enviar Opinión', 
                              style: TextStyle(color: Color(0xff141811), fontWeight: FontWeight.bold)
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // LISTA VERTICAL DE OPINIONES
            if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No hay reseñas escritas aún. ¡Sé el primero en opinar!', 
                  style: TextStyle(
                    color: Colors.black45, 
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const SizedBox(height: 28),
                itemBuilder: (context, index) {
                  final rev = reviews[index];
                  
                  // Descomponemos el String para extraer la fecha real y el texto original
                  final partes = rev.texto.split('|');
                  final String fechaReal = partes.length > 1 ? partes[0] : 'Reciente';
                  final String textoReal = partes.length > 1 ? partes.sublist(1).join('|') : rev.texto;
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: brandYellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline, color: Colors.black, size: 24),
                      ),
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  rev.nombreUsuario,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 16, 
                                    color: Colors.black
                                  ),
                                ),
                                // --- FECHA COLOCADA EN SU CONTENEDOR CORRECTO DERECHO ---
                                Text(
                                  fechaReal, 
                                  style: const TextStyle(color: Colors.black38, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < rev.calificacion ? Icons.star : Icons.star_border,
                                  color: brandYellow,
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(height: 10),
                            // --- COMENTARIO REAL SEPARADO Y LIMPIO ---
                            Text(
                              textoReal,
                              style: const TextStyle(
                                color: Colors.black54, 
                                fontSize: 14, 
                                height: 1.5,
                                fontFamily: 'Montserrat'
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            
            const SizedBox(height: 24),
            InkWell(
              onTap: () {},
              child: const Text(
                'Ver todas las reseñas',
                style: TextStyle(color: brandYellow, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }
}