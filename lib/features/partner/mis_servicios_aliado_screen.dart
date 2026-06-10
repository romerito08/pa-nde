import 'package:flutter/material.dart';
import 'package:paonde_app/widgets/header.dart';
import 'package:paonde_app/widgets/footer.dart';
import 'package:paonde_app/widgets/drawer.dart';

class MisServiciosAliadoScreen extends StatefulWidget {
  const MisServiciosAliadoScreen({super.key});

  @override
  State<MisServiciosAliadoScreen> createState() => _MisServiciosAliadoScreenState();
}

class _MisServiciosAliadoScreenState extends State<MisServiciosAliadoScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 817;

    const Color primaryYellow = Color(0xffE2E600);
    const Color bgColor = Color(0xff1A1F16);
    const Color cardBgColor = Colors.white; 

    return Scaffold(
      backgroundColor: bgColor,
      drawer: isMobile ? const CustomDrawer(selectedIndex: 1) : null, 
      appBar: isMobile ? const Header(selectedIndex: 1, isMobile: true) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isMobile) _buildAliadoHeader(context),

            // --- HERO SECTOR ---
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: isMobile ? 160 : 260,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/Encabezado.png', 
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: isMobile ? 160 : 260,
                  color: Colors.black.withAlpha((0.3 * 255).round()), 
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Optimiza tu alcance y conecta con la comunidad Pa\'onde',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 22 : 36,
                      fontWeight: FontWeight.bold,
                      shadows: const [Shadow(blurRadius: 10, color: Colors.black87)],
                    ),
                  ),
                ),
              ],
            ),

            // --- CONTENIDO ---
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 40.0, 
                    vertical: 24.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryYellow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Text('Nueva Publicación', style: TextStyle(fontWeight: FontWeight.bold)),
                          label: const Icon(Icons.add_circle, size: 18),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text('Alojamientos', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isMobile ? 1 : 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: isMobile ? 1.1 : 1.35,
                        children: [
                          _buildAliadoServiceCard('Título del servicio', 'Place', 'Activo', Colors.green, cardBgColor, primaryYellow),
                          _buildAliadoServiceCard('Título del servicio', 'Place', 'Pendiente por aprobación', Colors.orange, cardBgColor, primaryYellow),
                          _buildAliadoServiceCard('Título del servicio', 'Place', 'Pausado', Colors.grey, cardBgColor, primaryYellow),
                          _buildAliadoServiceCard('Título del servicio', 'Place', 'Activo', Colors.green, cardBgColor, primaryYellow),
                        ],
                      ),
                      const SizedBox(height: 40),

                      const Text('Experiencias', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isMobile ? 1 : 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: isMobile ? 1.1 : 1.35,
                        children: [
                          _buildAliadoServiceCard('Título del servicio', 'Place', 'Activo', Colors.green, cardBgColor, primaryYellow),
                          _buildAliadoServiceCard('Título del servicio', 'Place', 'Activo', Colors.green, cardBgColor, primaryYellow),
                          _buildAliadoServiceCard('Título del servicio', 'Place', 'Activo', Colors.green, cardBgColor, primaryYellow),
                          _buildAliadoServiceCard('Título del servicio', 'Place', 'Activo', Colors.green, cardBgColor, primaryYellow),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // --- FOOTER ---
                      const Divider(color: primaryYellow, thickness: 1),
                      Padding(
                        padding: EdgeInsets.only(top: isMobile ? 4.0 : 8.0, bottom: isMobile ? 0.0 : 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('assets/Logo.png', width: isMobile ? 80 : 150, fit: BoxFit.contain),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Footer(title: 'Sobre Nosotros', isMobile: isMobile, onTap: () => Navigator.pushNamed(context, '/sobre-nosotros')),
                                  SizedBox(width: isMobile ? 6 : 20),
                                  Footer(title: 'Sé un Aliado', isMobile: isMobile, onTap: () => Navigator.pushNamed(context, '/se-un-aliado')),
                                  SizedBox(width: isMobile ? 6 : 20),
                                  Footer(title: 'Ayuda', isMobile: isMobile, onTap: () => Navigator.pushNamed(context, '/ayuda')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAliadoHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      color: const Color(0xff1A1F16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/Logo.png', width: 120),
          Row(
            children: [
              _aliadoNavLink(context, 'Dashboard', false, '/partner-dashboard'),
              _aliadoNavLink(context, 'Servicios', true, '/partner-services'),
              _aliadoNavLink(context, 'Cotizaciones', false, '/partner-quotes'),
              _aliadoNavLink(context, 'Reservas', false, '/partner-reservations'),
            ],
          ),
          // Como debe quedar:
TextButton.icon(
  onPressed: () {
    Navigator.pushNamed(context, '/partner-profile');
  },
  icon: const Text('Mi perfil', style: TextStyle(color: Color(0xffE2E600), fontWeight: FontWeight.bold)),
  label: const Icon(Icons.account_circle_outlined, color: Color(0xffE2E600)),
)
        ],
      ),
    );
  }

  Widget _aliadoNavLink(BuildContext context, String text, bool isSelected, String routeName) {
    return InkWell(
      onTap: () {
        if (!isSelected) {
          Navigator.pushNamed(context, routeName);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? const Color(0xffE2E600) : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAliadoServiceCard(String title, String location, String statusText, Color statusColor, Color cardBg, Color yellow) {
    return Container(
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(color: Color(0xffeeeeee), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              child: const Center(child: Icon(Icons.image_outlined, color: Colors.black26, size: 40)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(location, style: const TextStyle(color: Colors.black54, fontSize: 11)),
                    ],
                  ),
                  Text(title, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  const Text(
                    'Descripción del alojamiento que se está visitando con todas las cosas que ofrece o el servicio que se ofrece',
                    maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 11),
                  ),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 28,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(backgroundColor: yellow, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), padding: EdgeInsets.zero),
                            child: const Text('Editar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 28,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: const BorderSide(color: Colors.black45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), padding: EdgeInsets.zero),
                            child: Text(statusText == 'Pausado' ? 'Publicar' : 'Pausar', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity, height: 28,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff11140E), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                      child: const Text('Estadísticas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}