import 'package:flutter/material.dart';

// =====================================================================
// PALETA DE COLORES TEQUANI
// =====================================================================
const Color obsidianBlack = Color(0xFF14110F); 
const Color deepJadeGreen = Color(0xFF1B4D3E); 
const Color tezontleRed   = Color(0xFF7A1C1C); 
const Color ochreGold     = Color(0xFFC29B38); 
const Color amatePaper    = Color(0xFFE5D4C0); 

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
        // OJO: Quité el "const" de aquí para que acepte tus imágenes
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
// PANTALLA 1: FORO 
// =====================================================================

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBlack,
      appBar: AppBar(
        title: const Text('Foro de Tequani', style: TextStyle(color: ochreGold, fontWeight: FontWeight.bold)),
        backgroundColor: obsidianBlack,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 2, 
        itemBuilder: (context, index) {
          return Card(
            color: deepJadeGreen.withOpacity(0.3),
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: deepJadeGreen, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: tezontleRed,
                        child: Icon(Icons.person, color: amatePaper),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gonzalo_Gamer', style: TextStyle(color: ochreGold, fontWeight: FontWeight.bold)),
                            Text('Hace 2 horas', style: TextStyle(color: amatePaper, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No puedo pasar al jefe del Templo de Obsidiana. ¡La espada de hielo no le hace nada! ¿Alguien sabe qué hacer? Les dejo captura.',
                    style: TextStyle(color: amatePaper, fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: obsidianBlack,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ochreGold.withOpacity(0.5)),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, color: deepJadeGreen, size: 50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: deepJadeGreen),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {}, 
                        icon: const Icon(Icons.thumb_up_alt_outlined, color: amatePaper, size: 20),
                        label: const Text('24', style: TextStyle(color: amatePaper)),
                      ),
                      TextButton.icon(
                        onPressed: () {}, 
                        icon: const Icon(Icons.thumb_down_alt_outlined, color: amatePaper, size: 20),
                        label: const Text('2', style: TextStyle(color: amatePaper)),
                      ),
                      TextButton.icon(
                        onPressed: () {}, 
                        icon: const Icon(Icons.chat_bubble_outline, color: amatePaper, size: 20),
                        label: const Text('Comentar', style: TextStyle(color: amatePaper)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: tezontleRed,
        onPressed: () {},
        icon: const Icon(Icons.add, color: amatePaper),
        label: const Text('Publicar', style: TextStyle(color: amatePaper, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// =====================================================================
// PANTALLAS 2 Y 3 
// =====================================================================

class NoticiasScreen extends StatelessWidget {
  const NoticiasScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBlack,
      appBar: AppBar(title: const Text('Actualizaciones', style: TextStyle(color: ochreGold)), backgroundColor: obsidianBlack),
      body: const Center(child: Text('Aquí irán los Parches', style: TextStyle(color: amatePaper))),
    );
  }
}

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBlack,
      appBar: AppBar(title: const Text('Mi Perfil', style: TextStyle(color: ochreGold)), backgroundColor: obsidianBlack),
      body: const Center(child: Text('Aquí irá tu foto y datos', style: TextStyle(color: amatePaper))),
    );
  }
}