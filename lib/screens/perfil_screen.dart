import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'auth/login_screen.dart';

// =====================================================================
// PALETA DE COLORES TEQUANI
// =====================================================================
const Color obsidianBlack = Color(0xFF14110F); 
const Color deepJadeGreen = Color(0xFF1B4D3E); 
const Color tezontleRed   = Color(0xFF7A1C1C); 
const Color ochreGold     = Color(0xFFC29B38); 
const Color amatePaper    = Color(0xFFE5D4C0); 

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _cargandoPerfil = true;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Uint8List? _fotoPerfilBytes;
  String _nombreUsuario = 'Gonzalo_Guerrero';
  String _tituloGuerrero = 'Portador de la Espada de Hielo';
  String _biografia = 'Explorando el Templo de Obsidiana y buscando estrategias para el jefe final.';
  bool _notificacionesActivas = true;
  bool _efectoEscarchaActivo = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosDesdeFirestore();
  }

  Future<void> _cargarDatosDesdeFirestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _cargandoPerfil = false);
      return;
    }

    try {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _nombreUsuario = (data['nombre'] ?? user.email?.split('@').first ?? 'Guerrero').toString();
        _tituloGuerrero = (data['titulo'] ?? 'Portador de la Espada de Hielo').toString();
        _biografia = (data['biografia'] ?? 'Explorando el Templo de Obsidiana.').toString();
        _notificacionesActivas = data['notificaciones'] ?? true;
        _efectoEscarchaActivo = data['escarcha'] ?? true;

        if (data['fotoBase64'] != null && data['fotoBase64'].toString().isNotEmpty) {
          _fotoPerfilBytes = base64Decode(data['fotoBase64'].toString());
        }
      } else {
        _nombreUsuario = user.email?.split('@').first ?? 'Gonzalo_Guerrero';
        await _guardarEnFirestore();
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _cargandoPerfil = false);
    }
  }

  Future<void> _guardarEnFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('usuarios').doc(user.uid).set({
      'nombre': _nombreUsuario,
      'titulo': _tituloGuerrero,
      'biografia': _biografia,
      'notificaciones': _notificacionesActivas,
      'escarcha': _efectoEscarchaActivo,
      'fotoBase64': _fotoPerfilBytes != null ? base64Encode(_fotoPerfilBytes!) : null,
      'email': user.email,
      'actualizado': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _cambiarFotoPerfil() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      imageQuality: 65,
    );
    if (imagen != null) {
      final bytes = await imagen.readAsBytes();
      setState(() {
        _fotoPerfilBytes = bytes;
      });
      await _guardarEnFirestore();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Foto de perfil sincronizada en Firebase!'),
            backgroundColor: deepJadeGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _mostrarModalEditarPerfil() {
    final nombreCtrl = TextEditingController(text: _nombreUsuario);
    final tituloCtrl = TextEditingController(text: _tituloGuerrero);
    final bioCtrl = TextEditingController(text: _biografia);

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personalizar Guerrero (Sincronizado)',
                style: TextStyle(color: ochreGold, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nombreCtrl,
                style: const TextStyle(color: amatePaper),
                decoration: InputDecoration(
                  labelText: 'Nombre de Jugador',
                  labelStyle: const TextStyle(color: ochreGold),
                  prefixIcon: const Icon(Icons.person_outline, color: ochreGold),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: deepJadeGreen),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: ochreGold),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tituloCtrl,
                style: const TextStyle(color: amatePaper),
                decoration: InputDecoration(
                  labelText: 'Título / Rango en Tequani',
                  labelStyle: const TextStyle(color: ochreGold),
                  prefixIcon: const Icon(Icons.military_tech, color: ochreGold),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: deepJadeGreen),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: ochreGold),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioCtrl,
                maxLines: 2,
                style: const TextStyle(color: amatePaper),
                decoration: InputDecoration(
                  labelText: 'Estado / Biografía',
                  labelStyle: const TextStyle(color: ochreGold),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: deepJadeGreen),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: ochreGold),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar', style: TextStyle(color: amatePaper)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tezontleRed,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () async {
                      setState(() {
                        if (nombreCtrl.text.trim().isNotEmpty) {
                          _nombreUsuario = nombreCtrl.text.trim();
                        }
                        if (tituloCtrl.text.trim().isNotEmpty) {
                          _tituloGuerrero = tituloCtrl.text.trim();
                        }
                        if (bioCtrl.text.trim().isNotEmpty) {
                          _biografia = bioCtrl.text.trim();
                        }
                      });
                      Navigator.pop(context);
                      await _guardarEnFirestore();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perfil guardado en Cloud Firestore'),
                            backgroundColor: deepJadeGreen,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.cloud_upload, color: amatePaper, size: 18),
                    label: const Text('Guardar en la Nube', style: TextStyle(color: amatePaper, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cerrarSesion() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final emailUsuario = _auth.currentUser?.email ?? 'guerrero@tequani.com';

    return Scaffold(
      backgroundColor: obsidianBlack,
      appBar: AppBar(
        title: const Text('Santuario del Jugador', style: TextStyle(color: ochreGold, fontWeight: FontWeight.bold)),
        backgroundColor: obsidianBlack,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Editar nombre y rango',
            icon: const Icon(Icons.edit_note, color: ochreGold),
            onPressed: _mostrarModalEditarPerfil,
          ),
        ],
      ),
      body: _cargandoPerfil
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ochreGold),
                  SizedBox(height: 16),
                  Text('Sincronizando perfil con Firebase...', style: TextStyle(color: amatePaper)),
                ],
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.all(18),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [deepJadeGreen, obsidianBlack],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ochreGold.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GestureDetector(
                            onTap: _cambiarFotoPerfil,
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: ochreGold,
                              child: CircleAvatar(
                                radius: 51,
                                backgroundColor: obsidianBlack,
                                backgroundImage: _fotoPerfilBytes != null ? MemoryImage(_fotoPerfilBytes!) : null,
                                child: _fotoPerfilBytes == null
                                    ? const Icon(Icons.person, size: 54, color: amatePaper)
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: tezontleRed,
                              padding: const EdgeInsets.all(8),
                            ),
                            icon: const Icon(Icons.camera_alt, color: amatePaper, size: 20),
                            onPressed: _cambiarFotoPerfil,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _nombreUsuario,
                        style: const TextStyle(color: ochreGold, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tituloGuerrero,
                        style: const TextStyle(color: amatePaper, fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        emailUsuario,
                        style: TextStyle(color: amatePaper.withValues(alpha: 0.6), fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _biografia,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: amatePaper.withValues(alpha: 0.9), fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: ochreGold),
                            ),
                            onPressed: _cambiarFotoPerfil,
                            icon: const Icon(Icons.photo_library_outlined, color: ochreGold, size: 18),
                            label: const Text('Cambiar Foto', style: TextStyle(color: ochreGold)),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tezontleRed,
                            ),
                            onPressed: _mostrarModalEditarPerfil,
                            icon: const Icon(Icons.edit, color: amatePaper, size: 18),
                            label: const Text('Editar Nombre', style: TextStyle(color: amatePaper)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Nivel', '14', Icons.bolt),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard('Jefes', '3 / 5', Icons.shield),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard('Armadura', 'Obsidiana', Icons.security),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Card(
                  color: deepJadeGreen.withValues(alpha: 0.22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: deepJadeGreen),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeColor: ochreGold,
                        secondary: const Icon(Icons.notifications_active, color: ochreGold),
                        title: const Text('Notificaciones de la Comunidad', style: TextStyle(color: amatePaper, fontSize: 14)),
                        subtitle: Text('Avisar cuando respondan tus dudas', style: TextStyle(color: amatePaper.withValues(alpha: 0.6), fontSize: 12)),
                        value: _notificacionesActivas,
                        onChanged: (val) {
                          setState(() => _notificacionesActivas = val);
                          _guardarEnFirestore();
                        },
                      ),
                      const Divider(color: deepJadeGreen, height: 1),
                      SwitchListTile(
                        activeColor: ochreGold,
                        secondary: const Icon(Icons.ac_unit, color: ochreGold),
                        title: const Text('Efectos de Partículas de Escarcha', style: TextStyle(color: amatePaper, fontSize: 14)),
                        subtitle: Text('Sincronizar con tu partida de Tequani', style: TextStyle(color: amatePaper.withValues(alpha: 0.6), fontSize: 12)),
                        value: _efectoEscarchaActivo,
                        onChanged: (val) {
                          setState(() => _efectoEscarchaActivo = val);
                          _guardarEnFirestore();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tezontleRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.logout, color: amatePaper),
                  label: const Text(
                    'CERRAR SESIÓN',
                    style: TextStyle(color: amatePaper, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String titulo, String valor, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: deepJadeGreen.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ochreGold.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Icon(icono, color: ochreGold, size: 24),
          const SizedBox(height: 6),
          Text(valor, style: const TextStyle(color: amatePaper, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(titulo, style: TextStyle(color: amatePaper.withValues(alpha: 0.7), fontSize: 11)),
        ],
      ),
    );
  }
}