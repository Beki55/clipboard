import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/clipboard_provider.dart';
import 'services/background_clipboard_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background service
  await BackgroundClipboardService.initializeService();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ClipboardProvider())],
      child: ClipboardApp(),
    ),
  );
}

class ClipboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipboard Sync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}
