import 'package:flutter/material.dart';

// =====================================================================
// PALETA DE COLORES TEQUANI
// =====================================================================
const Color obsidianBlack = Color(0xFF14110F); 
const Color deepJadeGreen = Color(0xFF1B4D3E); 
const Color tezontleRed   = Color(0xFF7A1C1C); 
const Color ochreGold     = Color(0xFFC29B38); 
const Color amatePaper    = Color(0xFFE5D4C0); 

class NoticiaItem {
  final String titulo;
  final String version;
  final String fecha;
  final String categoria;
  final String resumen;
  final List<String> detalles;
  final IconData icono;
  int likes;
  bool likeDado;
  bool guardado;
  bool expandido;

  NoticiaItem({
    required this.titulo,
    required this.version,
    required this.fecha,
    required this.categoria,
    required this.resumen,
    required this.detalles,
    required this.icono,
    required this.likes,
    this.likeDado = false,
    this.guardado = false,
    this.expandido = false,
  });
}

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});

  @override
  State<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  bool _cargandoNoticias = true;
  String _filtroActual = 'Todos';

  final List<String> _categorias = ['Todos', 'Parches', 'Eventos', 'Jefes'];

  final List<NoticiaItem> _noticias = [
    NoticiaItem(
      titulo: 'Equilibrio en el Templo de Obsidiana',
      version: 'Parche v1.0.2',
      fecha: 'Hace 3 horas',
      categoria: 'Parches',
      resumen: 'Ajustes críticos al daño elemental de Gonzalo y reducción de escudo en el guardián principal.',
      detalles: [
        '• Espada de acero con poder de hielo: +20% de daño de escarcha contra armaduras pesadas.',
        '• Las partículas de hielo ahora ralentizan los ataques del jefe un 15%.',
        '• Armadura de obsidiana: Se corrigió un bug donde el reflejo de daño no se activaba al bloquear.',
        '• Se redujo la vida base del Guardián del Templo en un 15%.',
      ],
      icono: Icons.ac_unit,
      likes: 48,
    ),
    NoticiaItem(
      titulo: 'Evento: Torneo de las Sombras',
      version: 'Evento Temporal',
      fecha: 'Hace 1 día',
      categoria: 'Eventos',
      resumen: 'Compite contra el reloj derrotando oleadas en la Arena Tezontle para desbloquear aspectos únicos.',
      detalles: [
        '• Disponible todo el fin de semana para todos los guerreros registrados.',
        '• Recompensa principal: Estandarte Dorado Ocre para tu perfil.',
        '• Doble de puntos de experiencia al usar ataques cargados con la espada de hielo.',
      ],
      icono: Icons.emoji_events,
      likes: 65,
    ),
    NoticiaItem(
      titulo: 'Nuevo Jefe: El Coloso de Jade',
      version: 'Expansión v1.1',
      fecha: 'Hace 3 días',
      categoria: 'Jefes',
      resumen: 'Un antiguo autómata ha despertado en las profundidades de la selva. Conoce sus patrones de ataque.',
      detalles: [
        '• Vulnerable únicamente a ataques rápidos en el núcleo del pecho.',
        '• Invoca pilares de jade que bloquean el desplazamiento lateral.',
        '• Derrotarlo otorga el fragmento ancestral para mejorar tu armadura.',
      ],
      icono: Icons.shield_moon,
      likes: 92,
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) {
        setState(() => _cargandoNoticias = false);
      }
    });
  }

  Future<void> _recargarNoticias() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Códice de actualizaciones sincronizado'),
          backgroundColor: deepJadeGreen,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final noticiasFiltradas = _filtroActual == 'Todos'
        ? _noticias
        : _noticias.where((n) => n.categoria == _filtroActual).toList();

    return Scaffold(
      backgroundColor: obsidianBlack,
      appBar: AppBar(
        title: const Text('Crónicas y Parches', style: TextStyle(color: ochreGold, fontWeight: FontWeight.bold)),
        backgroundColor: obsidianBlack,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Notificaciones de parche',
            icon: const Icon(Icons.notifications_active_outlined, color: ochreGold),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Alertas de parches activadas'),
                  backgroundColor: tezontleRed,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Actualizar noticias',
            icon: const Icon(Icons.sync, color: ochreGold),
            onPressed: () {
              setState(() => _cargandoNoticias = true);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) setState(() => _cargandoNoticias = false);
              });
            },
          ),
        ],
      ),
      body: _cargandoNoticias
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ochreGold),
                  SizedBox(height: 16),
                  Text('Descifrando notas del parche...', style: TextStyle(color: amatePaper)),
                ],
              ),
            )
          : RefreshIndicator(
              color: ochreGold,
              backgroundColor: obsidianBlack,
              onRefresh: _recargarNoticias,
              child: ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(14),
                children: [
                  // BANNER DESTACADO ANIMADO
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [tezontleRed, obsidianBlack],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ochreGold.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: ochreGold,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ACTUALIZACIÓN MAYOR',
                              style: TextStyle(color: obsidianBlack, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Temporada 1: El Despertar de Tequani',
                            style: TextStyle(color: amatePaper, fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Revisa los cambios de balance, mejoras en el motor de partículas de escarcha y los próximos torneos de la comunidad.',
                            style: TextStyle(color: amatePaper.withValues(alpha: 0.85), fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // BOTONES DE FILTRO POR CATEGORÍA
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _categorias.length,
                      itemBuilder: (context, index) {
                        final cat = _categorias[index];
                        final seleccionado = _filtroActual == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: seleccionado,
                            selectedColor: tezontleRed,
                            backgroundColor: deepJadeGreen.withValues(alpha: 0.3),
                            labelStyle: TextStyle(
                              color: seleccionado ? ochreGold : amatePaper,
                              fontWeight: FontWeight.bold,
                            ),
                            side: BorderSide(color: seleccionado ? ochreGold : deepJadeGreen),
                            onSelected: (_) {
                              setState(() => _filtroActual = cat);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // LISTA DE TARJETAS DE NOTICIAS CON ANIMACIÓN ESCALONADA
                  ...List.generate(noticiasFiltradas.length, (index) {
                    final item = noticiasFiltradas[index];
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 120)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        color: deepJadeGreen.withValues(alpha: 0.22),
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: item.expandido ? ochreGold : deepJadeGreen,
                            width: 1.2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: tezontleRed,
                                    child: Icon(item.icono, color: ochreGold, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.titulo,
                                          style: const TextStyle(color: ochreGold, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.version} • ${item.fecha}',
                                          style: TextStyle(color: amatePaper.withValues(alpha: 0.7), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Guardar nota',
                                    icon: Icon(
                                      item.guardado ? Icons.bookmark : Icons.bookmark_border,
                                      color: item.guardado ? ochreGold : amatePaper,
                                    ),
                                    onPressed: () {
                                      setState(() => item.guardado = !item.guardado);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.resumen,
                                style: const TextStyle(color: amatePaper, fontSize: 14, height: 1.35),
                              ),
                              // SECCIÓN EXPANDIBLE DE NOTAS DE PARCHE
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 250),
                                crossFadeState: item.expandido
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                firstChild: const SizedBox.shrink(),
                                secondChild: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: obsidianBlack.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: deepJadeGreen),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Detalles oficiales:',
                                        style: TextStyle(color: ochreGold, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 6),
                                      ...item.detalles.map(
                                        (d) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(d, style: const TextStyle(color: amatePaper, fontSize: 13, height: 1.3)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(color: deepJadeGreen),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        if (item.likeDado) {
                                          item.likeDado = false;
                                          item.likes -= 1;
                                        } else {
                                          item.likeDado = true;
                                          item.likes += 1;
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      item.likeDado ? Icons.favorite : Icons.favorite_border,
                                      color: item.likeDado ? tezontleRed : amatePaper,
                                      size: 20,
                                    ),
                                    label: Text(
                                      '${item.likes} útiles',
                                      style: TextStyle(color: item.likeDado ? ochreGold : amatePaper),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() => item.expandido = !item.expandido);
                                    },
                                    icon: Icon(
                                      item.expandido ? Icons.expand_less : Icons.expand_more,
                                      color: ochreGold,
                                    ),
                                    label: Text(
                                      item.expandido ? 'Ocultar notas' : 'Leer notas completas',
                                      style: const TextStyle(color: ochreGold, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}