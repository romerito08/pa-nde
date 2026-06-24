import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../features/catalog/logic/catalog_controller.dart';
import '../data/venezuela_geo.dart';
import '../theme/app_colors.dart';

/// Barra de búsqueda con campo de texto y botón de filtros (tune).
///
/// Al pulsar el botón se despliega un panel flotante DEBAJO de la barra
/// que sigue al scroll mediante [CompositedTransformFollower]. Los selectors
/// de Estado/Municipio son listas inline (sin overlay) para evitar conflictos
/// de z-order con [CompositedTransformFollower].
class BarraBuscadora extends StatefulWidget {
  final void Function(String texto) onBuscar;

  /// Llamado después de que el panel de filtros ejecuta "Buscar". Si es null,
  /// el panel aplica los filtros pero no navega a ninguna pantalla.
  final VoidCallback? onFiltrosAplicados;

  const BarraBuscadora({
    super.key,
    required this.onBuscar,
    this.onFiltrosAplicados,
  });

  @override
  State<BarraBuscadora> createState() => _BarraBuscadoraState();
}

class _BarraBuscadoraState extends State<BarraBuscadora> {
  final _controller = TextEditingController();
  final _layerLink = LayerLink();
  final _buttonKey = GlobalKey();
  OverlayEntry? _entry;

  bool get _abierto => _entry != null;

  @override
  void dispose() {
    _controller.dispose();
    _cerrarPanel();
    super.dispose();
  }

  void _togglePanel() => _abierto ? _cerrarPanel() : _abrirPanel();

  void _abrirPanel() {
    _entry = OverlayEntry(builder: _buildEntry);
    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _cerrarPanel() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
    if (mounted) setState(() {});
  }

  Widget _buildEntry(BuildContext ctx) {
    // Calcular el espacio disponible debajo del botón para que el panel
    // nunca desborde el viewport, pero siempre pueda hacer scroll interno.
    double panelMaxHeight = MediaQuery.of(context).size.height * 0.78;
    final box =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final bottomY =
          box.localToGlobal(Offset(0, box.size.height)).dy;
      final available =
          MediaQuery.of(context).size.height - bottomY - 16;
      panelMaxHeight =
          available.clamp(220.0, MediaQuery.of(context).size.height * 0.85);
    }

