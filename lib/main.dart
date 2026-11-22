import 'package:flutter/material.dart';

void main() => runApp(const KspShoppingApp());

class KspShoppingApp extends StatelessWidget {
  const KspShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF102A43);
    const gold = Color(0xFFD4AF37);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KSP Shopping',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('KSP SHOPPING')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag, size: 72, color: navy),
                const SizedBox(height: 16),
                const Text('Welcome to KSP Shopping',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Customer & Admin shopping app starter',
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Navy Blue • White • Gold',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
