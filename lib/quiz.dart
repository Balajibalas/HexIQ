import 'package:flutter/material.dart';

class QuizPage extends StatelessWidget {
  final int userId; // You can keep this if you want to pass user ID later

  QuizPage({required this.userId}); // Plain constructor with userId parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz Page")),
      body: Center(
        child: Text(
          'Welcome to the Quiz Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
