import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
// CONTENEDOR PRINCIPAL (BARRA INFERIOR + MÓDULO DE INICIO INTEGRADO)
// =====================================================================
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

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
            icon: Image.asset('assets/inicio.png', width: 26, height: 26),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/foro.png', width: 26, height: 26),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/perfil.png', width: 26, height: 26),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// PANTALLA 1: INICIO / FORO CONECTADO A CLOUD FIRESTORE (FASE 5)
// =====================================================================
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _mensajeController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verificarSemillaInicial();
  }

  // Si la base de datos está vacía, crea el primer post automáticamente
  Future<void> _verificarSemillaInicial() async {
    try {
      final snapshot = await _firestore.collection('publicaciones').limit(1).get();
      if (snapshot.docs.isEmpty) {
        await _firestore.collection('publicaciones').add({
          'uid': 'sistema',
          'usuario': 'Gonzalo_Gamer',
          'texto': 'No puedo pasar al jefe del Templo de Obsidiana. ¡La espada de hielo no le hace nada! ¿Alguien sabe qué hacer? Les dejo captura.',
          'imagenBase64': null,
          'fotoDemo': true,
          'likesUids': <String>['demo1', 'demo2'],
          'dislikesUids': <String>[],
          'comentarios': <String>[
            'Guerrero_Jaguar: Tienes que pegarle cuando su escudo cambie a color rojo.',
          ],
          'fecha': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {}
  }

  Future<String> _obtenerNombreActual() async {
    final user = _auth.currentUser;
    if (user == null) return 'Guerrero_Tequani';
    try {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists && doc.data()?['nombre'] != null) {
        return doc.data()!['nombre'].toString();
      }
    } catch (_) {}
    return user.email?.split('@').first ?? 'Guerrero_Tequani';
  }

  Future<void> _toggleLike(String docId, List<dynamic> likesUids, List<dynamic> dislikesUids) async {
    final uid = _auth.currentUser?.uid ?? 'invitado';
    final docRef = _firestore.collection('publicaciones').doc(docId);

    if (likesUids.contains(uid)) {
      await docRef.update({
        'likesUids': FieldValue.arrayRemove([uid]),
      });
    } else {
      await docRef.update({
        'likesUids': FieldValue.arrayUnion([uid]),
        'dislikesUids': FieldValue.arrayRemove([uid]),
      });
    }
  }

  Future<void> _toggleDislike(String docId, List<dynamic> likesUids, List<dynamic> dislikesUids) async {
    final uid = _auth.currentUser?.uid ?? 'invitado';
    final docRef = _firestore.collection('publicaciones').doc(docId);

    if (dislikesUids.contains(uid)) {
      await docRef.update({
        'dislikesUids': FieldValue.arrayRemove([uid]),
      });
    } else {
      await docRef.update({
        'dislikesUids': FieldValue.arrayUnion([uid]),
        'likesUids': FieldValue.arrayRemove([uid]),
      });
    }
  }

  Future<void> _eliminarPublicacion(String docId) async {
    await _firestore.collection('publicaciones').doc(docId).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicación eliminada de la nube'),
          backgroundColor: tezontleRed,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _mostrarModalComentarios(String docId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: obsidianBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('publicaciones').doc(docId).snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final List<dynamic> comentarios = data?['comentarios'] ?? [];

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Comentarios en Tiempo Real', style: TextStyle(color: ochreGold, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (comentarios.isEmpty)
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
                        itemCount: comentarios.length,
                        itemBuilder: (context, cIndex) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: deepJadeGreen.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: deepJadeGreen),
                            ),
                            child: Text(comentarios[cIndex].toString(), style: const TextStyle(color: amatePaper, fontSize: 13)),
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
                        onPressed: () async {
                          final texto = _comentarioController.text.trim();
                          if (texto.isNotEmpty) {
                            _comentarioController.clear();
                            final autor = await _obtenerNombreActual();
                            await _firestore.collection('publicaciones').doc(docId).update({
                              'comentarios': FieldValue.arrayUnion(['$autor: $texto']),
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _mostrarModalPublicar() {
    Uint8List? fotoSeleccionadaBytes;
    bool subiendoPost = false;

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
                  const Text('Crear Publicación en la Nube', style: TextStyle(color: ochreGold, fontSize: 18, fontWeight: FontWeight.bold)),
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
                          // Compresión automática para que se guarde al instante en Firestore
                          final XFile? imagen = await _picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 700,
                            imageQuality: 65,
                          );
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
                      subiendoPost
                          ? const Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: ochreGold, strokeWidth: 2.5),
                              ),
                            )
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: tezontleRed,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              onPressed: () async {
                                if (_mensajeController.text.trim().isNotEmpty || fotoSeleccionadaBytes != null) {
                                  setModalState(() => subiendoPost = true);
                                  final autor = await _obtenerNombreActual();
                                  final uid = _auth.currentUser?.uid ?? 'invitado';
                                  final String? base64Img = fotoSeleccionadaBytes != null
                                      ? base64Encode(fotoSeleccionadaBytes!)
                                      : null;

                                  await _firestore.collection('publicaciones').add({
                                    'uid': uid,
                                    'usuario': autor,
                                    'texto': _mensajeController.text.trim().isEmpty
                                        ? 'Compartió una captura de pantalla.'
                                        : _mensajeController.text.trim(),
                                    'imagenBase64': base64Img,
                                    'fotoDemo': false,
                                    'likesUids': <String>[],
                                    'dislikesUids': <String>[],
                                    'comentarios': <String>[],
                                    'fecha': FieldValue.serverTimestamp(),
                                  });

                                  _mensajeController.clear();
                                  if (context.mounted) Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.cloud_upload, color: amatePaper, size: 18),
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

  String _formatearFecha(Timestamp? timestamp) {
    if (timestamp == null) return 'Sincronizando...';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 1) return 'Justo ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    final miUid = _auth.currentUser?.uid ?? 'invitado';

    return Scaffold(
      backgroundColor: obsidianBlack,
      appBar: AppBar(
        title: const Text('Comunidad Tequani', style: TextStyle(color: ochreGold, fontWeight: FontWeight.bold)),
        backgroundColor: obsidianBlack,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Estado de conexión Firebase',
            icon: const Icon(Icons.cloud_done, color: ochreGold),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conectado en tiempo real con Cloud Firestore'),
                  backgroundColor: deepJadeGreen,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('publicaciones').orderBy('fecha', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ochreGold),
                  SizedBox(height: 16),
                  Text('Sincronizando pergaminos desde Firebase...', style: TextStyle(color: amatePaper)),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.all(12),
            itemCount: docs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
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
                        'Foro conectado en vivo a la nube. Tus publicaciones, capturas, likes y comentarios se sincronizan al instante con todos los jugadores.',
                        style: TextStyle(color: amatePaper.withValues(alpha: 0.9), fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                );
              }

              final doc = docs[index - 1];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              final String usuario = (data['usuario'] ?? 'Guerrero').toString();
              final String texto = (data['texto'] ?? '').toString();
              final String? imagenBase64 = data['imagenBase64'] as String?;
              final bool fotoDemo = data['fotoDemo'] == true;
              final List<dynamic> likesUids = data['likesUids'] ?? [];
              final List<dynamic> dislikesUids = data['dislikesUids'] ?? [];
              final List<dynamic> comentarios = data['comentarios'] ?? [];
              final Timestamp? fecha = data['fecha'] as Timestamp?;
              final bool esMio = data['uid'] == miUid;

              final bool likeDado = likesUids.contains(miUid);
              final bool dislikeDado = dislikesUids.contains(miUid);

              Uint8List? bytesDecodificados;
              if (imagenBase64 != null && imagenBase64.isNotEmpty) {
                try {
                  bytesDecodificados = base64Decode(imagenBase64);
                } catch (_) {}
              }

              return Card(
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
                            backgroundColor: esMio ? ochreGold : tezontleRed,
                            child: Icon(Icons.person, color: esMio ? obsidianBlack : amatePaper),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(usuario, style: const TextStyle(color: ochreGold, fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(_formatearFecha(fecha), style: TextStyle(color: amatePaper.withValues(alpha: 0.7), fontSize: 12)),
                              ],
                            ),
                          ),
                          if (esMio)
                            IconButton(
                              tooltip: 'Borrar mi publicación',
                              icon: const Icon(Icons.delete_outline, color: tezontleRed, size: 20),
                              onPressed: () => _eliminarPublicacion(docId),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(texto, style: const TextStyle(color: amatePaper, fontSize: 15, height: 1.3)),
                      const SizedBox(height: 12),

                      if (bytesDecodificados != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            bytesDecodificados,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ] else if (fotoDemo) ...[
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
                            onPressed: () => _toggleLike(docId, likesUids, dislikesUids),
                            icon: Icon(
                              likeDado ? Icons.thumb_up : Icons.thumb_up_alt_outlined, 
                              color: likeDado ? tezontleRed : amatePaper, 
                              size: 20,
                            ),
                            label: Text('${likesUids.length}', style: TextStyle(color: likeDado ? tezontleRed : amatePaper)),
                          ),
                          TextButton.icon(
                            onPressed: () => _toggleDislike(docId, likesUids, dislikesUids),
                            icon: Icon(
                              dislikeDado ? Icons.thumb_down : Icons.thumb_down_alt_outlined, 
                              color: dislikeDado ? ochreGold : amatePaper, 
                              size: 20,
                            ),
                            label: Text('${dislikesUids.length}', style: TextStyle(color: dislikeDado ? ochreGold : amatePaper)),
                          ),
                          TextButton.icon(
                            onPressed: () => _mostrarModalComentarios(docId),
                            icon: const Icon(Icons.chat_bubble_outline, color: amatePaper, size: 20),
                            label: Text('Comentar (${comentarios.length})', style: const TextStyle(color: amatePaper)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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