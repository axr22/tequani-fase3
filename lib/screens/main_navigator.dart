import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'noticias_screen.dart';
import 'perfil_screen.dart';

// =====================================================================
// PALETA DE COLORES TEQUANI
// =====================================================================
const Color obsidianBlack = Color(0xFF14110F); 
const Color deepJadeGreen = Color(0xFF1B4D3E); 
const Color tezontleRed   = Color(0xFF7A1C1C); 
const Color ochreGold     = Color(0xFFC29B38); 
const Color amatePaper    = Color(0xFFE5D4C0); 

// =====================================================================
// MODELO DE DATOS PARA LAS PUBLICACIONES DEL FORO
// =====================================================================
class PostForo {
  String usuario;
  String tiempo;
  String texto;
  Uint8List? imagenBytes;
  bool fotoDemo;
  int likes;
  int dislikes;
  bool likeDado;
  bool dislikeDado;
  List<String> comentarios;

  PostForo({
    required this.usuario,
    required this.tiempo,
    required this.texto,
    this.imagenBytes,
    this.fotoDemo = false,
    required this.likes,
    required this.dislikes,
    this.likeDado = false,
    this.dislikeDado = false,
    List<String>? comentarios,
  }) : comentarios = comentarios ?? [];
}

// =====================================================================
// CONTENEDOR PRINCIPAL (BARRA INFERIOR + MÓDULO DE INICIO INTEGRADO)
// =====================================================================
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  // Las 3 pantallas: Inicio (aquí mismo), Noticias y Perfil (en sus propios archivos)
  final List<Widget> _pantallas = const [
    InicioScreen(),
    NoticiasScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_currentIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: obsidianBlack,
        selectedItemColor: tezontleRed,
        unselectedItemColor: deepJadeGreen,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/inicio_btn.jpeg.jpeg', width: 26, height: 26),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/noticias_btn.jpeg.jpeg', width: 26, height: 26),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/perfil_btn.jpeg.jpeg', width: 26, height: 26),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// PANTALLA 1: INICIO / FORO (VIVE AQUÍ MISMO EN MAIN_NAVIGATOR)
