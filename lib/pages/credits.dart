import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:opamp/constants/colors.dart'; // Adjust path

import '../widgets/graph_paper_background.dart'; 
import '../pages/homescreen.dart';
import '../pages/aboutus.dart'; 

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              },
              child: const Text("OP AMP", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutusPage()));
                  },
                  child: const Text("About us", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.black)),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                  },
                  child: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
      body: GraphPaperBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ConstrainedBox(
                 constraints: const BoxConstraints(maxWidth: 650), // Set your max width here (650 is great for tablets/web)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Title
                    const Text(
                      'References & Tools',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 24),
                
                    // Introduction Sticky Note
                    StickyNote(
                      color: const Color(0xFFFFF7D1), // Pastel Yellow
                      angle: -0.01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Behind the Scenes",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.purple),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Building this interactive notebook required learning from some of the best educators on the internet and utilizing great creative tools. This app wouldn't be possible without the following resources!",
                            style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                
                    // SECTION 1: VIDEO REFERENCES
                    const Text(
                      'VIDEO REFERENCES',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildResourceTab(
                      context: context,
                      title: "IC 741 Operational Amplifier", 
                      url: "https://www.youtube.com/watch?v=gYwySQrnDUs",
                      iconWidget: _buildYouTubeIcon(),
                    ),
                    _buildResourceTab(
                      context: context,
                      title: "Eugene Khutoryansky - Op-Amp Animations", 
                      url: "https://www.youtube.com/watch?v=_o4ScgRZtNI&t=1s",
                      iconWidget: _buildYouTubeIcon(),
                    ),
                    _buildResourceTab(
                      context: context,
                      title: "ElectroBOOM - Operational Amplifiers Explained", 
                      url: "https://www.youtube.com/watch?v=OSCKBmkrH_g&t=4s",
                      iconWidget: _buildYouTubeIcon(),
                    ),
                    const SizedBox(height: 32),
                
                    // SECTION 2: WEB REFERENCES
                    const Text(
                      'WEB REFERENCES',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 16),
                
                    _buildResourceTab(
                      context: context,
                      title: "Wikipedia - Operational Amplifier", 
                      url: "https://en.wikipedia.org/wiki/Operational_amplifier",
                      iconWidget: const Icon(Icons.language, size: 24, color: Colors.blueAccent),
                    ),
                    _buildResourceTab(
                      context: context,
                      title: "Electronics Tutorials - Op-Amps", 
                      url: "https://www.electronics-tutorials.ws/opamp/opamp_1.html",
                      iconWidget: const Icon(Icons.language, size: 24, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 32),
                
                    // SECTION 3: SOFTWARE & TOOLS
                    const Text(
                      'SOFTWARE & ASSETS',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                
                    StickyNote(
                      color: const Color(0xFFE2F0CB), // Pastel Green
                      angle: 0.015,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildToolRow(Icons.design_services, "Canva", "Used for overall app design layout, UI prototyping, and color palette selection."),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Colors.black12, thickness: 1),
                          ),
                          _buildToolRow(Icons.brush, "MediBang Paint", "Used to hand-draw the notebook diagrams, schematic assets, and custom UI shapes to give the app its authentic sketchbook feel."),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Colors.black12, thickness: 1),
                          ),
                          _buildToolRow(Icons.photo_filter, "Photopea", "Used for image correction, logo, and adding customized text to graphical assets."),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(color: Colors.black12, thickness: 1),
                          ),
                          _buildToolRow(Icons.code, "Flutter Framework", "The entire user interface and interactive simulation logic was built using Dart and Flutter."),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom YouTube Icon built natively in Flutter
  Widget _buildYouTubeIcon() {
    return Container(
      width: 26,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000), // YouTube Red
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Icon(Icons.play_arrow, color: Colors.white, size: 14),
      ),
    );
  }

  // Helper for Software Tools Row
  Widget _buildToolRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: AppColors.purple),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  // Helper for Link Texts (Ribbon Bookmarks)
  Widget _buildResourceTab({
    required BuildContext context, 
    required String title, 
    required String url, 
    required Widget iconWidget
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Could not open the link.")),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.only(left: 16.0, right: 32.0, top: 14.0, bottom: 14.0),
          decoration: ShapeDecoration(
            color: const Color.fromARGB(255, 175, 228, 255).withValues(alpha: 0.5), 
            shape: const RibbonShape(notchDepth: 16.0),
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08), 
                offset: const Offset(2, 3), 
                blurRadius: 3
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget, // Dynamic icon (YouTube or Web)
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15, 
                    color: Colors.black87, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM STICKY NOTE WIDGET ---
class StickyNote extends StatelessWidget {
  final Widget child;
  final Color color;
  final double angle;

  const StickyNote({
    super.key,
    required this.child,
    this.color = const Color(0xFFFFF7D1), 
    this.angle = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(3, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

// --- CUSTOM RIBBON SHAPE WIDGET ---
class RibbonShape extends ShapeBorder {
  final double notchDepth;

  const RibbonShape({this.notchDepth = 16.0});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right, rect.top)
      ..lineTo(rect.right - notchDepth, rect.top + rect.height / 2) 
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => RibbonShape(notchDepth: notchDepth * t);
}