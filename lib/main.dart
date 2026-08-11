import 'package:flutter/material.dart';
import 'shell/app.dart';

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
      home: const ARPhotoShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}