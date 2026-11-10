import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:flutter_math_fork/flutter_math.dart'; // LaTeX support
import 'package:opamp/constants/colors.dart';

import '../widgets/graph_paper_background.dart';
import '../widgets/custom_arrow_button.dart';
import '../pages/homescreen.dart';
import '../pages/index.dart';
import '../pages/nonInvertingAMPPrac.dart'; 

class NonInvertingAmplifierPage extends StatefulWidget {
  const NonInvertingAmplifierPage({super.key});

  @override
  State<NonInvertingAmplifierPage> createState() => _NonInvertingAmplifierPageState();
}

class _NonInvertingAmplifierPageState extends State<NonInvertingAmplifierPage> {
  bool _isExpanded = false; // Starts closed

  // --- IMAGE ZOOM POPUP (Styled as a giant Sticky Note) ---
  // --- IMAGE ZOOM POPUP ---
  void _showImagePopup(BuildContext context, String imagePath, String title, Color noteColor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        elevation: 0, // Removes default dialog shadow so only the sticky note shadow shows
        // Notice: The Center widget is gone! The Dialog will now perfectly wrap the container.
        child: Transform.rotate(
          angle: 0.015, 
          child: Container(
            width: double.infinity, 
            constraints: const BoxConstraints(maxWidth: 600), 
            height: MediaQuery.of(context).size.height * 0.65,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: noteColor, 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15), 
                  offset: const Offset(4, 6), 
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title, 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.redAccent, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Expanded(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 1.0,
                    maxScale: 4.0, 
                    child: Image.asset(
                      imagePath, 
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported, size: 100, color: Colors.black26)),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text("Pinch to zoom, drag to pan", style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Restored the Back Button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0, // Keeps "OP AMP" text close to the back arrow
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const IndexPage()));
                  },
                  child: const Text("Index", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.black)),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NonInvertingAmplifierPrac()));
                  },
                  child: const Text("Next", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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
                    const Text(
                      'Non-Inverting OP AMP',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 24),
                
                    // DESCRIPTION SECTION
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _isExpanded = expanded;
                          });
                        },
                        initiallyExpanded: false, // Starts closed
                        collapsedIconColor: const Color.fromARGB(255, 255, 93, 34), // Custom Orange
                        iconColor: Colors.black38, // Faded grey when open
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          _isExpanded
                              ? 'INPUT CONNECTION: The input voltage connects directly to the positive (non-inverting) terminal.'
                              : 'INPUT CONNECTION: The input voltage connects directly to the positive (non-inverting) terminal...',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                        children: const [
                          // ALIGN LEFT FIX: Forces the bullet points strictly to the left margin
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 12.0, top: 4.0),
                              child: Text(
                                '• High Input Impedance: Because the input signal is applied directly to the non-inverting terminal, the input impedance is extremely high, drawing negligible input current.\n\n'
                                '• In-Phase Output: The output signal is exactly in phase with the input signal. A positive rising voltage at the input results in a positive rising voltage at the output.\n\n'
                                '• Feedback Mechanism: Output is fed back to the inverting (-) terminal through resistor R2, while resistor R1 connects the inverting terminal to ground. This divider sets the gain.\n\n'
                                '• Voltage Follower Effect: When configured with unity gain (R2 = 0, R1 = removed), it acts as an ideal voltage buffer, matching output to input to prevent signal loading.',
                                style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                
                    // SCHEMATIC IMAGE & SIMULATION BUTTON
                    const Text(
                      'DIAGRAM & SIMULATION',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                
                    Center(
                      child: StickyNote(
                        color: const Color(0xFFE2F0CB), // Pastel Green
                        angle: 0.01,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _showImagePopup(context, 'assets/images/nonInvertingAmp.png', 'Non-Inverting Amplifier Diagram', const Color(0xFFE2F0CB)),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/nonInvertingAmp.png',
                                    fit: BoxFit.contain,
                                    height: 220,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80, color: Colors.black26),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Non-Inverting Op-Amp Schematic", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                                  const Text("(Tap to view details)", style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Divider(color: Colors.black26),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Launch Interactive Simulator:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.purple)),
                                SizedBox(
                                  width: 50,
                                  child: CustomArrowButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NonInvertingAmplifierPrac(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                
                    // MATHEMATICAL FORMULA DERIVATION
                    const Text(
                      'MATHEMATICAL DERIVATION',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                
                    StickyNote(
                      color: const Color(0xFFE8F4F8), // Pastel Blue
                      angle: -0.01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Because of the Virtual Short, the voltage at the inverting (-) terminal matches the non-inverting (+) terminal. Therefore, V- = Vin.",
                            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          
                          // LaTeX Step 1
                          Row(
                            children: [
                              const Text("1. Node Voltage:   ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              Math.tex(
                                r'V_{-} = V_{in}',
                                textStyle: const TextStyle(fontSize: 18, color: Colors.black87),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                
                          // LaTeX Step 2
                          Row(
                            children: [
                              const Text("2. Current Law (KCL):   ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              Math.tex(
                                r'I_{R1} = I_{R2}',
                                textStyle: const TextStyle(fontSize: 18, color: Colors.black87),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                
                          // LaTeX Step 3
                          Row(
                            children: [
                              const Text("3. Substitute:   ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              Math.tex(
                                r'\frac{V_{in} - 0}{R_1} = \frac{V_{out} - V_{in}}{R_2}',
                                textStyle: const TextStyle(fontSize: 18, color: Colors.black87),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: Colors.black26),
                          const SizedBox(height: 16),
                
                          // LaTeX Final Gain
                          Center(
                            child: Math.tex(
                              r'Gain\ (A_v) = \frac{V_{out}}{V_{in}} = 1 + \frac{R_2}{R_1}',
                              textStyle: const TextStyle(fontSize: 22, color: AppColors.purple),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                
                    // USE CASES & APPLICATIONS
                    const Text(
                      'INDUSTRY USE CASES',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildApplicationCard(
                      icon: Icons.shield,
                      title: "High-Z Voltage Buffers",
                      description: "When R2 is 0Ω and R1 is removed, the circuit acts as a unity-gain buffer. It protects delicate input sensors (like a guitar pickup) from being 'loaded down' or drained by subsequent circuitry.",
                      color: const Color(0xFFFFF7D1), // Pastel Yellow
                      angle: 0.015,
                    ),
                    _buildApplicationCard(
                      icon: Icons.mic,
                      title: "Active Microphone Preamps",
                      description: "Microphones produce very weak signals but require high input impedance to preserve audio quality. Non-inverting op-amps perfectly amplify these signals without phase distortion.",
                      color: const Color(0xFFFCE1E4), // Light Peach
                      angle: -0.01,
                    ),
                    _buildApplicationCard(
                      icon: Icons.tune,
                      title: "Signal Conditioning",
                      description: "Used heavily in data acquisition systems to scale up sensor outputs (like temperature sensors) so they exactly match the optimal input range of an Analog-to-Digital Converter (ADC).",
                      color: const Color(0xFFF1E6F3), // Pastel Purple
                      angle: 0.01,
                    ),
                    
                    const SizedBox(height: 24),
                    const Text("Further Learning Links:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    // --- RIBBON LINKS ---
                    _buildResourceTab("All About Circuits - Non-Inverting Op-Amp", "https://www.allaboutelectronics.org/non-inverting-op-amp/"),
                    _buildResourceTab("Texas Instruments - Buffer & Amplifier Design", "https://www.ti.com/lit/an/sboa269a/sboa269a.pdf"),
                    _buildResourceTab("Electronics Tutorials - The Non-Inverting Amplifier", "https://www.electronics-tutorials.ws/opamp/opamp_3.html"),
                    
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

  // Helper for Application Cards 
  Widget _buildApplicationCard({
    required IconData icon, 
    required String title, 
    required String description, 
    required Color color, 
    required double angle
  }) {
    return StickyNote(
      color: color,
      angle: angle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: AppColors.purple), 
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.brown)),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Link Texts (Ribbon Bookmarks)
  Widget _buildResourceTab(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
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
              const Icon(Icons.link, size: 20, color: AppColors.purple), 
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