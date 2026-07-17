import 'package:flutter/material.dart';

void main() {
  runApp(const ARPhotoApp());
}

class ARPhotoApp extends StatelessWidget {
  const ARPhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Photo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Photo')),
      body: Center(
        child: Text(
          '🚧 MVP coming soon...',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
