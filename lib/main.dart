import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:handlecrash/domain/models/vehicle.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:camera/camera.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'presentation/providers.dart';
import 'presentation/auth/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Gemini
  final geminiKey = dotenv.env['GEMINI_API_KEY'];
  if (geminiKey != null && geminiKey.isNotEmpty) {
    Gemini.init(apiKey: geminiKey);
    debugPrint('Gemini inicializado correctamente');
  } else {
    debugPrint('GEMINI_API_KEY ausente; el chat de imagen se deshabilitará.');
  }

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(VehicleAdapter()); // Registers the VehicleAdapter for Hive
  final vehicleBox = await Hive.openBox<Vehicle>('vehicles');

  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    ProviderScope(
      overrides: [
        vehicleBoxProvider.overrideWithValue(vehicleBox),
      ],
      child: MyApp(camera: firstCamera),
    ),
  );
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HandleCrash',
      debugShowCheckedModeBanner: false, // Quita el banner de debug
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        
        // Color scheme oscuro moderno
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00D9FF), // Cyan vibrante
          secondary: const Color(0xFF7C4DFF), // Púrpura vibrante
          tertiary: const Color(0xFFFF6B9D), // Rosa vibrante
          surface: const Color(0xFF1A1A1A), // Gris oscuro para superficies
          surfaceContainer: const Color(0xFF242424), // Contenedores
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: const Color(0xFFE8E8E8),
          error: const Color(0xFFFF5252),
        ),
        
        scaffoldBackgroundColor: const Color(0xFF121212),
        
        // AppBar moderno
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFE8E8E8),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF00D9FF)),
        ),
        
        // Cards modernas
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A1A),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        // Bottom Navigation Bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: Color(0xFF00D9FF),
          unselectedItemColor: Color(0xFF6B6B6B),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
        ),
        
        // Botones elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D9FF),
            foregroundColor: Colors.black,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // Text buttons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00D9FF),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF242424),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          hintStyle: const TextStyle(color: Color(0xFF6B6B6B)),
        ),
        
        // FABs
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00D9FF),
          foregroundColor: Colors.black,
          elevation: 6,
        ),
        
        // Dividers
        dividerTheme: const DividerThemeData(
          color: Color(0xFF3A3A3A),
          thickness: 1,
        ),
        
        // Snackbars
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF242424),
          contentTextStyle: const TextStyle(color: Color(0xFFE8E8E8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: AuthWrapper(camera: camera),
    );
  }
}



