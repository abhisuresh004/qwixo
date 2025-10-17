import 'package:flutter/material.dart';
import 'package:qwixo/home.dart';
import 'package:qwixo/localstorage.dart';
import 'package:qwixo/screens/login.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _Navigatenext();
  }

  Future<void> _Navigatenext() async {
    await Future.delayed(const Duration(seconds: 5));

    final userdata = await Localstorage.getuser();
    final bool isLoggedIn = userdata['isLoggedIn'] ?? false;

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const Home() : const Login(),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo image on top
          Image.asset(
            'assets/images/lopng.png',
            width: 300, // adjust size
            height: 350,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 30),

          // Text below image
          Text(
            'MELCOWE',
            style: TextStyle(
              fontSize:25,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 20),

          // Circular progress indicator below text
          const CircularProgressIndicator(
            color: Colors.blue,
          ),
        ],
      ),
    ),
  );
}
}
