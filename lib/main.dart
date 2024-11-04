import 'package:flutter/material.dart';
import 'package:hexiq/LoginPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase (replace with your Supabase URL and API key)
  await Supabase.initialize(
    url: 'https://rcummkkmijqfeyrrbict.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjdW1ta2ttaWpxZmV5cnJiaWN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjkzNTE5MzQsImV4cCI6MjA0NDkyNzkzNH0.xirZdVALERrWrCuSQSqMOGvZj22JmOSyCbCJauRm6EY'
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HexIQ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: LoginPage(),
    );
  }
}

