import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const LubeApp());
}

class LubeApp extends StatelessWidget {
  const LubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color neonBlue = Color(0xFF00E5FF);
    const Color darkBg = Color(0xFF0B0E14);
    const Color darkSurface = Color(0xFF151921);

    return MaterialApp(
      title: 'Lube',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: neonBlue,
          secondary: const Color(0xFF00FFD4),
          surface: darkSurface,
          onPrimary: Colors.black,
        ),
        scaffoldBackgroundColor: darkBg,
        
        // Custom Typography
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
          titleLarge: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white70),
        ),

        // Modern Card Theme
        cardTheme: CardThemeData(
          color: darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: neonBlue.withAlpha((0.1 * 255).toInt()), width: 1),
          ),
        ),

        // Custom Input Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withAlpha((0.3 * 255).toInt()),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          floatingLabelStyle: const TextStyle(color: neonBlue),
          prefixIconColor: neonBlue.withAlpha((0.7 * 255).toInt()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withAlpha((0.1 * 255).toInt())),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withAlpha((0.05 * 255).toInt())),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: neonBlue, width: 2),
          ),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: neonBlue,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            elevation: 4,
            shadowColor: neonBlue.withAlpha((0.5 * 255).toInt()),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
        ),
      ),
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    
    // IF NOT SET, SET DEFAULT TO TRUE (OFFLINE MODE)
    if (!prefs.containsKey('is_local_mode')) {
      await prefs.setBool('is_local_mode', true);
    }

    final isLocal = prefs.getBool('is_local_mode') ?? true;
    
    if (isLocal) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
      return;
    }

    final userId = prefs.getInt('user_id');
    if (mounted) {
      if (userId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
