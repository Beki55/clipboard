import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/background_clipboard_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final api = ApiService(baseUrl: 'http://localhost:3000');
    final res = await api.post('auth/login', {
      'email': emailController.text,
      'password': passwordController.text,
    });

    if (res['access_token'] != null) {
      final prefs = await SharedPreferences.getInstance();

      // Save credentials for background service
      await prefs.setString('token', res['access_token']);
      await prefs.setInt('userId', res['user']['id']);

      // generate deviceId
      String? deviceId = prefs.getString('deviceId');
      if (deviceId == null) {
        deviceId = "device-${DateTime.now().millisecondsSinceEpoch}";
        await prefs.setString('deviceId', deviceId);
      }

      // 1️⃣ Register device BEFORE navigating to Home
      final api = ApiService(baseUrl: "http://localhost:3000");
      await api.post("devices/register", {
        "deviceId": deviceId,
        "userId": res['user']['id'],
        "deviceName": "Mobile App",
      });

      // 2️⃣ Start background service
      await BackgroundClipboardService.startService();

      // 3️⃣ Navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userId: res['user']['id'].toString(),
            deviceId: deviceId!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: Text('Login')),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
