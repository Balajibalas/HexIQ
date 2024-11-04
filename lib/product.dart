import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class ProductPage extends StatefulWidget {
  final int userId;

  ProductPage({required this.userId});

  @override
  _ProductPageState createState() => _ProductPageState();
}


class _ProductPageState extends State<ProductPage> {
  bool _quizCompleted = false;
  List<int> _selectedOptions = [];
  int _totalQuestions = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Person Page'),
      ),
      body: _quizCompleted
          ? Column(
              children: [
                Expanded(child: _buildResultSection()), // Display result
                ElevatedButton(
                  onPressed: _restartQuiz, // Restart button
                  child: Text('Restart Analysis'),
                ),
              ],
            )
          : Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        onQuizComplete: _handleQuizCompletion, // Pass callback
                      ),
                    ),
                  );
                },
                child: Text('Start Analysis'),
              ),
            ),
    );
  }

  // Callback to handle quiz completion and store the result
  void _handleQuizCompletion(List<int> selectedOptions, int totalQuestions) {
    setState(() {
      _quizCompleted = true;
      _selectedOptions = selectedOptions;
      _totalQuestions = totalQuestions;
    });
  }

  // Method to restart the quiz
  void _restartQuiz() {
    setState(() {
      _quizCompleted = false;
      _selectedOptions = [];
      _totalQuestions = 0;
    });
  }

  // Method to build the result section
  Widget _buildResultSection() {
    // Values for each question
    final Map<String, List<double>> _questionValues = {
       'Q1': [0.4, 0.6, 0.35, 0.0],
      'Q2': [0.8, 0.6, 0.4, 0.0],
      'Q3': [0.3, 0.2, 0.1, 0.0],
    };

    double totalValue = 0.0;
    double maxValue = _questionValues.values.expand((x) => x).reduce((a, b) => a + b);

  // Calculate the total value before building the UI
  for (int index = 0; index < _totalQuestions; index++) {
    String questionKey = 'Q${index + 1}';
    int selectedIndex = _selectedOptions[index];
    
    // Check if the selected index is valid
    if (selectedIndex != -1) {
      double selectedValue = _questionValues[questionKey]![selectedIndex];
      totalValue += selectedValue;

      // Print details for debugging
      //print('Question ${index + 1}: Selected Option ${selectedIndex + 1}, Value: $selectedValue');
    } 
  }
  double progressValue = totalValue / maxValue;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _totalQuestions,
            itemBuilder: (context, index) {
              String questionKey = 'Q${index + 1}';
              double selectedValue = _questionValues[questionKey]![_selectedOptions[index]];
              totalValue += selectedValue;

              return ListTile(
                title: Text('Question ${index + 1}: Selected Option ${_selectedOptions[index] + 1}'),
                subtitle: Text('Value: $selectedValue'),
              );
            },
          ),
        ),
        Text(
          'Your Carbon Footprint: ${totalValue }',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10), // Add some space between the text and progress bar
     Container(
      width: 350, // Set the desired width of the progress bar
      child: LinearProgressIndicator(
        value: progressValue, // Set the progress value
        minHeight: 20, // Height of the progress bar
        backgroundColor: Colors.grey.shade300, // Background color of the bar
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Color of the progress indicator
      ),
    ),
      SizedBox(height: 10), // Add some space after the progress bar
      Text(
        '${(progressValue * 100).toStringAsFixed(1)}% of Max Carbon Footprint', // Display percentage
        style: TextStyle(fontSize: 16),
      ),
      ],
    );
  }
}

class QuestionNode {
  String questionText;
  List<String> options;
  List<String> descriptions;
  String videoPath;
  QuestionNode? next;
  QuestionNode? prev;

  QuestionNode({
    required this.questionText,
    required this.options,
    required this.descriptions,
    required this.videoPath,
    this.next,
    this.prev,
  });
}

class QuizScreen extends StatefulWidget {
  final Function(List<int>, int) onQuizComplete; // Callback for quiz completion

