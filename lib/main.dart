import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/kanban_board_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => KanbanBoardProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'TunTask - Jira Style Kanban Board',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme(themeProvider.primaryColor),
            darkTheme: AppTheme.darkTheme(themeProvider.primaryColor),
            home: const SplashScreenView(),
          );
        },
      ),
    );
  }
}
