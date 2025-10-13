import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qwixo/home.dart';
import 'package:qwixo/localstorage.dart';
import 'package:qwixo/screens/login.dart';

void main() async {
  
 
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final userdata = await Localstorage.getuser();
   final bool isLoggedIn = userdata['isLoggedIn']??false;


   runApp(MyApp(isLoggedIn:isLoggedIn));
  
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  
  const MyApp({super.key, required this.isLoggedIn});
  

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      
       
      ),
      home: isLoggedIn?Home():Login(),
    );
  }
}