  QuizScreen({required this.onQuizComplete});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late VideoPlayerController _videoController;
  QuestionNode? _currentQuestion;
  int _questionIndex = 0;
  List<int> _selectedOptions = [];
  int _totalQuestions = 0;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
    _loadVideo();
  }

  void _initializeQuiz() {
   QuestionNode q1 = QuestionNode(
      questionText: 'What type of electronic device do you most frequently buy?',
      options: ['Smartphone','Laptop',' Tablet','None'],
      descriptions: [
        'Small, frequent upgrades, high production emissions.',
        'Higher resource use, longer-lasting than smartphones.',
        'Moderate resource use, typically replaced every few years.',
        'No electronic purchases, zero carbon impact.',
      ],
      videoPath: 'assets/videos/video1.mp4',
    );
    QuestionNode q2 = QuestionNode(
      questionText: 'How often do you purchase new furniture?',
      options: ['Every 6 months','Every year','Every 2 years','Rarely or never'],
      descriptions: ['Frequent purchases, high waste and emissions.',
        'Regular replacements, moderate emissions.',
        'Less frequent, lower impact.',
        'No regular purchases, minimal emissions.'
      ],
      videoPath: 'assets/videos/video2.mp4',
    );
    QuestionNode q3 = QuestionNode(
      questionText: 'How often do you buy cosmetics or personal care products?',
      options: ['Every month','Every 6 months','Once a year','None'],
      descriptions: [
        'Frequent purchases, high resource consumption.',
        'Low frequency, lower resource use.',
        'Minimal purchases, minimal environmental impact.',
        'No cosmetic purchases, zero emissions.',
      ],
      videoPath: 'assets/videos/video3.mp4',

    );

    q1.next = q2;
    q2.prev = q1;
    q2.next = q3;
    q3.prev = q2;

    _currentQuestion = q1;
    _totalQuestions = 3;
    _selectedOptions = List<int>.filled(_totalQuestions, -1);
  }

  void _loadVideo() {
    if (_currentQuestion != null) {
      _videoController = VideoPlayerController.asset(_currentQuestion!.videoPath)
        ..initialize().then((_) {
          setState(() {
            _videoController.play();
            _videoController.setLooping(true);
            _videoController.setVolume(0);
          });
        });
    }
  }

  void _nextQuestion() {
    if (_currentQuestion?.next != null) {
      setState(() {
        _videoController.dispose();
        _currentQuestion = _currentQuestion?.next;
        _questionIndex++;
        _expandedIndex = null;
        _loadVideo();
      });
    } else {
      _submitQuiz();
    }
  }

  void _prevQuestion() {
    if (_currentQuestion?.prev != null) {
      setState(() {
        _videoController.dispose();
        _currentQuestion = _currentQuestion?.prev;
        _questionIndex--;
        _expandedIndex = null;
        _loadVideo();
      });
    }
  }

  void _submitQuiz() {
    widget.onQuizComplete(_selectedOptions, _totalQuestions);
    Navigator.pop(context); // Return to the home page after submitting
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make the app bar transparent
        elevation: 0, // Remove the shadow under the app bar
        title: Text('Question ${_questionIndex + 1}', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _questionIndex > 0 ? _prevQuestion : null,
        ),
      ),
      body: Stack(
        children: [
          if (_videoController.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
          Column(
            children: [
              Expanded(
                child: _currentQuestion != null
                    ? _buildQuestionPage(_currentQuestion!, _questionIndex)
                    : Center(child: CircularProgressIndicator()),
              ),
              Opacity(
                opacity: _selectedOptions[_questionIndex] != -1 ? 1.0 : 0.9, // Full opacity if selected, else translucent
                child: ElevatedButton(
                  onPressed: _selectedOptions[_questionIndex] != -1 ? _nextQuestion : null, // Disabled if no option selected
                  child: Text(_currentQuestion?.next != null ? 'Next Question' : 'Submit Analysis'),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(QuestionNode question, int index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 100),
              Container(
                width: 250,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  question.questionText,
                  style: TextStyle(fontSize: 22, color: Colors.black),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight, // Aligns to the bottom right
            child: Container(
              width: 300,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Adjust size based on content
                children: [
                  for (int i = 0; i < question.options.length; i++)
                    _buildOption(
                      index: i,
                      option: question.options[i],
                      description: question.descriptions[i],
                      isExpanded: _expandedIndex == i,
                      onTap: () {
                        setState(() {
                          _selectedOptions[_questionIndex] = i;
                          _expandedIndex = _expandedIndex == i ? null : i;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required int index,
    required String option,
    required String description,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Text(
                  option,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                Spacer(),
                Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.black),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
      ],
    );
  }
}
