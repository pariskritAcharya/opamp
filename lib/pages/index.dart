import 'package:flutter/material.dart';

import '../widgets/graph_paper_background.dart'; 
import '../constants/colors.dart'; 
import '../pages/homescreen.dart';
import '../pages/invertingAMP.dart';
import '../pages/noninvertingAMP.dart';
import '../pages/introOPAMP.dart';
import '../pages/exercise.dart'; // Make sure to create this file next

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Keeps it matching your cream background
        elevation: 0, // Removes shadow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                  },
                  child: const Text("OP AMP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  child: const Text("HOME", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black)),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
      body: GraphPaperBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'INDEX',
                    style: TextStyle(
                      fontSize: 40, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.purple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Member List Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const IntroToOpAmpPage(),
                            ),
                          );
                        },
                        child: const Text("1. Introduction to OP AMP", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.black)),
                      ),
                      const SizedBox(height: 12),
                      
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InvertingAmplifierPage(),
                            ),
                          );
                        },
                        child: const Text("2. Inverting OP AMP", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.black)),
                      ),
                      const SizedBox(height: 12),
                      
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NonInvertingAmplifierPage(),
                            ),
                          );
                        },
                        child: const Text("3. Non-Inverting OP AMP", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.black)),
                      ),
                      const SizedBox(height: 12),
                      
                      // NEW EXERCISE LINK
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExercisePage(),
                            ),
                          );
                        },
                        child: const Text("4. OP AMP Exercises & Quiz", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20, color: Colors.black)),
                      ),
                      const SizedBox(height: 12),  
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}