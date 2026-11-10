import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:flutter_math_fork/flutter_math.dart'; // NEW: LaTeX support
import 'package:opamp/constants/colors.dart';

import '../widgets/graph_paper_background.dart';
import '../widgets/custom_arrow_button.dart';
import '../pages/homescreen.dart';
import '../pages/index.dart';
import '../pages/invertingAMPPrac.dart'; 

class InvertingAmplifierPage extends StatefulWidget {
  const InvertingAmplifierPage({super.key});

  @override
  State<InvertingAmplifierPage> createState() => _InvertingAmplifierPageState();
}

class _InvertingAmplifierPageState extends State<InvertingAmplifierPage> {
  bool _isExpanded = false; // Starts closed

  // --- IMAGE ZOOM POPUP ---
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
        // Explicitly added the back button back in
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0, // Keeps the "OP AMP" text close to the back arrow
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const InvertingAmplifierPrac()));
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
                      'Inverting OP AMP',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 24),
                
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
                        initiallyExpanded: false, // Starts collapsed so it doesn't overwhelm
                        collapsedIconColor: const Color.fromARGB(255, 255, 93, 34), // Your custom orange!
                        iconColor: Colors.black38, // Fades to grey when open
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          _isExpanded
                              ? 'OVERVIEW: How the Inverting Amplifier utilizes virtual ground to perfectly invert and scale an input signal.'
                              : 'OVERVIEW: How the Inverting Amplifier utilizes virtual ground...',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.0, top: 4.0),
                            child: Text(
                              '• Phase Inversion: An inverting amplifier generates an output voltage that is exactly 180 degrees out of phase with the input waveform. If you input a positive voltage, the output will swing negative.\n\n'
                              '• Virtual Ground Concept: The non-inverting (+) terminal is physically connected to ground. Because the op-amp has infinite open-loop gain and employs negative feedback, the differential voltage between the inputs is forced to zero. This makes the inverting (-) terminal act as a "virtual ground" (0V) even though it isn\'t directly grounded.\n\n'
                              '• Resistor Roles: R1 (Input Resistor) controls the amount of current drawn from the source, while R2 (Feedback Resistor) diverts that current to the output, precisely dictating the amplification factor (Gain).',
                              style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
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
                        angle: -0.015,
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _showImagePopup(context, 'assets/images/invertingAmp.png', 'Inverting Amplifier Diagram', const Color(0xFFE2F0CB)),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/invertingAmp.png',
                                    fit: BoxFit.contain,
                                    height: 220,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80, color: Colors.black26),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Inverting Op-Amp Schematic", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
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
                                          builder: (context) => const InvertingAmplifierPrac(),
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
                      angle: 0.01,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Because of Virtual Ground (V- = 0V) and Infinite Input Impedance (no current enters the Op-Amp pin), all input current flows through the feedback resistor.",
                            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          
                          // LaTeX Step 1 - WRAPPED IN FITTEDBOX TO PREVENT OVERFLOW
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Text("1. Input Current:   ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                Math.tex(
                                  r'I_{in} = \frac{V_{in} - 0}{R_{in}} = \frac{V_{in}}{R_{in}}',
                                  textStyle: const TextStyle(fontSize: 18, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                
                          // LaTeX Step 2 - WRAPPED IN FITTEDBOX TO PREVENT OVERFLOW
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Text("2. Feedback Current:   ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                Math.tex(
                                  r'I_f = \frac{0 - V_{out}}{R_f} = -\frac{V_{out}}{R_f}',
                                  textStyle: const TextStyle(fontSize: 18, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                
                          // LaTeX Step 3 - WRAPPED IN FITTEDBOX TO PREVENT OVERFLOW
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Text("3. Equate (", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                Math.tex(r'I_{in} = I_f', textStyle: const TextStyle(fontSize: 16, color: Colors.black87)),
                                const Text("):     ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                Math.tex(
                                  r'\frac{V_{in}}{R_{in}} = -\frac{V_{out}}{R_f}',
                                  textStyle: const TextStyle(fontSize: 18, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(color: Colors.black26),
                          const SizedBox(height: 16),
                
                          // LaTeX Final Gain - WRAPPED IN FITTEDBOX TO PREVENT OVERFLOW
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Center(
                              child: Math.tex(
                                r'Gain\ (A_v) = \frac{V_{out}}{V_{in}} = -\frac{R_f}{R_{in}}',
                                textStyle: const TextStyle(fontSize: 22, color: AppColors.purple),
                              ),
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
                      icon: Icons.graphic_eq,
                      title: "Audio Summing Mixers",
                      description: "Inverting amplifiers act as precise audio mixers. The virtual ground node isolates multiple input channels, allowing DJs to mix different audio signals without them bleeding into or interfering with one another.",
                      color: const Color(0xFFFFF7D1),
                      angle: -0.01,
                    ),
                    _buildApplicationCard(
                      icon: Icons.sensors,
                      title: "Transimpedance Amplifiers",
                      description: "Sensors like photodiodes produce tiny currents rather than voltages. An inverting op-amp takes that current directly into the virtual ground and converts it into a large, readable voltage.",
                      color: const Color(0xFFFCE1E4), // Light Peach
                      angle: 0.015,
                    ),
                    _buildApplicationCard(
                      icon: Icons.calculate,
                      title: "Analog Integrators & Differentiators",
                      description: "By swapping the feedback resistor with a capacitor, the inverting amplifier transforms into a calculus engine, performing real-time mathematical integration for analog control systems.",
                      color: const Color(0xFFE2F0CB), // Pastel Green
                      angle: -0.01,
                    ),
                    
                    const SizedBox(height: 24),
                    const Text("Further Learning Links:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    // --- RIBBON LINKS ---
                    _buildResourceTab("All About Circuits - Inverting Op-Amp & Virtual Ground", "https://www.allaboutelectronics.org/inverting-op-amp-and-the-concept-of-virtual-ground/"),
                    _buildResourceTab("Texas Instruments - Inverting Amplifier Design", "https://www.ti.com/lit/sboa270"),
                    _buildResourceTab("GeeksForGeeks - Inverting Operational Amplifier", "https://www.geeksforgeeks.org/electrical-engineering/inverting-operational-amplifier/"),
                    
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