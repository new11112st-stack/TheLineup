// نقطة بداية التطبيق — تهيئة Firebase وProvider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'services/firebase_service.dart';
import 'services/storage_service.dart';
import 'utils/theme.dart';
import 'screens/root_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الخدمات
  await StorageService.initialize();
  await FirebaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..start()),
      ],
      child: const TakweelaApp(),
    ),
  );
}

class TakweelaApp extends StatelessWidget {
  const TakweelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'التشكيلة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RootScreen(),
      builder: (context, child) {
        // التأكد من دعم RTL
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
    );
  }
}
