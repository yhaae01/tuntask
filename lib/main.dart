import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/kanban_board_provider.dart';
import 'views/splash_screen_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TunTaskApp());
}

class TunTaskApp extends StatelessWidget {
  const TunTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KanbanBoardProvider()),
      ],
      child: MaterialApp(
        title: 'TunTask - Jira Style Kanban Board',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0052CC),
            brightness: Brightness.light,
            primary: const Color(0xFF0052CC),
            surface: const Color(0xFFF4F5F7),
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F5F7),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF172B4D),
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          fontFamily: null, // Uses default clean system font
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0052CC),
            brightness: Brightness.dark,
            primary: const Color(0xFF4C9AFF),
            surface: const Color(0xFF0F172A),
          ),
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F172A),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        home: const SplashScreenView(),
      ),
    );
  }
}
