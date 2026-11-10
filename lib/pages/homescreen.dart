
import 'package:flutter/material.dart';

import '../widgets/graph_paper_background.dart'; 
import '../widgets/custom_arrow_button.dart';

import '../constants/colors.dart'; // Adjust path depending on where your file is located
import '../pages/aboutus.dart';
import '../pages/credits.dart';
import '../pages/index.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
    backgroundColor: Colors.transparent, // Keeps it matching your cream background
    elevation: 0, // Removes shadow
    automaticallyImplyLeading: false,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
          Row(
            children: [
              const SizedBox(width: 10,),
              const Text("GROUP 11",style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context)=> const CreditsPage()));

                 
                },
                child: const Text("Credits", style: TextStyle(fontWeight: FontWeight.normal , fontSize: 17),),
                ),
                const SizedBox(width: 20,),
                GestureDetector(
                  onTap: () {
                  
                     Navigator.push(context, MaterialPageRoute(builder: (context)=> const AboutusPage(),));
                  },
                  child: const Text("About Us", style: TextStyle(fontWeight: FontWeight.bold)),),
              const SizedBox(width: 20),
            ],
          ),
       ],
      )
    ),

      // === IMPLEMENTATION HERE ===
      body: GraphPaperBackground(
        child: SafeArea( // Safe area ensures content is below the system status bar/notch
          child: Stack(
            children: [Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: const Text(
                        'OP AMP',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.purple),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(child: const Text('INVERTING AND NON INVERTING', style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: AppColors.black),),),
                    const SizedBox(height: 30),
                    
                    // Example Navigation Button
                    Center(
                      child: CustomArrowButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const IndexPage(), // 👈 Your target page
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 40
              ,
              right: 40,
              
                child: Column(
                  children: [
                    Text("PROFESSOR:  SANTOS KUMAR DAS ", style: TextStyle(fontSize: 18),),
                    Text("SUBJECT CODE : EC2700", style: TextStyle(fontSize: 18),),
                  ],
                ),
              ),
            ],
          ),
          
          
      
        ),
      ),
    );
  }
}