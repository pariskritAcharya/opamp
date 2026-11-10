import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:flutter_math_fork/flutter_math.dart'; // True LaTeX support
import 'package:opamp/constants/colors.dart';

import '../widgets/graph_paper_background.dart';
import '../pages/homescreen.dart';
import '../pages/index.dart'; 
import '../pages/invertingAMP.dart';

class IntroToOpAmpPage extends StatefulWidget {
  const IntroToOpAmpPage({super.key});

  @override
  State<IntroToOpAmpPage> createState() => _IntroToOpAmpPageState();
}

class _IntroToOpAmpPageState extends State<IntroToOpAmpPage> {
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
        titleSpacing: 0, // Keeps "OP AMP" close to the back arrow
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const IndexPage()));
                  },
                  child: const Text("Index", style: TextStyle(fontWeight: FontWeight.normal, fontSize: 17, color: Colors.black)),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const InvertingAmplifierPage()));
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
                      'Introduction to OP AMP',
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
                        initiallyExpanded: false, 
                        collapsedIconColor: const Color.fromARGB(255, 255, 93, 34), // Solid, visible black ink color
                        iconColor: Colors.black38, // Faded grey/black when expanded
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          _isExpanded
                              ? 'OVERVIEW: Learn the core working principles, differential amplification, and ideal properties of operational amplifiers.'
                              : 'OVERVIEW: Learn the core working principles, differential amplification, and ideal properties...',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Working Principle:\nAn operational amplifier (Op-Amp) is a high-gain electronic voltage amplifier with differential inputs (inverting [-] and non-inverting [+]) and usually a single output. It mathematically amplifies the difference between the two input voltages.',
                                  style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                                ),
                                const SizedBox(height: 16),
                                
                                // Pure LaTeX for perfect math rendering
                                StickyNote(
                                  color: const Color(0xFFFFF7D1), 
                                  angle: 0.015, 
                                  child: Column(
                                    children: [
                                      const Text("Fundamental Differential Equation:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.purple)),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Math.tex(
                                          r'V_{out} = A_{ol} (V_{+} - V_{-})',
                                          textStyle: const TextStyle(fontSize: 22, color: Colors.black87),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text("Common Mode Rejection Ratio (CMRR):", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.purple)),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Math.tex(
                                          r'CMRR = 20 \log_{10} \left( \frac{A_d}{A_c} \right)',
                                          textStyle: const TextStyle(fontSize: 22, color: Colors.black87),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                const Text(
                                  'Ideal Properties:\n'
                                  '  • Infinite Open-Loop Gain (A_ol) → Any input difference results in massive output.\n'
                                  '  • Infinite Input Impedance (Z_in) → Zero current flows into the input pins.\n'
                                  '  • Zero Output Impedance (Z_out) → It can drive any load perfectly.\n'
                                  '  • Infinite Bandwidth → It amplifies all frequencies equally without delay.\n\n'
                                  'Feedback Mechanism:\nBecause open-loop gain is practically infinite, Op-Amps are rarely used without external components. Negative feedback stabilizes the gain and controls the exact mathematical behavior of the circuit.',
                                  style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                
                    // SCHEMATIC IMAGES SECTION
                    const Text(
                      'DIAGRAMS',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showImagePopup(context, 'assets/images/opAMPDiagram.png', 'Standard Op-Amp Diagram', const Color(0xFFE2F0CB)),
                            child: StickyNote(
                              color: const Color(0xFFE2F0CB), 
                              angle: -0.02, 
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/opAMPDiagram.png',
                                    fit: BoxFit.contain,
                                    height: 270, 
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80, color: Colors.black26),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Standard Op-Amp Diagram", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                                  const Text("(Tap to view details)", style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          GestureDetector(
                            onTap: () => _showImagePopup(context, 'assets/images/ic741.png', 'Typical 741 IC Pinout Diagram', const Color(0xFFFFDFD3)),
                            child: StickyNote(
                              color: const Color(0xFFFFDFD3), 
                              angle: 0.02, 
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/images/ic741.png',
                                    fit: BoxFit.contain,
                                    height: 260, 
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80, color: Colors.black26),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Typical 741 IC Pinout Diagram", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                                  const Text("(Tap to view details)", style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                
                    // IC PINS & PARTS EXPLANATION
                    const Text(
                      'IC PIN FUNCTIONS',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                
                    StickyNote(
                      color: const Color(0xFFF1E6F3), 
                      angle: -0.01,
                      child: Table(
                        columnWidths: const {
                          0: IntrinsicColumnWidth(),
                          1: FlexColumnWidth(),
                        },
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: [
                          _buildPinTableRow('Inverting Input (-): ', 'Receives input signal phase-inverted or serves as the feedback node.'),
                          _buildPinTableRow('Non-Inverting (+): ', 'Receives input signal in-phase; often referenced to ground or source.'),
                          _buildPinTableRow('Output (Out): ', 'Delivers the amplified output voltage signal to the load.'),
                          _buildPinTableRow('V+ / V- Supply: ', 'Positive and negative DC power rails supplying operating voltage.'),
                          _buildPinTableRow('Offset Null: ', 'Pins used externally to zero out input offset voltage errors.'),
                          _buildPinTableRow('NC: ', 'Not Connected; internal pins with no external connection required.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                
                    // RESEARCH, LINKS, AND APPLICATIONS SECTION
                    const Text(
                      'APPLICATIONS & RESEARCH',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildApplicationCard(
                      icon: Icons.speaker,
                      title: "Audio Preamplification & Filtering",
                      description: "Op-Amps are the foundation of audio mixing boards and preamplifiers, driving the crisp sound systems required for intricate theater performances, classical dance recitals, and studio music production.",
                      color: const Color(0xFFFFF7D1),
                      angle: 0.015,
                    ),
                    _buildApplicationCard(
                      icon: Icons.monitor_heart,
                      title: "Medical Instrumentation",
                      description: "Instrumentation amplifiers (built using multiple op-amps) are used in ECG and EEG machines to extract tiny biological signals while rejecting massive environmental noise.",
                      color: const Color(0xFFE8F4F8), 
                      angle: -0.015,
                    ),
                    _buildApplicationCard(
                      icon: Icons.calculate,
                      title: "Analog Computers",
                      description: "Before digital processors, op-amps were literally used to perform mathematical calculus (Integration and Differentiation) continuously in real-time.",
                      color: const Color(0xFFFCE1E4), 
                      angle: 0.01,
                    ),
                    
                    const SizedBox(height: 24),
                    const Text("Further Learning Links:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    // --- SOFTER RIBBON LINKS ---
                    _buildResourceTab("Electronics Tutorials - The Operational Amplifier", "https://www.electronics-tutorials.ws/opamp/opamp_1.html"),
                    _buildResourceTab("All About Circuits - Op-Amp Basics", "https://www.allaboutcircuits.com/textbook/semiconductors/chpt-8/introduction-operational-amplifiers/"),
                    _buildResourceTab("Texas Instruments - Op-Amp Design Guides", "https://www.ti.com/amplifier-circuit/op-amps/overview.html"),
                    
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

  // Helper for the Pin Table
  TableRow _buildPinTableRow(String pin, String description) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 12.0),
          child: Text(pin, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(description, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14, color: Colors.black87)),
        ),
      ],
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

  // Helper for Link Texts (Softer Ribbon Bookmarks)
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
      ..lineTo(rect.right - notchDepth, rect.top + rect.height / 2) // Cuts inward
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => RibbonShape(notchDepth: notchDepth * t);
}