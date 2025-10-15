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

  void initState(){
    super.initState();
    _Navigatenext();

  }


  Future<void>_Navigatenext()async{
    await Future.delayed(const Duration(seconds: 5));

     final userdata = await Localstorage.getuser();
   final bool isLoggedIn = userdata['isLoggedIn']??false;

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
      
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('MELCOWE'),
            SizedBox(height: 3,),
            CircularProgressIndicator(color: Colors.white)
            
          ],
        ),
      ),
    );
  }
}