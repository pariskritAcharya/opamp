import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:opamp/constants/colors.dart'; 

import '../widgets/graph_paper_background.dart'; 
import '../pages/homescreen.dart';
import '../pages/credits.dart';

class AboutusPage extends StatefulWidget {
  const AboutusPage({super.key});

  @override
  State<AboutusPage> createState() => _AboutusPageState();
}

class _AboutusPageState extends State<AboutusPage> {
  int _pariskritClickCount = 0;
  
  // Glows at 3 clicks, unlocks ribbon at 10 clicks
  bool get _isGolden => _pariskritClickCount >= 3;
  bool get _isSecretUnlocked => _pariskritClickCount >= 10;

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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreditsPage()));
                  },
                  child: const Text("Credits", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.black)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'ABOUT US',
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "The team behind the project",
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                
                // TEAM LIST STICKY NOTE
                Center(
                  child: StickyNote(
                    color: const Color(0xFFF1E6F3), // Soft pastel purple note
                    angle: -0.015,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Project Members",
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold, 
                              color: AppColors.purple,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // All rows are now built identically to prevent font changes
                          _buildMemberRow('Anuj', '125CS0147'),
                          const SizedBox(height: 12),
                          _buildMemberRow('Suman', '125CS0148'),
                          const SizedBox(height: 12),
                          
                          // Pariskrit - The Easter Egg Row (Passes onTap logic and Golden state)
                          _buildMemberRow(
                            'Pariskrit', 
                            '125CS0149',
                            isGolden: _isGolden,
                            onTap: () {
                              setState(() {
                                _pariskritClickCount++;
                              });
                            },
                          ),
                          
                          const SizedBox(height: 12),
                          _buildMemberRow('Prasiddha', '125CS0150'),
                          const SizedBox(height: 12),
                          _buildMemberRow('Purushottam', '125CS0151'),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 50),

                // SECRET UNLOCK REVEAL
                AnimatedOpacity(
                  opacity: _isSecretUnlocked ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  child: _isSecretUnlocked 
                      ? Column(
                          children: [
                            const Text(
                              "✨ You found the creator! ✨",
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.orange, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            _buildResourceTab(
                              context: context,
                              title: "Cyber Nivio", // Only Cyber Nivio written
                              url: "https://www.youtube.com/@CyberNivio",
                              iconWidget: _buildYouTubeIcon(),
                            ),
                          ],
                        )
                      : const SizedBox(height: 80), // Placeholder to prevent layout jump
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UNIFIED ROW BUILDER ---
  // Every member uses this exact same layout so the fonts match perfectly
  Widget _buildMemberRow(String name, String roll, {bool isGolden = false, VoidCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap, // Null for other members, triggers counting for you
      child: SizedBox(
        width: 310, 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              // Uses standard TextStyle to perfectly inherit your app's custom font
              style: TextStyle(
                fontSize: isGolden ? 22 : 20, 
                fontWeight: isGolden ? FontWeight.w900 : FontWeight.normal, 
                color: isGolden ? Colors.amber.shade600 : AppColors.black,
                shadows: isGolden 
                    ? [
                        Shadow(
                          color: Colors.amber.withValues(alpha: 0.6), 
                          blurRadius: 10,
                        )
                      ] 
                    : [],
              ),
            ),
            Text(
              roll,
              style: TextStyle(
                fontSize: 20, 
                fontWeight: isGolden ? FontWeight.bold : FontWeight.normal, 
                color: isGolden ? Colors.amber.shade700 : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom YouTube Icon built natively
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

  // Secret Link Ribbon
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
            color: Colors.white.withValues(alpha: 0.95), 
            shape: const RibbonShape(notchDepth: 16.0),
            shadows: [
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.4), // Golden shadow for the secret link
                offset: const Offset(2, 4), 
                blurRadius: 8
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget, 
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16, 
                  color: Colors.black87, 
                  fontWeight: FontWeight.bold,
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