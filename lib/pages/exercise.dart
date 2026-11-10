import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:opamp/constants/colors.dart';
import 'package:opamp/pages/index.dart';
import '../widgets/graph_paper_background.dart';

// --- QUESTION DATA MODEL ---
class Question {
  final String questionText;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['questionText'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
    );
  }
}

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<Question> _allQuestions = []; // Stores ALL 50+ questions
  List<Question> _questions = [];    // Stores the active 10 questions
  
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _isAnswerChecked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      // Load JSON from assets
      final String response = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> data = json.decode(response);
      
      setState(() {
        _allQuestions = data.map((json) => Question.fromJson(json)).toList();
        _generateQuizSet(); // Pick a random 10
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading questions: $e");
      setState(() => _isLoading = false);
    }
  }

  // Shuffles the master list and picks exactly 10 questions
  void _generateQuizSet() {
    _allQuestions.shuffle();
    _questions = _allQuestions.take(10).toList();
  }

  void _checkAnswer() {
    if (_selectedIndex == null) return;

    setState(() {
      _isAnswerChecked = true;
      if (_selectedIndex == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _isAnswerChecked = false;
    });
  }

  void _restartQuiz() {
    setState(() {
      _generateQuizSet(); // Grab a completely new random set of 10 questions!
      _currentIndex = 0;
      _score = 0;
      _selectedIndex = null;
      _isAnswerChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: GraphPaperBackground(
          child: const Center(child: CircularProgressIndicator(color: AppColors.purple)),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: GraphPaperBackground(
          child: const Center(
            child: Text("No questions found. Check assets/questions.json", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    bool isQuizFinished = _currentIndex >= _questions.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: isQuizFinished
            ? const Text("Quiz Complete", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentIndex) / _questions.length,
                  minHeight: 10,
                  backgroundColor: Colors.black12,
                  color: AppColors.purple,
                ),
              ),
        centerTitle: true,
      ),
      body: GraphPaperBackground(
        child: SafeArea(
          child: isQuizFinished ? _buildScoreScreen() : _buildQuizScreen(),
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final currentQuestion = _questions[_currentIndex];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Question ${_currentIndex + 1} of ${_questions.length}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                
                // Question Text
                Text(
                  currentQuestion.questionText,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
                ),
                const SizedBox(height: 32),

                // Options List
                ...List.generate(currentQuestion.options.length, (index) {
                  return _buildOptionCard(index, currentQuestion.options[index]);
                }),
              ],
            ),
          ),
        ),
        
        // Bottom Action Area (Feedback & Buttons)
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildOptionCard(int index, String text) {
    bool isSelected = _selectedIndex == index;
    bool isCorrectOption = index == _questions[_currentIndex].correctIndex;

    Color borderColor = Colors.black26;
    Color backgroundColor = Colors.transparent;
    Color textColor = Colors.black87;
    IconData? icon;
    Color iconColor = Colors.transparent;

    if (_isAnswerChecked) {
      if (isCorrectOption) {
        borderColor = Colors.green;
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        iconColor = Colors.green;
      } else if (isSelected && !isCorrectOption) {
        borderColor = Colors.redAccent;
        backgroundColor = Colors.redAccent.withValues(alpha: 0.1);
        textColor = Colors.redAccent.shade700;
        icon = Icons.cancel;
        iconColor = Colors.redAccent;
      }
    } else if (isSelected) {
      borderColor = AppColors.purple;
      backgroundColor = AppColors.purple.withValues(alpha: 0.1);
      textColor = AppColors.purple;
    }

    return GestureDetector(
      onTap: _isAnswerChecked ? null : () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: isSelected || _isAnswerChecked ? 2.5 : 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 18, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: textColor),
              ),
            ),
            if (icon != null) Icon(icon, color: iconColor, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.transparent, // Made transparent to match the graph paper background
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Feedback message
          if (_isAnswerChecked) ...[
            Row(
              children: [
                Icon(
                  _selectedIndex == _questions[_currentIndex].correctIndex ? Icons.check_circle : Icons.cancel,
                  color: _selectedIndex == _questions[_currentIndex].correctIndex ? Colors.green : Colors.redAccent,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedIndex == _questions[_currentIndex].correctIndex ? "Excellent!" : "Not quite right.",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _selectedIndex == _questions[_currentIndex].correctIndex ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Primary Button
          ElevatedButton(
            onPressed: _selectedIndex == null
                ? null
                : (_isAnswerChecked ? _nextQuestion : _checkAnswer),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAnswerChecked 
                  ? (_selectedIndex == _questions[_currentIndex].correctIndex ? Colors.green : Colors.redAccent) 
                  : AppColors.purple,
              disabledBackgroundColor: Colors.black12,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: _selectedIndex == null ? 0 : 2,
            ),
            child: Text(
              _isAnswerChecked ? "CONTINUE" : "CHECK",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreScreen() {
    double percentage = _score / _questions.length;
    String feedbackText;
    Color feedbackColor;

    if (percentage == 1.0) {
      feedbackText = "Perfect Score!";
      feedbackColor = Colors.green;
    } else if (percentage >= 0.7) {
      feedbackText = "Great Job!";
      feedbackColor = AppColors.purple;
    } else {
      feedbackText = "Keep Practicing!";
      feedbackColor = AppColors.orange;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 100, color: feedbackColor),
            const SizedBox(height: 24),
            Text(
              feedbackText,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: feedbackColor),
            ),
            const SizedBox(height: 16),
            Text(
              "You scored $_score out of ${_questions.length}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _restartQuiz,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.purple,
                  side: const BorderSide(color: AppColors.purple, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("RETRY QUIZ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const IndexPage())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("BACK TO INDEX", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}