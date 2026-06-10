import 'package:flutter/material.dart';
import 'package:paonde_app/widgets/header.dart';
import 'package:paonde_app/widgets/footer.dart';
import 'package:paonde_app/widgets/drawer.dart';

class ReservasAliadoScreen extends StatefulWidget {
  const ReservasAliadoScreen({super.key});

  @override
  State<ReservasAliadoScreen> createState() => _ReservasAliadoScreenState();
}

class _ReservasAliadoScreenState extends State<ReservasAliadoScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 817;

    const Color primaryYellow = Color(0xffE2E600);
    const Color bgColor = Color(0xff1A1F16);
    const Color cardBgColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      drawer: isMobile ? const CustomDrawer(selectedIndex: 3) : null, 
      appBar: isMobile ? const Header(selectedIndex: 3, isMobile: true) : null,
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
                    'Tu agenda de experiencias para hoy',
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

            // --- MÉTRICAS DE HOY ---
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryMetric('Nuevas solicitudes', '3', primaryYellow),
                      _buildSummaryMetric('Próximas salidas', '2', primaryYellow),
                      _buildSummaryMetric('Por cobrar', '\$200', primaryYellow),
                    ],
                  ),
                ),
              ),
            ),

            // --- RESERVAS ---
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 24.0, 
                    vertical: 32.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildBookingCard(isMobile, 'Título del servicio', 'Pagado', Colors.green, cardBgColor),
                      const SizedBox(height: 24),
                      _buildBookingCard(isMobile, 'Título del servicio', 'Pagado', Colors.green, cardBgColor),
                      const SizedBox(height: 24),
                      _buildBookingCard(isMobile, 'Título del servicio', 'Disfrutado', Colors.blue, cardBgColor),
                      
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
              _aliadoNavLink(context, 'Servicios', false, '/partner-services'),
              _aliadoNavLink(context, 'Cotizaciones', false, '/partner-quotes'),
              _aliadoNavLink(context, 'Reservas', true, '/partner-reservations'),
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

  Widget _buildSummaryMetric(String label, String value, Color yellow) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: yellow, fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBookingCard(bool isMobile, String title, String status, Color statusColor, Color cardBg) {
    return Container(
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (!isMobile)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 110,
                        decoration: BoxDecoration(color: const Color(0xffeeeeee), borderRadius: BorderRadius.circular(16)),
                        child: const Center(child: Icon(Icons.image_outlined, color: Colors.black26, size: 36)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(children: [Icon(Icons.location_on_outlined, size: 14, color: Colors.black54), Text(' Place', style: TextStyle(color: Colors.black54, fontSize: 12))]),
                          Row(children: List.generate(5, (_) => const Icon(Icons.star, size: 12, color: Colors.amber))),
                        ],
                      ),
                      Text(title, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Text('Nombre de Explorador', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildDateCell('Check-in')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDateCell('Check-out')),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Text('2', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Text('Huéspedes', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 120, decoration: BoxDecoration(color: const Color(0xffeeeeee), borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.image_outlined, color: Colors.black26, size: 36))),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Nombre de Explorador', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(children: [Expanded(child: _buildDateCell('Check-in')), const SizedBox(width: 8), Expanded(child: _buildDateCell('Check-out'))]),
              ],
            ),
          
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: const BorderSide(color: Colors.black45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Enviar cotización', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff11140E), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text('Ver Comprobante', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateCell(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          width: double.infinity,
          decoration: BoxDecoration(color: const Color(0xffE0E0E0), borderRadius: BorderRadius.circular(8)),
          child: const Text('dd/mm/aaaa', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12)),
        ),
      ],
    );
  }
}