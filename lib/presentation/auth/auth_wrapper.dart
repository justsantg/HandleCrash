import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../providers.dart';
import 'login_page.dart';
import '../../homepage.dart';
import '../vehicle/vehicle_details_page.dart';
import '../../emergency.dart';
import '../../external_link.dart';
import '../camera/unified_camera_screen.dart';

class AuthWrapper extends ConsumerWidget {
  final CameraDescription camera;

  const AuthWrapper({super.key, required this.camera});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        // Usuario autenticado
        if (state.session != null) {
          return HomePage(camera: camera);
        }
        // Usuario no autenticado
        return const LoginPage();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00D9FF),
          ),
        ),
      ),
      error: (error, stack) => const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final CameraDescription camera;

  const HomePage({super.key, required this.camera});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      Homepage(onNavigate: (int index) => _onItemTapped(index)),
      UnifiedCameraScreen(camera: widget.camera),
      const VehicleDetailsPage(),
      const Emergency(),
      const ExternalLink(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded, size: 28),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_rounded),
              activeIcon: Icon(Icons.camera_alt_rounded, size: 28),
              label: 'Cámara',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_filled_rounded),
              activeIcon: Icon(Icons.directions_car_filled_rounded, size: 28),
              label: 'Vehículo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency_rounded),
              activeIcon: Icon(Icons.emergency_rounded, size: 28),
              label: 'Emergencia',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.link_rounded),
              activeIcon: Icon(Icons.link_rounded, size: 28),
              label: 'Enlaces',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
