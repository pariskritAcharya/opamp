// main.dart
import 'package:flutter/material.dart';
import 'pages/homescreen.dart'; // Import your home page file
import 'constants/colors.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OP-AMP',
      
      
      theme: ThemeData(
        useMaterial3: true,
        // Sets the background color for all Scaffolds globally
        scaffoldBackgroundColor: AppColors.cream, 
        fontFamily: 'CustomMathFont',
        
      ),
      home: HomeScreen(), // Sets your home screen as the very first page
    );
  }
}