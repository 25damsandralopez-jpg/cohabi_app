import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/owner_account_created_screen.dart';

import 'core/theme/app_colors.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ejktuacvujbzpjzxopoi.supabase.co',
    anonKey: 'sb_publishable_ruzBXCxH7wx1S8lVOO9KzA_VYSpWm5s',
  );

  runApp(const CohabiApp());
}

class CohabiApp extends StatelessWidget {
  const CohabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cohabi',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: CohabiColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CohabiColors.purple,
        ),
      ),
      home: const OwnerAccountCreatedScreen(),
    );
  }
}