    return Stack(
      children: [
        // Toque fuera del panel → cerrar
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _cerrarPanel,
          ),
        ),
        // Panel anclado al borde inferior-derecho de la barra
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 6),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Material(
              color: Colors.transparent,
              child: _PanelFiltros(
                onCerrar: _cerrarPanel,
                onNavegar: widget.onFiltrosAplicados,
                maxHeight: panelMaxHeight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _controller,
                onChanged: (texto) {
                  // Si el usuario borró todo el texto del buscador principal
                  if (texto.trim().isEmpty) {
                    widget.onBuscar(''); 
                  }
                },
                onSubmitted: (v) {
                  _cerrarPanel();
                  widget.onBuscar(v);
                },
                style:
                    const TextStyle(color: Colors.black87, fontSize: 13),
                cursorColor: Colors.black54,
                decoration: InputDecoration(
                  hintText:
                      'Escribe un destino, experiencia o servicio...',
                  hintStyle: const TextStyle(
                      color: Colors.black38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search,
                      color: Colors.black38, size: 18),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.amarillo),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            height: 42,
            child: ElevatedButton(
              key: _buttonKey,
              onPressed: _togglePanel,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _abierto ? AppColors.amarillo : Colors.white,
                foregroundColor:
                    _abierto ? Colors.black : Colors.black54,
                elevation: 0,
                padding: EdgeInsets.zero,
                minimumSize: const Size(42, 42),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Icon(Icons.tune, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Panel de filtros — StatefulWidget independiente.
// Los selectores de Estado/Municipio son listas INLINE (sin overlay) para
// que no aparezcan detrás del panel por conflictos de z-order.
// ============================================================================

class _PanelFiltros extends StatefulWidget {
  final VoidCallback onCerrar;
  final VoidCallback? onNavegar;
  final double maxHeight;
  const _PanelFiltros({
    required this.onCerrar,
    this.onNavegar,
    required this.maxHeight,
  });

  @override
  State<_PanelFiltros> createState() => _PanelFiltrosState();
}

class _PanelFiltrosState extends State<_PanelFiltros> {
  final _presupuestoCtrl = TextEditingController();

  // Estado de los selectores inline
  bool _estadoExpandido = false;
  bool _municipioExpandido = false;
  bool _fechaExpandida = false;

  // Filtros locales
  final Set<String> _tipos = {};
  bool _conTransporte = false;

  static const _tiposAlojamiento = [
    'Posada',
    'Camping',
    'Hotel',
    'Apartamento',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = context.read<CatalogController>();
      if (c.presupuestoMaximo != null && c.presupuestoMaximo! > 0) {
        _presupuestoCtrl.text = c.presupuestoMaximo!.toStringAsFixed(0);
      }
      setState(() {
        _tipos
          ..clear()
          ..addAll(c.tiposAlojamiento);
        _conTransporte = c.conTransporte == true;
      });
    });
  }

  @override
  void dispose() {
    _presupuestoCtrl.dispose();
    super.dispose();
  }

// ── Acciones ─────────────────────────────────────────────────────────────

  void _buscar() {
    final catalogo = context.read<CatalogController>();
    catalogo.actualizarPresupuesto(_presupuestoCtrl.text);
    catalogo.actualizarTiposAlojamiento(_tipos);
    catalogo.actualizarTransporte(_conTransporte ? true : null);
    catalogo.buscar(); // Esto ya ejecuta notifyListeners()
    widget.onCerrar(); // Cierra el overlay flotante de filtros
    // widget.onNavegar?.call(); <-- ELIMINADO para evitar navegación reactiva externa
  }

  void _limpiar() {
    _presupuestoCtrl.clear();
    setState(() {
      _tipos.clear();
      _conTransporte = false;
      _estadoExpandido = false;
      _municipioExpandido = false;
      _fechaExpandida = false;
    });
    
    // Limpia también el estado en el controller global y restaura los servicios
    final catalogo = context.read<CatalogController>();
    catalogo.limpiarFiltros();
    
    widget.onCerrar(); // Cierra el overlay
    // widget.onNavegar?.call(); <-- ELIMINADO para que se restaure en la misma pantalla
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final catalogo = context.watch<CatalogController>();
    final fechaTxt = catalogo.fecha != null
        ? DateFormat('dd/MM/yyyy').format(catalogo.fecha!)
        : null;

    return Container(
      width: 300,
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      decoration: BoxDecoration(
        color: AppColors.verde,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Colors.black45, blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── UBICACIÓN ────────────────────────────────────────────
            _titulo('Ubicación'),
            const SizedBox(height: 8),
            _selectorInline(
              icono: Icons.map_outlined,
              valor: catalogo.estado,
              placeholder: 'Todos los estados',
              expandido: _estadoExpandido,
              onToggle: () => setState(() {
                _estadoExpandido = !_estadoExpandido;
                _municipioExpandido = false;
              }),
              opciones: VenezuelaGeo.estados,
              opcionTodos: 'Todos los estados',
              onSeleccionar: (e) {
                setState(() => _estadoExpandido = false);
                context
                    .read<CatalogController>()
                    .actualizarUbicacion(e, null);
              },
            ),
            const SizedBox(height: 8),
            _selectorInline(
              icono: Icons.location_city_outlined,
              valor: catalogo.municipio,
              placeholder: catalogo.estado == null
                  ? 'Elige un estado primero'
                  : 'Todos los municipios',
              expandido: _municipioExpandido,
              habilitado: catalogo.estado != null,
              onToggle: () => setState(() {
                _municipioExpandido = !_municipioExpandido;
                _estadoExpandido = false;
              }),
              opciones: catalogo.estado != null
                  ? VenezuelaGeo.municipiosDe(catalogo.estado)
                  : const [],
              opcionTodos: 'Todos los municipios',
              onSeleccionar: (m) {
                setState(() => _municipioExpandido = false);
                context
                    .read<CatalogController>()
                    .actualizarUbicacion(catalogo.estado, m);
              },
            ),

            // ── FECHA ────────────────────────────────────────────────
            const SizedBox(height: 14),
            _titulo('Fecha'),
            const SizedBox(height: 8),
            // Cabecera: muestra la fecha seleccionada y permite expandir
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        setState(() => _fechaExpandida = !_fechaExpandida),
                    borderRadius: BorderRadius.circular(8),
                    child: _campoIcono(
                      icono: Icons.calendar_today_outlined,
                      texto: fechaTxt ?? 'Cualquier fecha',
                      activo: fechaTxt != null,
                      sufijo: Icon(
                        _fechaExpandida
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppColors.verdeClaro,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (catalogo.fecha != null) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      setState(() => _fechaExpandida = false);
                      context
                          .read<CatalogController>()
                          .actualizarFecha(null);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.close,
                          color: AppColors.verdeClaro, size: 16),
                    ),
                  ),
                ],
              ],
            ),
            // Calendario inline — sin overlay, sin conflictos de z-order
            if (_fechaExpandida)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.verdeOscuro.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.verdeClaro.withValues(alpha: 0.3)),
                ),
                child: Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.dark(
                      primary: AppColors.amarillo,
                      onPrimary: Colors.black,
                      surface: AppColors.verdeOscuro,
                      onSurface: AppColors.blanco,
                      secondary: AppColors.amarillo,
                      surfaceContainerHighest:
                          AppColors.verdeClaro.withValues(alpha: 0.2),
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: catalogo.fecha ??
                        DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                    onDateChanged: (fecha) {
                      setState(() => _fechaExpandida = false);
                      context
                          .read<CatalogController>()
                          .actualizarFecha(fecha);
                    },
                  ),
                ),
              ),

            // ── PRESUPUESTO ──────────────────────────────────────────
            const SizedBox(height: 14),
            _titulo('Presupuesto máximo'),
            const SizedBox(height: 8),
            TextField(
              controller: _presupuestoCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style:
                  const TextStyle(color: AppColors.blanco, fontSize: 13),
              cursorColor: AppColors.amarillo,
              decoration: InputDecoration(
                hintText: 'Ej: 150',
                hintStyle: TextStyle(
                    color: AppColors.verdeClaro.withValues(alpha: 0.7),
                    fontSize: 13),
                prefixIcon: const Icon(Icons.attach_money_outlined,
                    color: AppColors.verdeClaro, size: 18),
                suffixText: 'USD',
                suffixStyle: const TextStyle(
                    color: AppColors.verdeClaro, fontSize: 12),
                filled: true,
                fillColor: AppColors.verdeOscuro.withValues(alpha: 0.45),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: AppColors.verdeClaro.withValues(alpha: 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.amarillo),
                ),
              ),
            ),

            // ── TIPOS DE ALOJAMIENTO ─────────────────────────────────
            const SizedBox(height: 16),
            _titulo('Tipos de Alojamiento'),
            const SizedBox(height: 6),
            ..._tiposAlojamiento.map(_checkboxTipo),

            // ── TRANSPORTE ───────────────────────────────────────────
            const SizedBox(height: 8),
            _checkboxItem(
              'Transporte incluido',
              _conTransporte,
              () => setState(() => _conTransporte = !_conTransporte),
            ),

            // ── BOTONES ──────────────────────────────────────────────
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _buscar,
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Buscar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amarillo,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _limpiar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.verdeClaro,
                    side: BorderSide(
                        color: AppColors.verdeClaro
                            .withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('Limpiar'),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  // ── Selector inline (sin overlay) ────────────────────────────────────────

  Widget _selectorInline({
    required IconData icono,
    required String? valor,
    required String placeholder,
    required bool expandido,
    required VoidCallback onToggle,
    required List<String> opciones,
    required String opcionTodos,
    required void Function(String? valor) onSeleccionar,
    bool habilitado = true,
  }) {
    final color = habilitado ? AppColors.verdeClaro : AppColors.verdeClaro.withValues(alpha: 0.4);
    return Column(
      children: [
        // Cabecera del selector
        InkWell(
          onTap: habilitado ? onToggle : null,
          borderRadius: BorderRadius.circular(8),
          child: _campoIcono(
            icono: icono,
            texto: valor ?? placeholder,
            activo: valor != null,
            sufijo: habilitado
                ? Icon(
                    expandido ? Icons.expand_less : Icons.expand_more,
                    color: color,
                    size: 18,
                  )
                : null,
          ),
        ),
        // Lista desplegable inline
        if (expandido)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              color: AppColors.verdeOscuro,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.verdeClaro.withValues(alpha: 0.3)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Opción "Todos"
                  _opcionLista(opcionTodos, valor == null, () => onSeleccionar(null)),
                  ...opciones.map((op) =>
                      _opcionLista(op, op == valor, () => onSeleccionar(op))),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _opcionLista(String texto, bool seleccionado, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.amarillo.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
                color: AppColors.verdeClaro.withValues(alpha: 0.1)),
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: seleccionado ? AppColors.amarillo : AppColors.blanco,
            fontSize: 13,
            fontWeight:
                seleccionado ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Widgets auxiliares ───────────────────────────────────────────────────

  Widget _titulo(String texto) => Text(
        texto,
        style: const TextStyle(
            color: AppColors.blanco,
            fontSize: 13,
            fontWeight: FontWeight.w700),
      );

  Widget _campoIcono({
    required IconData icono,
    required String texto,
    required bool activo,
    Widget? sufijo,
  }) =>
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.verdeOscuro.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppColors.verdeClaro.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icono, color: AppColors.verdeClaro, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  color: activo ? AppColors.blanco : AppColors.verdeClaro,
                  fontSize: 13,
                ),
              ),
            ),
            ?sufijo,
          ],
        ),
      );

  Widget _checkboxTipo(String tipo) => _checkboxItem(
        tipo,
        _tipos.contains(tipo),
        () => setState(() => _tipos.contains(tipo)
            ? _tipos.remove(tipo)
            : _tipos.add(tipo)),
      );

  Widget _checkboxItem(String label, bool activo, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              _cuadroCheck(activo),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.blanco, fontSize: 13)),
            ],
          ),
        ),
      );

  Widget _cuadroCheck(bool activo) => Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: activo ? AppColors.amarillo : Colors.transparent,
          border: Border.all(
            color: activo ? AppColors.amarillo : AppColors.verdeClaro,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: activo
            ? const Icon(Icons.check, size: 12, color: Colors.black)
            : null,
      );
}
