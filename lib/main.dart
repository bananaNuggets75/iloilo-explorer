import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const IloiloTravelBuddyApp());
}

class IloiloTravelBuddyApp extends StatelessWidget {
  const IloiloTravelBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF00695C); // teal — feels "local + fresh"
    return MaterialApp(
      title: 'Iloilo Travel Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