// =====================================================================
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  bool _cargandoModulo = true;
  final ImagePicker _picker = ImagePicker();

  final List<PostForo> _publicaciones = [
    PostForo(
      usuario: 'Gonzalo_Gamer',
      tiempo: 'Hace 2 horas',
      texto: 'No puedo pasar al jefe del Templo de Obsidiana. ¡La espada de hielo no le hace nada! ¿Alguien sabe qué hacer? Les dejo captura.',
      fotoDemo: true,
      likes: 24,
      dislikes: 2,
      comentarios: [
        'Guerrero_Jaguar: Tienes que pegarle cuando su escudo cambie a color rojo.',
      ],
    ),
  ];

  final TextEditingController _mensajeController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _cargandoModulo = false);
      }
    });
  }

  Future<void> _recargarForo() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foro actualizado al 100%'),
          backgroundColor: deepJadeGreen,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _toggleLike(int index) {
    setState(() {
      final post = _publicaciones[index];
      if (post.likeDado) {
        post.likeDado = false;
        post.likes -= 1;
      } else {
        post.likeDado = true;
        post.likes += 1;
        if (post.dislikeDado) {
          post.dislikeDado = false;
          post.dislikes -= 1;
        }
      }
    });
  }

  void _toggleDislike(int index) {
    setState(() {
      final post = _publicaciones[index];
      if (post.dislikeDado) {
        post.dislikeDado = false;
        post.dislikes -= 1;
      } else {
        post.dislikeDado = true;
        post.dislikes += 1;
        if (post.likeDado) {
          post.likeDado = false;
          post.likes -= 1;
        }
      }
    });
  }

  void _mostrarModalComentarios(int index) {
    final post = _publicaciones[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: obsidianBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Comentarios de la Comunidad', style: TextStyle(color: ochreGold, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (post.comentarios.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Aún no hay comentarios. ¡Sé el primero en ayudar!', style: TextStyle(color: amatePaper)),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: post.comentarios.length,
                        itemBuilder: (context, cIndex) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: deepJadeGreen.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: deepJadeGreen),
                            ),
                            child: Text(post.comentarios[cIndex], style: const TextStyle(color: amatePaper, fontSize: 13)),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _comentarioController,
                          style: const TextStyle(color: amatePaper),
                          decoration: InputDecoration(
                            hintText: 'Escribe tu respuesta...',
                            hintStyle: TextStyle(color: amatePaper.withValues(alpha: 0.5)),
                            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: deepJadeGreen), borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: ochreGold), borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: tezontleRed, padding: const EdgeInsets.all(14)),
                        icon: const Icon(Icons.send, color: amatePaper),
                        onPressed: () {
                          if (_comentarioController.text.isNotEmpty) {
                            setState(() {
                              post.comentarios.add('Tú: ${_comentarioController.text}');
                            });
                            setModalState(() {});
                            _comentarioController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarModalPublicar() {
    Uint8List? fotoSeleccionadaBytes;

    showModalBottomSheet(
      context: context,
      backgroundColor: obsidianBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Crear Publicación', style: TextStyle(color: ochreGold, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _mensajeController,
                    maxLines: 4,
                    style: const TextStyle(color: amatePaper),
                    decoration: InputDecoration(
                      hintText: '¿En qué jefe te atoraste o qué secreto descubriste?',
                      hintStyle: TextStyle(color: amatePaper.withValues(alpha: 0.5)),
                      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: deepJadeGreen), borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: ochreGold), borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (fotoSeleccionadaBytes != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ochreGold),
                            image: DecorationImage(
                              image: MemoryImage(fotoSeleccionadaBytes!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        IconButton(
                          style: IconButton.styleFrom(backgroundColor: obsidianBlack.withValues(alpha: 0.8)),
                          icon: const Icon(Icons.close, color: tezontleRed, size: 20),
                          onPressed: () => setModalState(() => fotoSeleccionadaBytes = null),
                        ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
                          if (imagen != null) {
                            final bytes = await imagen.readAsBytes();
                            setModalState(() {
                              fotoSeleccionadaBytes = bytes;
                            });
                          }
                        },
                        icon: const Icon(Icons.add_photo_alternate, color: ochreGold),
                        label: Text(
                          fotoSeleccionadaBytes != null ? 'Cambiar foto' : 'Elegir de galería',
                          style: const TextStyle(color: ochreGold, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tezontleRed,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          if (_mensajeController.text.isNotEmpty || fotoSeleccionadaBytes != null) {
                            setState(() {
                              _publicaciones.insert(
                                0,
                                PostForo(
                                  usuario: 'Tú (Guerrero Tequani)',
                                  tiempo: 'Justo ahora',
                                  texto: _mensajeController.text.isEmpty ? 'Compartió una captura de pantalla.' : _mensajeController.text,
                                  imagenBytes: fotoSeleccionadaBytes,
                                  likes: 0,
                                  dislikes: 0,
                                ),
                              );
                            });
                            _mensajeController.clear();
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.publish, color: amatePaper, size: 18),
                        label: const Text('Publicar', style: TextStyle(color: amatePaper, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBlack,
      appBar: AppBar(
        title: const Text('Comunidad Tequani', style: TextStyle(color: ochreGold, fontWeight: FontWeight.bold)),
        backgroundColor: obsidianBlack,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Recargar foro',
            icon: const Icon(Icons.refresh, color: ochreGold),
            onPressed: () {
              setState(() => _cargandoModulo = true);
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) setState(() => _cargandoModulo = false);
              });
            },
          ),
        ],
      ),
      body: _cargandoModulo
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ochreGold),
                  SizedBox(height: 16),
                  Text('Cargando pergaminos del foro...', style: TextStyle(color: amatePaper)),
                ],
              ),
            )
          : RefreshIndicator(
              color: ochreGold,
              backgroundColor: obsidianBlack,
              onRefresh: _recargarForo,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(12),
                itemCount: _publicaciones.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return TweenAnimationBuilder<double>(
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
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [deepJadeGreen, obsidianBlack],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ochreGold.withValues(alpha: 0.4), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_awesome, color: ochreGold, size: 22),
                                SizedBox(width: 8),
                                Text('¡Bienvenido a Tequani!', style: TextStyle(color: ochreGold, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Comparte tus capturas de pantalla, pregunta cómo vencer a los guardianes de obsidiana y ayuda a otros guerreros.',
                              style: TextStyle(color: amatePaper.withValues(alpha: 0.9), fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final postIndex = index - 1;
                  final post = _publicaciones[postIndex];

                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (postIndex * 100)),
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
                      color: deepJadeGreen.withValues(alpha: 0.25),
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: deepJadeGreen, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: post.usuario.contains('Tú') ? ochreGold : tezontleRed,
                                  child: Icon(Icons.person, color: post.usuario.contains('Tú') ? obsidianBlack : amatePaper),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(post.usuario, style: const TextStyle(color: ochreGold, fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text(post.tiempo, style: TextStyle(color: amatePaper.withValues(alpha: 0.7), fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(post.texto, style: const TextStyle(color: amatePaper, fontSize: 15, height: 1.3)),
                            const SizedBox(height: 12),
                            
                            if (post.imagenBytes != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  post.imagenBytes!,
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ] else if (post.fotoDemo) ...[
                              Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: obsidianBlack,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: ochreGold.withValues(alpha: 0.4)),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shield_moon, color: tezontleRed, size: 48),
                                    SizedBox(height: 8),
                                    Text('Captura: Jefe Templo de Obsidiana', style: TextStyle(color: ochreGold, fontSize: 13)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            const Divider(color: deepJadeGreen),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _toggleLike(postIndex),
                                  icon: Icon(
                                    post.likeDado ? Icons.thumb_up : Icons.thumb_up_alt_outlined, 
                                    color: post.likeDado ? tezontleRed : amatePaper, 
                                    size: 20,
                                  ),
                                  label: Text('${post.likes}', style: TextStyle(color: post.likeDado ? tezontleRed : amatePaper)),
                                ),
                                TextButton.icon(
                                  onPressed: () => _toggleDislike(postIndex),
                                  icon: Icon(
                                    post.dislikeDado ? Icons.thumb_down : Icons.thumb_down_alt_outlined, 
                                    color: post.dislikeDado ? ochreGold : amatePaper, 
                                    size: 20,
                                  ),
                                  label: Text('${post.dislikes}', style: TextStyle(color: post.dislikeDado ? ochreGold : amatePaper)),
                                ),
                                TextButton.icon(
                                  onPressed: () => _mostrarModalComentarios(postIndex),
                                  icon: const Icon(Icons.chat_bubble_outline, color: amatePaper, size: 20),
                                  label: Text('Comentar (${post.comentarios.length})', style: const TextStyle(color: amatePaper)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: tezontleRed,
        onPressed: _mostrarModalPublicar,
        icon: const Icon(Icons.add_a_photo, color: amatePaper),
        label: const Text('Publicar', style: TextStyle(color: amatePaper, fontWeight: FontWeight.bold)),
      ),
    );
  }
}