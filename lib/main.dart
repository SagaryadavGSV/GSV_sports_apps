import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/match_provider.dart';
import 'screens/match_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const VolleyTrackerApp());
}

class VolleyTrackerApp extends StatelessWidget {
  const VolleyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchProvider(),
      child: MaterialApp(
        title: 'Volley Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const MatchScreen(),
      ),
    );
  }
}
