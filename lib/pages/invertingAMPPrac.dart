import 'dart:math' as math;
import 'dart:convert';
import 'dart:async'; // REQUIRED FOR CONTINUOUS HOLD TIMERS
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_math_fork/flutter_math.dart'; 
import 'package:opamp/constants/colors.dart';

import '../widgets/graph_paper_background.dart'; 
import '../pages/homescreen.dart';
// Adjust this import depending on the exact name of your non-inverting practice page file
import '../pages/noninvertingAMP.dart'; 

class InvertingAmplifierPrac extends StatefulWidget {
  const InvertingAmplifierPrac({super.key});

  @override
  State<InvertingAmplifierPrac> createState() => _InvertingAmplifierPracState();
}

class _InvertingAmplifierPracState extends State<InvertingAmplifierPrac> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  
  // States: 'incomplete', 'error', 'correct'
  String _circuitState = 'incomplete';

  // Interactive Simulation State
  String _waveType = 'Sine';
  double _amplitude = 1.0;         
  double _r1 = 10.0;             
  double _r2 = 20.0;             
  
  // Independent zoom scales for both graphs (-50 to 50)
  double _genScale = 0.0; 
  double _dsoScale = 0.0; 
  bool _isWaveActive = true; 

  // List to store recorded results for the table
  final List<Map<String, String>> _tableData = [];

  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  // Scroll Controllers
  final ScrollController _tableScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTableData(); 
  }

  @override
  void dispose() {
    _animController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  // --- PERSISTENT STORAGE METHODS ---

  Future<void> _loadTableData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('inverting_table_data');
    
    if (savedData != null) {
      final List<dynamic> decodedData = jsonDecode(savedData);
      setState(() {
        _tableData.clear();
        for (var item in decodedData) {
          _tableData.add(Map<String, String>.from(item));
        }
      });
    }
  }

  Future<void> _saveTableData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_tableData);
    await prefs.setString('inverting_table_data', encodedData);
  }

  void _recordValuesToTable(double gain, double vOut) {
    setState(() {
      _tableData.add({
        'type': 'Inverting',
        'r1': '${_r1.toStringAsFixed(1)} kΩ',
        'r2': '${_r2.toStringAsFixed(1)} kΩ',
        'vin': '${_amplitude.toStringAsFixed(2)} V',
        'vout': '${vOut.toStringAsFixed(2)} V',
        'gain': gain.toStringAsFixed(2),
        'phase': _isWaveActive ? '180° (Out-of-phase)' : '-',
      });
    });
    _saveTableData(); 
  }

  void _deleteRow(int index) {
    setState(() {
      _tableData.removeAt(index);
    });
    _saveTableData(); 
  }

  // --- LOGIC METHODS ---

  void _autoSetGraphs(double maxOutAmplitude) {
    double optimalMultiplier = maxOutAmplitude / 3.5;
    if (optimalMultiplier < 0.001) optimalMultiplier = 0.001; 
    
    double optimalDialValue = math.log(optimalMultiplier) / math.log(1.1);
    
    setState(() {
      _genScale = optimalDialValue.clamp(-50.0, 50.0);
      _dsoScale = optimalDialValue.clamp(-50.0, 50.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    double safeR1 = (_r1 == 0) ? 0.001 : _r1;
    // INVERTING AMPLIFIER GAIN FORMULA: Av = -(R2 / R1)
    double gain = - (_r2 / safeR1); 
    
    double vOutAmplitude = _amplitude * gain;
    double vOutDCValue = _amplitude * gain;
    
    double maxSignal = _isWaveActive ? vOutAmplitude.abs() : vOutDCValue.abs();
    double currentVout = _isWaveActive ? vOutAmplitude : vOutDCValue;

    bool isLocked = _circuitState != 'correct';

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
                    // Links to the Non-Inverting Practice page next
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NonInvertingAmplifierPage()));
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
                        initiallyExpanded: false, 
                        collapsedIconColor: const Color.fromARGB(255, 255, 93, 34), // Custom Orange
                        iconColor: Colors.black38, 
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          _isExpanded
                              ? 'GUIDE & FORMULA: Learn how to interact with the simulation and view calculations.'
                              : 'GUIDE & FORMULA: Learn how to interact with the simulation and view calculations...',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• How to Use:\n'
                                    '  - First, trace the circuit by dragging wires between the correct component terminals.\n'
                                    '  - Once validated, the simulation panels will unlock automatically.\n'
                                    '  - HOLD the side arrows to spin rapidly, drag the dials vertically, or tap the numbers to type values.\n'
                                    '  - Large values will clip the graph; adjust the scales or press AUTOSET to fit them on screen.\n',
                                    style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                                  ),
                                  const Text(
                                    '• Formulas Involved:',
                                    style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                                  ),
                                  const SizedBox(height: 12),
                                  // LaTeX for Inverting Gain
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Math.tex(
                                      r'Voltage\ Gain\ (A_v) = -\frac{R_2}{R_1}',
                                      textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // LaTeX for Output Voltage
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Math.tex(
                                      r'Output\ Voltage\ (V_{out}) = A_v \times V_{in}',
                                      textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    '  - The output signal is inverted (180° out-of-phase) from the input signal.',
                                    style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                
                    // INTERACTIVE CIRCUIT BUILDER
                    CircuitBuilder(
                      isLocked: !isLocked, 
                      onCircuitStateChanged: (state) {
                        setState(() {
                          _circuitState = state;
                        });
                      },
                      onCircuitRedo: () {
                        setState(() {
                          _circuitState = 'incomplete';
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                
                    // NOTEBOOK-STYLE VALIDATION MESSAGE
                    if (isLocked)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            _circuitState == 'error'
                                ? "Oops! Incorrect wiring or short circuit detected. Tap the redo icon to try again."
                                : "Wiring Required: Correctly connect the circuit above to unlock the simulation instruments.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, 
                              color: _circuitState == 'error' ? Colors.redAccent : Colors.black54, 
                              fontStyle: FontStyle.italic,
                              fontWeight: _circuitState == 'error' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      // WAVEFORM DISPLAYS (Function Generator & DSO)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Function Generator (Input)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center, 
                              children: [
                                const Text(
                                  "Function Generator",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const Text(
                                  "Vin",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.purple),
                                ),
                                const SizedBox(height: 4), 
                                SizedBox(
                                  width: 145,
                                  height: 105,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.asset(
                                          'assets/images/box_2.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Positioned(
                                        left: 10,
                                        top: 22,
                                        width: 108,
                                        height: 58,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border.all(color: Colors.black, width: 2.0),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: ClipRect(
                                                  child: AnimatedBuilder(
                                                    animation: _animController,
                                                    builder: (context, child) {
                                                      return CustomPaint(
                                                        painter: MiniWavePainter(
                                                          progress: _animController.value,
                                                          waveType: _waveType,
                                                          amplitudeFactor: _amplitude,
                                                          scale: _genScale, 
                                                          color: AppColors.purple,
                                                          isWaveActive: _isWaveActive,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                RotaryDial(
                                  label: "Vin Scale",
                                  value: _genScale,
                                  baseMin: -50.0,
                                  baseMax: 50.0, 
                                  stepSize: 1.0,
                                  unit: "", 
                                  indicatorColor: AppColors.purple,
                                  onChanged: (val) => setState(() => _genScale = val),
                                ),
                              ],
                            ),
                          ),
                
                          // DSO (Output)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center, 
                              children: [
                                const Text(
                                  "DSO",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const Text(
                                  "Output",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.orange),
                                ),
                                const SizedBox(height: 4), 
                                SizedBox(
                                  width: 145, 
                                  height: 105, 
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.asset(
                                          'assets/images/box_2.png',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Positioned(
                                        left: 10,
                                        top: 22,
                                        width: 108,
                                        height: 58,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border.all(color: Colors.black, width: 2.0),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: ClipRect(
                                                  child: AnimatedBuilder(
                                                    animation: _animController,
                                                    builder: (context, child) {
                                                      return CustomPaint(
                                                        painter: MiniWavePainter(
                                                          progress: _animController.value,
                                                          waveType: _waveType,
                                                          amplitudeFactor: _isWaveActive ? vOutAmplitude : vOutDCValue,
                                                          scale: _dsoScale,
                                                          color: AppColors.orange,
                                                          isWaveActive: _isWaveActive,
                                                          isDCValueExplicit: !_isWaveActive,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                RotaryDial(
                                  label: "Output Scale",
                                  value: _dsoScale,
                                  baseMin: -50.0,
                                  baseMax: 50.0,
                                  stepSize: 1.0, 
                                  unit: "",
                                  indicatorColor: AppColors.orange,
                                  onChanged: (val) => setState(() => _dsoScale = val),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                
                      // AUTOSET BUTTON
                      Center(
                        child: TextButton(
                          onPressed: () => _autoSetGraphs(maxSignal),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text(
                            "AUTOSET",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                
                      const Text(
                        'Inputs & Variables',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 12),
                
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Wave Type & State:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isWaveActive = !_isWaveActive;
                                  });
                                },
                                icon: _isWaveActive
                                    ? const ACSineIcon(color: AppColors.purple)
                                    : const DCIcon(color: Colors.grey),
                                tooltip: _isWaveActive ? "Switch to DC Mode" : "Switch to AC Wave Mode",
                              ),
                              const SizedBox(width: 4),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                                child: PopupMenuButton<String>(
                                  tooltip: '', 
                                  initialValue: _waveType,
                                  offset: const Offset(40, -145), 
                                  elevation: 0, 
                                  color: Colors.transparent, 
                                  surfaceTintColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                    side: BorderSide.none, 
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_waveType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_drop_up, color: Colors.black54), 
                                      ],
                                    ),
                                  ),
                                  itemBuilder: (context) => ['Sine', 'Cubic', 'Square', 'Randomized']
                                      .map((type) => PopupMenuItem<String>(
                                            value: type,
                                            height: 36,
                                            child: Container(
                                              width: double.infinity,
                                              alignment: Alignment.centerRight, 
                                              child: Text(
                                                type,
                                                style: TextStyle(
                                                  fontSize: 14, 
                                                  fontWeight: _waveType == type ? FontWeight.bold : FontWeight.normal,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onSelected: (val) {
                                    setState(() => _waveType = val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                
                      // WRAP LAYOUT FIX: Dials wrap perfectly without scroll conflicts!
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16.0,
                          runSpacing: 24.0,
                          children: [
                            RotaryDial(
                              label: _isWaveActive ? "Vin Amplitude" : "Vin DC",
                              value: _amplitude,
                              baseMin: _isWaveActive ? 0.1 : -10.0,
                              baseMax: 10.0,
                              stepSize: 0.1,
                              unit: "V",
                              indicatorColor: AppColors.purple,
                              onChanged: (val) => setState(() => _amplitude = val),
                            ),
                            RotaryDial(
                              label: "R1 Resistor",
                              value: _r1,
                              baseMin: 0.1,
                              baseMax: 100.0,
                              stepSize: 1.0,
                              unit: "kΩ",
                              indicatorColor: Colors.blueGrey,
                              onChanged: (val) => setState(() => _r1 = val),
                            ),
                            RotaryDial(
                              label: "R2 Resistor",
                              value: _r2,
                              baseMin: 0.1,
                              baseMax: 100.0,
                              stepSize: 1.0,
                              unit: "kΩ",
                              indicatorColor: Colors.blueGrey,
                              onChanged: (val) => setState(() => _r2 = val),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                
                      StickyNote(
                        color: const Color(0xFFE8F4F8), // Pastel Blue
                        angle: 0.0,
                        child: Column(
                          children: [
                            _buildValueRow("Voltage Gain (Av):", gain.toStringAsFixed(2)),
                            const Divider(color: Colors.black26),
                            _buildValueRow("Vout Voltage:", "${currentVout.toStringAsFixed(2)} V ${_isWaveActive ? '(Out-of-phase)' : ''}"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                
                      // COMPACT RECORD BUTTON
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: () => _recordValuesToTable(gain, currentVout),
                          icon: const Icon(Icons.table_chart, size: 18),
                          label: const Text("TABLE", style: TextStyle(fontSize: 13, letterSpacing: 1.0)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: const Size(0, 36), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                
                      // MERGED RESULT TABLE SECTION
                      if (_tableData.isNotEmpty) ...[
                        const Text(
                          'Result Table: -',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        
                        Scrollbar(
                          controller: _tableScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _tableScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54),
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // MERGED COLUMN ("Type of Amplifier")
                                    Container(
                                      width: 140, 
                                      decoration: const BoxDecoration(
                                        border: Border(right: BorderSide(color: Colors.black54)),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 56, 
                                            alignment: Alignment.center,
                                            decoration: const BoxDecoration(
                                              border: Border(bottom: BorderSide(color: Colors.black54)),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            child: const Text(
                                              'Type of Amplifier', 
                                              textAlign: TextAlign.center, 
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)
                                            ),
                                          ),
                                          const Expanded(
                                            child: Center(
                                              child: Text(
                                                'Inverting', 
                                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // DATA TABLE SECTION
                                    DataTable(
                                      headingRowColor: WidgetStateProperty.all(Colors.transparent), 
                                      headingRowHeight: 56,
                                      dataRowMinHeight: 48,
                                      dataRowMaxHeight: 48,
                                      border: const TableBorder(
                                        horizontalInside: BorderSide(color: Colors.black54),
                                        verticalInside: BorderSide(color: Colors.black54),
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('R1', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('R2', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Input AC Voltage', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Output Voltage', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Theoretical Gain', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Phase', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                                      ],
                                      rows: List.generate(_tableData.length, (index) {
                                        final data = _tableData[index];
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(data['r1']!)),
                                            DataCell(Text(data['r2']!)),
                                            DataCell(Text(data['vin']!)),
                                            DataCell(Text(data['vout']!)),
                                            DataCell(Text(data['gain']!)),
                                            DataCell(Text(data['phase']!)),
                                            DataCell(
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                                onPressed: () => _deleteRow(index),
                                                tooltip: "Delete Row",
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ], 
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }
}

// --- UNION-FIND LOGIC FOR CIRCUIT VALIDATION ---
class DisjointSet {
  late List<int> parent;
  DisjointSet(int size) {
    parent = List.generate(size, (i) => i);
  }
  int find(int i) {
    if (parent[i] == i) return i;
    return parent[i] = find(parent[i]);
  }
  void union(int i, int j) {
    int rootI = find(i);
    int rootJ = find(j);
    if (rootI != rootJ) {
      parent[rootI] = rootJ;
    }
  }
}

class WireConnection {
  final int a;
  final int b;
  WireConnection(this.a, this.b);
}

// --- INTERACTIVE CIRCUIT BUILDER WIDGET FOR INVERTING AMP ---
class CircuitBuilder extends StatefulWidget {
  final Function(String) onCircuitStateChanged;
  final VoidCallback onCircuitRedo;
  final bool isLocked;

  const CircuitBuilder({
    super.key, 
    required this.onCircuitStateChanged, 
    required this.onCircuitRedo,
    this.isLocked = false
  });

  @override
  State<CircuitBuilder> createState() => _CircuitBuilderState();
}

class _CircuitBuilderState extends State<CircuitBuilder> {
  // Configured nodes mapping to an Inverting Amplifier layout
  final List<Offset> nodes = [
    const Offset(30, 120),  // 0: Vin
    const Offset(160, 200), // 1: GND
    const Offset(60, 120),  // 2: R1_Left
    const Offset(140, 120), // 3: R1_Right
    const Offset(160, 60),  // 4: R2_Left
    const Offset(280, 60),  // 5: R2_Right
    const Offset(160, 160), // 6: OpAmp_+ (Non-Inverting Input)
    const Offset(160, 120), // 7: OpAmp_- (Inverting Input)
    const Offset(280, 140), // 8: OpAmp_Output
  ];

  List<WireConnection> wires = [];
  int? dragStartNode;
  Offset? currentDragPos;

  void _handlePanStart(DragStartDetails details) {
    if (widget.isLocked) return;
    for (int i = 0; i < nodes.length; i++) {
      if ((details.localPosition - nodes[i]).distance < 30) {
        setState(() {
          dragStartNode = i;
          currentDragPos = nodes[i];
        });
        break;
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (widget.isLocked || dragStartNode == null) return;
    setState(() {
      currentDragPos = details.localPosition;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (widget.isLocked || dragStartNode == null || currentDragPos == null) return;
    
    int? dropNode;
    for (int i = 0; i < nodes.length; i++) {
      if (i != dragStartNode && (currentDragPos! - nodes[i]).distance < 30) {
        dropNode = i;
        break;
      }
    }

    if (dropNode != null) {
      bool exists = wires.any((w) => 
        (w.a == dragStartNode && w.b == dropNode) || 
        (w.b == dragStartNode && w.a == dropNode));
      
      if (!exists) {
        setState(() {
          wires.add(WireConnection(dragStartNode!, dropNode!));
        });
        _validateCircuit(); 
      }
    }

    setState(() {
      dragStartNode = null;
      currentDragPos = null;
    });
  }

  void _validateCircuit() {
    DisjointSet ds = DisjointSet(9);
    for (var w in wires) {
      ds.union(w.a, w.b);
    }

    // 1. Identify critical shorts for INVERTING Amplifier
    bool isError = false;
    // Vin(0) shorted to GND(1), OpAmp+(6), OpAmp-(7), or Output(8)
    if (ds.find(0) == ds.find(1) || ds.find(0) == ds.find(6) || ds.find(0) == ds.find(7) || ds.find(0) == ds.find(8)) isError = true;
    // GND(1) shorted to OpAmp-(7) or Output(8)
    if (ds.find(1) == ds.find(7) || ds.find(1) == ds.find(8)) isError = true;
    // OpAmp-(7) shorted to Output(8)
    if (ds.find(7) == ds.find(8)) isError = true;

    if (isError) {
      widget.onCircuitStateChanged('error');
      return;
    }

    // 2. Check complete circuit paths for INVERTING Amplifier
    // Vin -> R1_L or R1_R
    bool vinValid = (ds.find(0) == ds.find(2)) || (ds.find(0) == ds.find(3));
    // The *other* side of R1 -> OpAmp-
    bool r1Valid = (ds.find(0) == ds.find(2) && ds.find(3) == ds.find(7)) ||
                   (ds.find(0) == ds.find(3) && ds.find(2) == ds.find(7));
    
    // OpAmp+ -> GND
    bool gndValid = (ds.find(1) == ds.find(6));

    // R2 -> OpAmp- AND Output
    bool r2Valid = (ds.find(4) == ds.find(7) && ds.find(5) == ds.find(8)) ||
                   (ds.find(5) == ds.find(7) && ds.find(4) == ds.find(8));

    if (vinValid && r1Valid && gndValid && r2Valid) {
      widget.onCircuitStateChanged('correct');
    } else {
      widget.onCircuitStateChanged('incomplete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 320,
            height: 240,
            color: Colors.transparent, 
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(320, 240),
                    painter: CircuitPainter(nodes: nodes, wires: wires, dragStart: dragStartNode != null ? nodes[dragStartNode!] : null, dragEnd: currentDragPos),
                  ),
                  ...List.generate(nodes.length, (index) {
                    return Positioned(
                      left: nodes[index].dx - 8,
                      top: nodes[index].dy - 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isLocked ? AppColors.purple.withValues(alpha: 0.15) : Colors.white,
                          border: Border.all(color: widget.isLocked ? AppColors.purple : AppColors.orange, width: 2),
                        ),
                      ),
                    );
                  }),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.replay, color: Colors.redAccent, size: 28),
                      tooltip: "Redo Circuit",
                      onPressed: () {
                        setState(() {
                          wires.clear();
                          dragStartNode = null;
                          currentDragPos = null;
                        });
                        widget.onCircuitStateChanged('incomplete');
                        widget.onCircuitRedo();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CircuitPainter extends CustomPainter {
  final List<Offset> nodes;
  final List<WireConnection> wires;
  final Offset? dragStart;
  final Offset? dragEnd;

  CircuitPainter({required this.nodes, required this.wires, this.dragStart, this.dragEnd});

  void drawText(Canvas canvas, String text, Offset offset, {double size = 12, bool bold = true}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.black87, fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  Path buildResistor(double x, double y) {
    Path p = Path();
    p.moveTo(x, y);
    p.lineTo(x + 5, y - 10);
    p.lineTo(x + 15, y + 10);
    p.lineTo(x + 25, y - 10);
    p.lineTo(x + 35, y + 10);
    p.lineTo(x + 40, y);
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final componentPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final wirePaint = Paint()
      ..color = AppColors.purple
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Op-Amp Body (Shifted to draw Inverting layout properly)
    Path opAmp = Path()..moveTo(180, 100)..lineTo(180, 180)..lineTo(260, 140)..close();
    canvas.drawPath(opAmp, componentPaint);
    drawText(canvas, "+", const Offset(188, 152), size: 18);
    drawText(canvas, "-", const Offset(188, 110), size: 22);

    // Op-Amp Extended Leads
    canvas.drawLine(const Offset(160, 160), const Offset(180, 160), componentPaint); // + lead
    canvas.drawLine(const Offset(160, 120), const Offset(180, 120), componentPaint); // - lead
    canvas.drawLine(const Offset(260, 140), const Offset(280, 140), componentPaint); // out lead

    // Resistor 1 with Leads
    canvas.drawLine(const Offset(60, 120), const Offset(80, 120), componentPaint); 
    canvas.drawPath(buildResistor(80, 120), componentPaint); 
    canvas.drawLine(const Offset(120, 120), const Offset(140, 120), componentPaint); 
    drawText(canvas, "R1", const Offset(95, 95));

    // Resistor 2 with Leads
    canvas.drawLine(const Offset(160, 60), const Offset(200, 60), componentPaint); 
    canvas.drawPath(buildResistor(200, 60), componentPaint); 
    canvas.drawLine(const Offset(240, 60), const Offset(280, 60), componentPaint); 
    drawText(canvas, "R2", const Offset(215, 35));

    // Vin with Lead
    canvas.drawLine(const Offset(10, 120), const Offset(30, 120), componentPaint); 
    drawText(canvas, "Vin", const Offset(5, 100));

    // Ground with Lead
    canvas.drawLine(const Offset(160, 200), const Offset(160, 210), componentPaint); 
    canvas.drawLine(const Offset(150, 210), const Offset(170, 210), componentPaint); 
    canvas.drawLine(const Offset(154, 215), const Offset(166, 215), componentPaint);
    canvas.drawLine(const Offset(158, 220), const Offset(162, 220), componentPaint);
    drawText(canvas, "GND", const Offset(175, 200), size: 12, bold: false);

    // Output Label
    drawText(canvas, "Output", const Offset(290, 132));

    for (var wire in wires) {
      canvas.drawLine(nodes[wire.a], nodes[wire.b], wirePaint);
    }

    if (dragStart != null && dragEnd != null) {
      canvas.drawLine(dragStart!, dragEnd!, wirePaint..color = AppColors.orange.withValues(alpha: 0.8));
    }
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) => true;
}

// ==========================================
// --- FULLY UPGRADED STATEFUL ROTARY DIAL ---
// ==========================================
class RotaryDial extends StatefulWidget {
  final String label;
  final double value;
  final double baseMin;
  final double baseMax;
  final double stepSize;
  final String unit;
  final Color indicatorColor;
  final ValueChanged<double> onChanged;
  final double dialSize;

  const RotaryDial({
    super.key,
    required this.label,
    required this.value,
    required this.baseMin,
    required this.baseMax,
    required this.stepSize,
    required this.unit,
    required this.indicatorColor,
    required this.onChanged,
    this.dialSize = 55.0,
  });

  @override
  State<RotaryDial> createState() => _RotaryDialState();
}

class _RotaryDialState extends State<RotaryDial> {
  Timer? _initialDelayTimer;
  Timer? _periodicTimer;

  // Triggers instantly on press, then rapidly repeats if held down
  void _startHold(double step) {
    _stepValue(step); 
    _initialDelayTimer = Timer(const Duration(milliseconds: 300), () {
      _periodicTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
        _stepValue(step);
      });
    });
  }

  void _stopHold() {
    _initialDelayTimer?.cancel();
    _periodicTimer?.cancel();
  }

  void _stepValue(double step) {
    double currentMax = widget.value > widget.baseMax ? widget.value : widget.baseMax;
    double currentMin = widget.value < widget.baseMin ? widget.value : widget.baseMin;
    double newVal = widget.value + step;
    
    if (widget.label.contains("Resistor") && newVal < 0.1) {
       newVal = 0.1;
    } else if (newVal < currentMin) {
       newVal = currentMin;
    } else if (newVal > currentMax) {
       newVal = currentMax;
    }
    widget.onChanged(newVal);
  }

  Future<void> _showEditDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController(text: widget.value.toStringAsFixed(1));
    String clearText = widget.unit.isNotEmpty ? widget.unit : 'x';

    double? newValue = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, 
          surfaceTintColor: Colors.transparent, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Set ${widget.label}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Enter value',
              suffixIcon: InkWell(
                onTap: () => controller.clear(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Text(clearText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: widget.indicatorColor, width: 2)),
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (val) {
              Navigator.of(context).pop(double.tryParse(val));
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(double.tryParse(controller.text)),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.indicatorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    if (newValue != null) {
      if (widget.label.contains("Resistor") && newValue <= 0) {
        newValue = 0.1;
      }
      widget.onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentMax = widget.value > widget.baseMax ? widget.value : widget.baseMax;
    double currentMin = widget.value < widget.baseMin ? widget.value : widget.baseMin;
    double range = currentMax - currentMin;
    
    // Calculates a smooth continuous step size based on 2% of the range 
    // This allows it to sweep quickly but smoothly while holding the button
    double holdStep = range * 0.02;
    if (holdStep < widget.stepSize) holdStep = widget.stepSize;
    
    double normalized = range == 0 ? 0 : (widget.value - currentMin) / range;
    double angle = -math.pi * 0.75 + (normalized * math.pi * 1.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 4),
        
        GestureDetector(
          onTap: () => _showEditDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black38, style: BorderStyle.solid, width: 1.5)),
            ),
            child: Text(
              '${widget.value.toStringAsFixed(1)}${widget.unit.isNotEmpty ? ' ${widget.unit}' : ''}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HOLD TO DECREMENT ARROW
            GestureDetector(
              onTapDown: (_) => _startHold(-holdStep),
              onTapUp: (_) => _stopHold(),
              onTapCancel: () => _stopHold(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                child: Icon(Icons.keyboard_arrow_left, size: 28, color: widget.indicatorColor.withValues(alpha: 0.9)),
              ),
            ),
            
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              // THIS EXPLICITLY PREVENTS THE PAGE FROM SCROLLING WHEN GRABBING THE DIAL
              onVerticalDragStart: (_) {}, 
              onVerticalDragUpdate: (details) {
                double step = range / 150.0; 
                double newVal = widget.value - (details.delta.dy * step); 
                
                if (widget.label.contains("Resistor") && newVal < 0.1) {
                   newVal = 0.1;
                } else if (newVal < currentMin) {
                   newVal = currentMin;
                } else if (newVal > currentMax) {
                   newVal = currentMax;
                }
                
                widget.onChanged(newVal);
              },
              child: Container(
                width: widget.dialSize,
                height: widget.dialSize,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 3)),
                    BoxShadow(color: Colors.white, blurRadius: 4, offset: Offset(-2, -2)),
                  ],
                  border: Border.all(color: Colors.black12, width: 1.5),
                ),
                child: Transform.rotate(
                  angle: angle,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: widget.indicatorColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // HOLD TO INCREMENT ARROW
            GestureDetector(
              onTapDown: (_) => _startHold(holdStep),
              onTapUp: (_) => _stopHold(),
              onTapCancel: () => _stopHold(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                child: Icon(Icons.keyboard_arrow_right, size: 28, color: widget.indicatorColor.withValues(alpha: 0.9)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DCIcon extends StatelessWidget {
  final Color color;
  const DCIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 18, height: 2.5, color: color),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 4.5, height: 2.5, color: color),
              const SizedBox(width: 2.5),
              Container(width: 4.5, height: 2.5, color: color),
              const SizedBox(width: 2.5),
              Container(width: 4.5, height: 2.5, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

class ACSineIcon extends StatelessWidget {
  final Color color;
  const ACSineIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(painter: ACSinePainter(color: color)),
    );
  }
}

class ACSinePainter extends CustomPainter {
  final Color color;
  ACSinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - 2, paint);

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    
    path.moveTo(w * 0.2, h * 0.5);
    path.cubicTo(w * 0.35, h * 0.15, w * 0.35, h * 0.85, w * 0.5, h * 0.5);
    path.cubicTo(w * 0.65, h * 0.15, w * 0.65, h * 0.85, w * 0.8, h * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniWavePainter extends CustomPainter {
  final double progress;
  final String waveType;
  final double amplitudeFactor;
  final double scale; 
  final Color color;
  final bool isWaveActive;
  final bool isDCValueExplicit;

  MiniWavePainter({
    required this.progress,
    required this.waveType,
    required this.amplitudeFactor,
    required this.scale,
    required this.color,
    this.isWaveActive = true,
    this.isDCValueExplicit = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 0.8;
    
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), axisPaint);

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    double visualScaleFactor = math.pow(1.1, scale).toDouble();
    double baseScale = (height * 0.22) / 5.0; 
    double currentAmp = (amplitudeFactor / visualScaleFactor) * baseScale;
    
    double? endY;

    for (double x = 0; x <= width; x += 1) {
      double t = isWaveActive ? ((x / width) * 2 * math.pi + (progress * 2 * math.pi)) : 0.0;
      double y = 0;

      if (!isWaveActive) {
        y = centerY - currentAmp;
      } else {
        switch (waveType) {
          case 'Cubic':
            y = centerY - currentAmp * (math.sin(t) + 0.3 * math.sin(3 * t));
            break;
          case 'Square':
            y = centerY - currentAmp * (math.sin(t) >= 0 ? 1.0 : -1.0);
            break;
          case 'Randomized':
            double noise = math.sin(t * 3) * math.cos(t * 2) * 1.5;
            y = centerY - currentAmp * (math.sin(t) + noise * 0.4);
            break;
          case 'Sine':
          default:
            y = centerY - currentAmp * math.sin(t);
            break;
        }
      }
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      if (x >= width) {
        endY = y;
      }
    }

    canvas.drawPath(path, linePaint);

    if (endY != null && endY >= 0 && endY <= height) {
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(width, endY), 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MiniWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveType != waveType ||
        oldDelegate.amplitudeFactor != amplitudeFactor ||
        oldDelegate.scale != scale ||
        oldDelegate.color != color ||
        oldDelegate.isWaveActive != isWaveActive ||
        oldDelegate.isDCValueExplicit != isDCValueExplicit;
  }
}

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