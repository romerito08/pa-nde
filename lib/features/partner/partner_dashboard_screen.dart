import 'package:flutter/material.dart';
import 'package:paonde_app/widgets/header.dart';
import 'package:paonde_app/widgets/footer.dart';
import 'package:paonde_app/widgets/drawer.dart'; 

class DashboardAliadoScreen extends StatefulWidget {
  const DashboardAliadoScreen({super.key});

  @override
  State<DashboardAliadoScreen> createState() => _DashboardAliadoScreenState();
}

class _DashboardAliadoScreenState extends State<DashboardAliadoScreen> {
  
  final Map<String, Map<String, String>> mapaReservas = {
    'April 1': {'servicio': 'Posada Gran Roque', 'cliente': 'Carlos Mendoza'},
    '4': {'servicio': 'Tour Morrocoy Full Day', 'cliente': 'María Gómez'},
    '6': {'servicio': 'Hospedaje Suite VIP', 'cliente': 'Luis Alvarado'},
    '8': {'servicio': 'Tour Morrocoy Full Day', 'cliente': 'Andrés Pérez'},
    '14': {'servicio': 'Posada Gran Roque', 'cliente': 'Elena Castellanos'},
    '18': {'servicio': 'Hospedaje Suite VIP', 'cliente': 'Pedro Infante'},
    '20': {'servicio': 'Tour Morrocoy Full Day', 'cliente': 'Diana Carolina'},
    '23': {'servicio': 'Posada Gran Roque', 'cliente': 'Juan Arango'},
    '26': {'servicio': 'Hospedaje Suite VIP', 'cliente': 'Roberto Carlos'},
    '29': {'servicio': 'Tour Morrocoy Full Day', 'cliente': 'Sofía Tejera'},
  };

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 817;

    const Color primaryYellow = Color(0xffE2E600);
    const Color bgColor = Color(0xff1A1F16);
    const Color cardBgColor = Color(0xff11140E); 

    return Scaffold(
      backgroundColor: bgColor,
      drawer: isMobile ? const CustomDrawer(selectedIndex: 0) : null,
      appBar: isMobile ? const Header(selectedIndex: 0, isMobile: true) : null,
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
                    'Conectando tus rutas con nuevos exploradores',
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
                    vertical: 32.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      
                      // --- TARJETAS DE MÉTRICAS ---
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isMobile ? 2 : 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isMobile ? 1.2 : 1.7,
                        children: [
                          _buildMetricCard('Ventas totales', '\$1000', primaryYellow, cardBgColor),
                          _buildChartMetricCard('Ingresos en la semana', primaryYellow, cardBgColor),
                          _buildMetricCard('Por cobrar', '\$200', primaryYellow, cardBgColor),
                          _buildMetricCard('Reservas confirmadas', '10', primaryYellow, cardBgColor),
                          _buildMetricCard('Nuevas solicitudes', '3', primaryYellow, cardBgColor),
                          _buildMetricCard('Satisfacción del cliente', '4,8', primaryYellow, cardBgColor),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // --- CALENDARIO ---
                      const Center(
                        child: Text(
                          'Calendario de reservas',
                          style: TextStyle(color: primaryYellow, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCalendarioReal(isMobile),
                      const SizedBox(height: 40),

                      // --- SERVICIOS DESTACADOS ---
                      const Text(
                        'Servicios destacados',
                        style: TextStyle(color: primaryYellow, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      const Text('Alojamientos', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      _buildHorizontalServicesList(
                        isMobile: isMobile,
                        height: 200, 
                        childBuilder: (context) => _buildLocalDashboardCard('Título del servicio', 'Falcón'),
                      ),
                      const SizedBox(height: 24),

                      const Text('Experiencias', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      _buildHorizontalServicesList(
                        isMobile: isMobile,
                        height: 200, 
                        childBuilder: (context) => _buildLocalDashboardCard('Título del servicio', 'Bolívar'),
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
    const Color bgColor = Color(0xff1A1F16);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/Logo.png', width: 120),
          Row(
            children: [
              _aliadoNavLink(context, 'Dashboard', true, () {}),
              _aliadoNavLink(context, 'Servicios', false, () {
                Navigator.pushNamed(context, '/partner-services');
              }),
              _aliadoNavLink(context, 'Cotizaciones', false, () {
                Navigator.pushNamed(context, '/partner-quotes');
              }),
              _aliadoNavLink(context, 'Reservas', false, () {}),
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

  Widget _aliadoNavLink(BuildContext context, String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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

  Widget _buildMetricCard(String title, String value, Color yellow, Color bg) {
    final Color borderColor = yellow.withAlpha((0.4 * 255).round());
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: yellow, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartMetricCard(String title, Color yellow, Color bg) {
    final Color borderColor = yellow.withAlpha((0.4 * 255).round());
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end, 
            children: [
              _buildBar(10, yellow), _buildBar(18, yellow), _buildBar(14, yellow),
              _buildBar(25, yellow), _buildBar(20, yellow), _buildBar(8, yellow), _buildBar(12, yellow),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('L', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text('M', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text('M', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text('J', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text('V', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text('S', style: TextStyle(color: Colors.white54, fontSize: 10)),
              Text('D', style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(width: 8, height: height, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)));
  }

  Widget _buildCalendarioReal(bool isMobile) {
    final List<String> dias = ['DOMINGO', 'LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
      child: Column(
        children: [
          Row(
            children: dias.map((d) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.white10)),
                child: Text(isMobile ? d.substring(0, 1) : d, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            )).toList(),
          ),
          _buildFilaCalendario(['30', '31', 'April 1', '2', '3', '4', '5']),
          _buildFilaCalendario(['6', '7', '8', '9', '10', '11', '12']),
          _buildFilaCalendario(['13', '14', '15', '16', '17', '18', '19']),
          _buildFilaCalendario(['20', '21', '22', '23', '24', '25', '26']),
          _buildFilaCalendario(['27', '28', '29', '30', '31', 'May 1', 'May 2']),
        ],
      ),
    );
  }

  Widget _buildFilaCalendario(List<String> numerosFila) {
    return Row(
      children: numerosFila.map((diaIdentificador) {
        final bool tieneReserva = mapaReservas.containsKey(diaIdentificador);
        final Map<String, String>? datosReserva = mapaReservas[diaIdentificador];

        return Expanded(
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: tieneReserva ? const Color(0xffE2E600) : Colors.transparent,
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(diaIdentificador, style: TextStyle(color: tieneReserva ? Colors.black : Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                if (tieneReserva && datosReserva != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(datosReserva['servicio'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                        Text(datosReserva['cliente'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 8)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHorizontalServicesList({required bool isMobile, required WidgetBuilder childBuilder, double height = 200}) {
    return SizedBox(
      height: height, 
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) => SizedBox(width: isMobile ? 220 : 240, child: childBuilder(context)),
      ),
    );
  }

  Widget _buildLocalDashboardCard(String title, String location) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: const Color(0xffeeeeee), borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Icon(Icons.image_outlined, color: Colors.black26)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(location, style: const TextStyle(color: Colors.black54, fontSize: 11)),
              Row(children: List.generate(5, (_) => const Icon(Icons.star, size: 10, color: Colors.amber))),
            ],
          ),
          Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
          const Text('Descripción corta presentada...', maxLines: 1, style: TextStyle(color: Colors.black87, fontSize: 11)),
        ],
      ),
    );
  }
}