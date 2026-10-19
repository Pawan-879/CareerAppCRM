import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:confetti/confetti.dart';

class StaffTraining extends StatefulWidget {
  const StaffTraining({Key? key}) : super(key: key);
  static const routeName = '/staff_training';

  @override
  _StaffTrainingState createState() => _StaffTrainingState();
}

class _StaffTrainingState extends State<StaffTraining> 
    with TickerProviderStateMixin, WidgetsBindingObserver {
  List staffTrainingPosts = [];
  var userData;
  var user_id = "";
  var categories = [];
  final List _selectedCategories = [];
  final PageController _pageController = PageController();
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  double _playbackSpeed = 1.0;
  bool _showPlaybackSpeedOptions = false;
  bool _showAudioControls = false;
  
  // Animation controllers
  late AnimationController _animationController;
  late AnimationController _questionAnimationController;
  late AnimationController _answerAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _fadeInController;
  late AnimationController _bounceController;
  
  // Animations
  late Animation<double> _animation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _bounceAnimation;
  
  VideoPlayerController? _videoController;
  int _currentVideoIndex = 0;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _showLoadingIndicator = false;
  
  // Question related variables
  final Map<String, String> _selectedAnswers = {};
  List trainingQuestions = [];
  String _currentPostId = "";
  bool _showQuestions = false;
  int _currentQuestionIndex = 0;
  bool _showAnswerFeedback = false;
  bool _isAnswerCorrect = false;
  String _selectedOption = "";
  int _selectedOptionIndex = -1;
  AudioPlayer? _audioPlayer;
  ConfettiController? _confettiController;

  bool _isAudio = false;
  bool _isAudioPlaying = false;
  bool _isFullScreen = false;
  bool _showMediaControls = true;
  DateTime? _lastInteractionTime;
bool staffLogin = false;
bool consulLogin = false;
bool showStaffTrainingTab = false;

  // Theme colors
  final Color primaryColor = const Color(0xFF0F172A); // Dark slate
  final Color secondaryColor = const Color(0xFF1E40AF); // Deep blue
  final Color accentColor = const Color(0xFFEF4444); // Red
  final Color successColor = const Color(0xFF10B981); // Emerald
  final Color warningColor = const Color(0xFFF59E0B); // Amber
  final Color infoColor = const Color(0xFF3B82F6); // Blue
  final Color backgroundColor = const Color(0xFF0F172A); // Dark background
  final Color surfaceColor = const Color(0xFF1E293B); // Dark surface
  final Color textColor = const Color(0xFFFFFFFF); // White text
  final Color lightTextColor = const Color(0xFF94A3B8); // Light gray
  final Color darkTextColor = const Color(0xFF1E293B); // Dark text

  // Gradient
  final Gradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );


int? restrictedCategoryId;

Future<void> getUserData() async {
  final prefs = await SharedPreferences.getInstance();

  // Always restrict to category_id 47
  restrictedCategoryId = 47;

  if (prefs.containsKey('staffData') && prefs.getString('staffData') != '') {
    var staffData = json.decode(prefs.getString('staffData')!);
    if (staffData["user_id"] != '') {
      staffLogin = true;
    }
    print("Staff Data category_id: ${staffData['category_id']}");
    setState(() {});
  }

  if (prefs.containsKey('consulData') && prefs.getString('consulData') != '') {
    var staffData = json.decode(prefs.getString('consulData')!);
    if (staffData["id"] != '') {
      consulLogin = true;
    }
    print("Consul Data category_id: ${staffData['category_id']}");
    setState(() {});
  }

  // Always show the staff training tab
  showStaffTrainingTab = true;
}

// Extracts the full filename from URL
String getFileNameFromUrl(String url) {
  Uri uri = Uri.parse(url);
  return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'Unknown File';
}

// Cleans the filename by removing UUID-like prefixes
String getCleanAudioName(String url) {
  final fileName = getFileNameFromUrl(url);
  final parts = fileName.split('_');
  if (parts.length >= 3) {
    return parts.sublist(2).join('_'); // Remove first two UUID parts
  }
  return fileName;
}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    
    _initializeAnimations();
    _initializeConfetti();
    getUserData2();
    getStaffTrainingPosts();
    _startInteractionTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseMedia();
    } else if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        _playMedia();
      }
    }
  }

  void _initializeConfetti() {
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _questionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _answerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _answerAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeIn,
    ));

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -15.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -15.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));
    
    _pulseAnimationController.repeat(reverse: true);
    _fadeInController.forward();
  }




  void _startInteractionTimer() {
    _lastInteractionTime = DateTime.now();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && DateTime.now().difference(_lastInteractionTime!) > const Duration(seconds: 3)) {
        setState(() {
          _showMediaControls = false;
        });
      }
    });
  }

  void _recordInteraction() {
    setState(() {
      _lastInteractionTime = DateTime.now();
      _showMediaControls = true;
    });
    _startInteractionTimer();
  }

  void _disposeCurrentAudio() {
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isAudio = false;
    _isAudioPlaying = false;
    _isInitialized = false;
  }

  void _disposeCurrentVideo() {
    if (_videoController != null) {
      _videoController!.pause();
      _videoController!.dispose();
      _videoController = null;
      _isInitialized = false;
    }
  }

  void _initializeVideo(String videoUrl, int index, bool isCurrentTab) {
    if (_currentVideoIndex == index && _videoController != null) {
      return;
    }
    _disposeCurrentVideo();
    _currentVideoIndex = index;
    _videoController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _videoController!.setLooping(true);
          _videoController!.setPlaybackSpeed(_playbackSpeed);
          if (_isPlaying) {
            _videoController!.play();
          }
        });
      });
  }
void _initializeAudio(String audioFileName, int index) async {
  _disposeCurrentVideo();
  _disposeCurrentAudio();

  // ✅ Construct full URL using audio_file from API
  final String audioUrl = Uri.encodeFull(
    "https://careerinstitute.co/$audioFileName",
  );

  setState(() {
    _isAudio = true;
    _isAudioPlaying = true;
    _currentVideoIndex = index;
    _isInitialized = true;
    _showAudioControls = true;
  });

  _audioPlayer = AudioPlayer();

  _audioPlayer!.onDurationChanged.listen((duration) {
    setState(() {
      _audioDuration = duration;
    });
  });

  _audioPlayer!.onPositionChanged.listen((position) {
    setState(() {
      _audioPosition = position;
    });
  });

  _audioPlayer!.onPlayerComplete.listen((event) {
    setState(() {
      _isAudioPlaying = false;
      _audioPosition = _audioDuration;
    });
  });

  try {
    await _audioPlayer!.play(UrlSource(audioUrl));
    debugPrint("Playing audio from: $audioUrl");
  } catch (e) {
    debugPrint("Audio play failed: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Error playing audio"),
        backgroundColor: accentColor,
      ),
    );
  }
}





  void _togglePlayPause() {
    _recordInteraction();
    setState(() {
      _isPlaying = !_isPlaying;

      if (_isAudio) {
        _isAudioPlaying = _isPlaying;
        if (_isPlaying) {
          _audioPlayer?.resume();
        } else {
          _audioPlayer?.pause();
        }
      } else {
        if (_isPlaying) {
          _videoController?.play();
          _animationController.reverse();
        } else {
          _videoController?.pause();
          _animationController.forward();
        }
      }
    });
  }

  void _togglePlaybackSpeed() {
    _recordInteraction();
    setState(() {
      _showPlaybackSpeedOptions = !_showPlaybackSpeedOptions;
    });
  }

  void _changePlaybackSpeed(double speed) {
    _recordInteraction();
    setState(() {
      _playbackSpeed = speed;
      _showPlaybackSpeedOptions = false;
      if (_videoController != null) {
        _videoController!.setPlaybackSpeed(_playbackSpeed);
      }
    });
  }

  void _toggleFullScreen() {
    _recordInteraction();
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _playMedia() {
    if (_isAudio) {
      _audioPlayer?.resume();
    } else {
      _videoController?.play();
    }
  }

  void _pauseMedia() {
    if (_isAudio) {
      _audioPlayer?.pause();
    } else {
      _videoController?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCurrentVideo();
    _pageController.dispose();
    _animationController.dispose();
    _questionAnimationController.dispose();
    _answerAnimationController.dispose();
    _pulseAnimationController.dispose();
    _fadeInController.dispose();
    _bounceController.dispose();
    _disposeCurrentAudio();
    _confettiController?.dispose();
    super.dispose();
  }

Future<void> getUserData2() async {
  final prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('userData')) {
    debugPrint("❌ 'userData' key not found in SharedPreferences.");
    return;
  }

  final rawData = prefs.getString('userData');
  if (rawData == null || rawData.trim().isEmpty) {
    debugPrint("⚠️ 'userData' is empty or null.");
    return;
  }

  try {
    final data = json.decode(rawData);
    debugPrint("✅ Decoded userData: $data");

    userData = data;
    user_id = userData["user_id"]?.toString() ?? "";
    
    if (user_id.isEmpty) {
      debugPrint("⚠️ 'user_id' is missing or empty in userData.");
    } else {
      debugPrint("🔐 Loaded user_id from shared preferences: $user_id");
    }

    setState(() {}); // trigger rebuild
  } catch (e) {
    debugPrint("❌ Failed to decode userData: $e");
  }
}



Future<void> getStaffTrainingPosts() async {
  setState(() {
    _isLoading = true;
    _showLoadingIndicator = true;
  });

  try {
    var res = await ApiService.getMethod("/getStaffTrainingPosts");
    var body = jsonDecode(res.body);

    if (body['status'] == '1') {
      List allPosts = body['detail'];

      // 👉 Filter only for staff with category_id == 47
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('staffData')) {
        final staffData = json.decode(prefs.getString('staffData')!);
        if (staffData["category_id"].toString() == "47") {
          allPosts = allPosts
              .where((item) => item["post_category_id"].toString().toLowerCase() == "sales")
              .toList();
        }
      }

      setState(() {
        staffTrainingPosts = allPosts;

        final seenCategories = <String>{};
        categories = staffTrainingPosts
            .where((item) => seenCategories.add(item["post_category_id"]))
            .map((item) => {
                  'id': item["post_category_id"],
                  'category_name': item["post_category_name"] ?? item["post_category_id"],
                })
            .toList();

        _isLoading = false;
        _showLoadingIndicator = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _showLoadingIndicator = false;
      });
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
      _showLoadingIndicator = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to load training posts: $e'),
        backgroundColor: accentColor,
      ),
    );
  }
}



  Future<void> getStaffTrainingQuestions(String postId) async {
    setState(() {
      trainingQuestions = [];
      _selectedAnswers.clear();
      _currentQuestionIndex = 0;
      _showQuestions = false;
    });
    
    try {
      var res = await ApiService.getMethod("/getStaffTrainingQuestions2?post_id=$postId");
      var body = jsonDecode(res.body);
      
      if (body['status'] == '1') {
        setState(() {
          trainingQuestions = body['detail'];
          _currentPostId = postId;
        });
      } else {
        setState(() {
          trainingQuestions = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load questions: $e'),
          backgroundColor: accentColor,
        ),
      );
    }
  }


Future<void> _submitTrainingResult({
  required String userId,
  required String postId,
  required int correct,
  required int wrong,
  required double percentage,
  required bool passed,
}) async {
  // if (userId.isEmpty || postId.isEmpty) {
  //   debugPrint("❌ Cannot submit result: userId or postId is empty");
  //   return;
  // }

  // 🔍 Print each parameter before constructing the payload
  debugPrint("🧾 Preparing to submit training result:");
  debugPrint("🆔 userId: $userId");
  debugPrint("🧾 postId: $postId");
  debugPrint("✅ correct_answers: $correct");
  debugPrint("❌ wrong_answers: $wrong");
  debugPrint("📊 score_percentage: ${percentage.toStringAsFixed(2)}%");
  debugPrint("🏁 is_passed: ${passed ? 'Yes' : 'No'}");

  final payload = jsonEncode({
    'user_id': userId,
    'post_id': postId,
    'correct_answers': correct,
    'wrong_answers': wrong,
    'score_percentage': percentage,
    'is_passed': passed ? 1 : 0,
  });

  debugPrint("📤 Submitting training result payload: $payload");

  try {
    final response = await ApiService.postMethod4('Api/addTrainingResult', payload);

    debugPrint("📥 Response from training result API: $response");

    if (response['status'] == '1') {
      debugPrint("✅ Training result saved successfully");
    } else {
      debugPrint("❌ Failed to save result: ${response['response']}");
    }
  } catch (e) {
    debugPrint("❌ Error submitting result: $e");
  }
}




  void _showQuestionsOverlay() {
    _recordInteraction();
    if (trainingQuestions.isEmpty) return;
    
    setState(() {
      _showQuestions = true;
      _showAnswerFeedback = false;
      _selectedOption = "";
      _selectedOptionIndex = -1;
    });
    _questionAnimationController.forward();
  }

  void _hideQuestionsOverlay() {
    _questionAnimationController.reverse().then((_) {
      setState(() {
        _showQuestions = false;
        _showAnswerFeedback = false;
      });
    });
  }

  void _selectAnswer(String option, int index) {
    if (_showAnswerFeedback) return;

    _recordInteraction();
    setState(() {
      _selectedOption = option;
      _selectedOptionIndex = index;
      _showAnswerFeedback = true;
    });

    final question = trainingQuestions[_currentQuestionIndex];
    int correctAnswerIndex = int.tryParse(question["correct_answer"] ?? "0") ?? 0;
    String correctOptionText = question["option_$correctAnswerIndex"];
    _isAnswerCorrect = option == correctOptionText;

    _selectedAnswers[question["id"]] = option;
    _answerAnimationController.forward();

    if (_isAnswerCorrect) {
      _bounceController.forward();
      _confettiController?.play();
    }
  }

  void _nextQuestion() {
    _recordInteraction();
    _answerAnimationController.reset();

    if (_currentQuestionIndex < trainingQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showAnswerFeedback = false;
        _selectedOption = "";
        _selectedOptionIndex = -1;
      });
      _questionAnimationController.reset();
      _questionAnimationController.forward();
    }
  }

  void _showResultDialog() {
    int correctAnswers = 0;
    int wrongAnswers = 0;

    for (var question in trainingQuestions) {
      String questionId = question["id"];
      String selectedAnswer = _selectedAnswers[questionId] ?? "";
      int correctAnswerIndex = int.tryParse(question["correct_answer"] ?? "0") ?? 0;
      String correctOptionText = question["option_$correctAnswerIndex"];
      if (selectedAnswer == correctOptionText) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }
    }

    double percentage = (correctAnswers / trainingQuestions.length) * 100;
    bool isPassed = percentage >= 70;

   _submitTrainingResult(
    userId: user_id,
    postId: _currentPostId,
    correct: correctAnswers,
    wrong: wrongAnswers,
    percentage: percentage,
    passed: isPassed,
  );


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [surfaceColor, primaryColor],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isPassed
                                  ? [successColor, const Color(0xFF6EE7B7)]
                                  : [warningColor, const Color(0xFFFCD34D)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isPassed ? successColor : warningColor)
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            isPassed ? Icons.celebration : Icons.thumb_up,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: ConfettiWidget(
                            confettiController: _confettiController!,
                            blastDirectionality: BlastDirectionality.explosive,
                            shouldLoop: false,
                            colors: const [
                              Colors.green,
                              Colors.blue,
                              Colors.pink,
                              Colors.orange,
                              Colors.purple
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isPassed ? "Congratulations!" : "Good Effort!",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "You scored $correctAnswers out of ${trainingQuestions.length}",
                      style: TextStyle(
                        fontSize: 18,
                        color: lightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 150,
                      height: 150,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPassed ? successColor : warningColor,
                          width: 5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "${percentage.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? successColor : warningColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _selectedAnswers.clear();
                            _currentQuestionIndex = 0;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPassed ? successColor : warningColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          isPassed ? "Continue Learning" : "Try Again",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void myfilter() {
    setState(() {
      if (_selectedCategories.isEmpty) {
        getStaffTrainingPosts();
      } else {
        staffTrainingPosts = staffTrainingPosts
            .where((item) => _selectedCategories.contains(item['post_category_id']))
            .toList();
      }
    });
  }

  Widget _buildFilterButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: () => showFilterDialog(context),
            icon: const Icon(FontAwesomeIcons.filter, size: 16),
            label: const Text("Filter"),
            backgroundColor: accentColor,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioControls() {
    double progress = _audioDuration.inMilliseconds == 0
        ? 0
        : _audioPosition.inMilliseconds / _audioDuration.inMilliseconds;

    return AnimatedOpacity(
      opacity: _showAudioControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Positioned(
        bottom: 0,
        left: 20,
        right: 20,
        child: Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white30,
                thumbColor: Colors.white,
                overlayColor: Colors.white.withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: progress,
                onChanged: (value) {
                  final newPosition = Duration(
                    milliseconds: (_audioDuration.inMilliseconds * value).round(),
                  );
                  _audioPlayer?.seek(newPosition);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_audioPosition),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    _formatDuration(_audioDuration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildPlaybackSpeedOptions() {
    return AnimatedOpacity(
      opacity: _showPlaybackSpeedOptions ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Positioned(
        right: 20,
        bottom: 180,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                _buildSpeedOption(0.5),
                const Divider(color: Colors.white24, height: 8),
                _buildSpeedOption(0.75),
                const Divider(color: Colors.white24, height: 8),
                _buildSpeedOption(1.0),
                const Divider(color: Colors.white24, height: 8),
                _buildSpeedOption(1.25),
                const Divider(color: Colors.white24, height: 8),
                _buildSpeedOption(1.5),
                const Divider(color: Colors.white24, height: 8),
                _buildSpeedOption(2.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedOption(double speed) {
    return GestureDetector(
      onTap: () => _changePlaybackSpeed(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${speed}x',
              style: TextStyle(
                color: _playbackSpeed == speed ? accentColor : Colors.white,
                fontSize: 16,
                fontWeight: _playbackSpeed == speed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (_playbackSpeed == speed)
              const Icon(Icons.check, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeIndicator(bool isAudio) {
    return Positioned(
      top: 60,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isAudio ? Icons.audiotrack : Icons.videocam,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isAudio ? "Audio Lesson" : "Video Lesson",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: _isFullScreen ? null : _buildAppBar(),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showMediaControls = true;
          });
          _startInteractionTimer();
        },
        child: Stack(
          children: [
            _isLoading ? _buildLoadingView() : _buildBody(),
            if (_showQuestions && trainingQuestions.isNotEmpty)
              _buildQuestionOverlay(),
            if (_isAudio) _buildAudioControls(),
            if (_isAudio || _isInitialized) _buildPlaybackSpeedOptions(),
            if (_isAudio || _isInitialized) _buildMediaControls(),
            if (_isAudio || _isInitialized) _buildMediaTypeIndicator(_isAudio),
            if (_showLoadingIndicator) _buildLoadingIndicator(),
          ],
        ),
      ),
      // floatingActionButton: _isFullScreen ? null : _buildFilterButton(),
    );
  }

  Widget _buildMediaControls() {
    return AnimatedOpacity(
      opacity: _showMediaControls ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          if (!_isFullScreen)
            Container(
              height: kToolbarHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.9),
                    primaryColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.0),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: _toggleFullScreen,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.speed, color: Colors.white),
                  onPressed: _togglePlaybackSpeed,
                ),
                if (trainingQuestions.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.quiz, color: Colors.white),
                    onPressed: _showQuestionsOverlay,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: surfaceColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
              strokeWidth: 4,
            ),
            const SizedBox(height: 16),
            Text(
              "Loading...",
              style: TextStyle(
                color: lightTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.9),
              primaryColor.withOpacity(0.0),
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              FontAwesomeIcons.graduationCap,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Staff Training",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: getStaffTrainingPosts,
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, secondaryColor],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: surfaceColor,
              highlightColor: Colors.white30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Shimmer.fromColors(
              baseColor: surfaceColor,
              highlightColor: Colors.white30,
              child: Container(
                width: 200,
                height: 24,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Shimmer.fromColors(
              baseColor: surfaceColor,
              highlightColor: Colors.white30,
              child: Container(
                width: 160,
                height: 16,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return staffTrainingPosts.isEmpty
        ? _buildEmptyView()
        : _buildShortsView(staffTrainingPosts);
  }

  Widget _buildEmptyView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, secondaryColor],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                FontAwesomeIcons.video,
                size: 60,
                color: lightTextColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "No training content available",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Check back later for new training materials",
              style: TextStyle(
                fontSize: 16,
                color: lightTextColor,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: getStaffTrainingPosts,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortsView(List posts) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: posts.length,
      onPageChanged: (index) {
        final post = posts[index];

        _disposeCurrentVideo();
        _disposeCurrentAudio();

        if (post['media_type'] == 'video') {
          _initializeVideo(post['video_url'], index, true);
        } else if (post['media_type'] == 'audio' && post['audio_file']?.isNotEmpty == true) {
          _initializeAudio(post['audio_file'], index);
        }

        if (post["id"] != null && post["id"] != _currentPostId) {
          getStaffTrainingQuestions(post["id"]);
        }

        setState(() {
          _isPlaying = true;
          _showQuestions = false;
          _showMediaControls = true;
        });
        _startInteractionTimer();
      },
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildShortsItem(post, index);
      },
    );
  }

  Widget _buildShortsItem(dynamic post, int index) {
    bool isVideo = post['media_type'] == 'video';
    bool isCurrentVideo = _currentVideoIndex == index && isVideo;

    if (index == 0 && isVideo && !_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeVideo(post["video_url"], index, true);
      });
    }

    if (index == 0 && post["id"] != null && _currentPostId != post["id"]) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getStaffTrainingQuestions(post["id"]);
      });
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor,
                secondaryColor,
              ],
            ),
          ),
        ),
        
        // Content (video or image)
       isVideo && isCurrentVideo && _isInitialized
    ? ClipRRect(
        borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 20),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      )
    : _isAudio
        ? Container(
            margin: EdgeInsets.all(_isFullScreen ? 0 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 20),
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          )
        : Hero(
            tag: 'training_${post["id"]}',
            child: Container(
              margin: EdgeInsets.all(_isFullScreen ? 0 : 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 20),
                child: CachedNetworkImage(
                  imageUrl: ApiService.websiteUrl2 + post["image"],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: surfaceColor,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: surfaceColor,
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    ),
                  ),
                ),
              ),
            ),
          ),


        // Content info overlay (only shown when not fullscreen)
        if (!_isFullScreen)
          Positioned(
            left: 20,
            right: 20,
            bottom: 120,
            child: AnimatedBuilder(
              animation: _fadeInAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeInAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _fadeInAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post["title"] ?? "Training Content",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (post["description"] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            post["description"],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (_isAudio && post["audio_file"] != null)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      getCleanAudioName(post["audio_file"]),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontStyle: FontStyle.italic,
      ),
    ),
  ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (trainingQuestions.isNotEmpty && post["id"] == _currentPostId)
                    Center(
                      child: AnimatedBuilder(
                        animation: _bounceAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _bounceAnimation.value),
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [secondaryColor, accentColor],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: secondaryColor.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _showQuestionsOverlay,
                            icon: const Icon(FontAwesomeIcons.brain, size: 18),
                            label: Text("Quiz (${trainingQuestions.length})"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionOverlay() {
    if (trainingQuestions.isEmpty || _currentQuestionIndex >= trainingQuestions.length) {
      return Container();
    }

    final question = trainingQuestions[_currentQuestionIndex];
    final options = [
      question["option_1"],
      question["option_2"],
      question["option_3"],
      question["option_4"],
    ].where((opt) => opt != null && opt.isNotEmpty).toList();

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.95 * _fadeAnimation.value),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Header with close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: secondaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: secondaryColor),
                              ),
                              child: Text(
                                "Question ${_currentQuestionIndex + 1}/${trainingQuestions.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _hideQuestionsOverlay,
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Progress bar
                        // LiquidLinearProgressIndicator(
                        //   value: (_currentQuestionIndex + 1) / trainingQuestions.length,
                        //   valueColor: AlwaysStoppedAnimation(secondaryColor),
                        //   backgroundColor: Colors.white24,
                        //   borderRadius: 2,
                        //   direction: Axis.horizontal,
                        //   center: Text(
                        //     "${((_currentQuestionIndex + 1) / trainingQuestions.length * 100).toStringAsFixed(0)}%",
                        //     style: const TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 10,
                        //     ),
                        //   ),
                        // ),
                        
                        const SizedBox(height: 16),
                        
                        // Question container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question["question"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (question["description"] != null && question["description"].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    question["description"],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Options
                        Expanded(
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options[index];
                              final optionLabel = String.fromCharCode(65 + index);
                              bool isSelected = _selectedOptionIndex == index;
                              bool showFeedback = _showAnswerFeedback && isSelected;
                              int correctAnswerIndex = int.tryParse(question["correct_answer"] ?? "0") ?? 0;
                              String correctOptionText = question["option_$correctAnswerIndex"];
                              bool isCorrect = option == correctOptionText;
                              
                              Color bgColor = Colors.white.withOpacity(0.1);
                              Color borderColor = Colors.white24;
                              Color textColor = Colors.white;
                              
                              if (showFeedback) {
                                bgColor = isCorrect 
                                    ? successColor.withOpacity(0.2)
                                    : accentColor.withOpacity(0.2);
                                borderColor = isCorrect ? successColor : accentColor;
                                textColor = isCorrect ? successColor : accentColor;
                              } else if (isSelected) {
                                bgColor = Colors.white.withOpacity(0.2);
                                borderColor = Colors.white;
                              }
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AnimatedBuilder(
                                  animation: _scaleAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: showFeedback ? _scaleAnimation.value : 1.0,
                                      child: GestureDetector(
                                        onTap: () => _selectAnswer(option, index),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: borderColor,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: showFeedback
                                                      ? (isCorrect ? successColor : accentColor)
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: showFeedback
                                                        ? (isCorrect ? successColor : accentColor)
                                                        : Colors.white54,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: showFeedback
                                                      ? Icon(
                                                          isCorrect ? Icons.check : Icons.close,
                                                          color: Colors.white,
                                                          size: 18,
                                                        )
                                                      : Text(
                                                          optionLabel,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Text(
                                                  option,
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Next/Submit button
                       if (_showAnswerFeedback)
  Padding(
    padding: const EdgeInsets.only(bottom: 16), // <-- Bottom padding added here
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_currentQuestionIndex < trainingQuestions.length - 1) {
            _nextQuestion();
          } else {
            _hideQuestionsOverlay();
            _showResultDialog();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _isAnswerCorrect ? successColor : accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
        child: Text(
          _currentQuestionIndex < trainingQuestions.length - 1
              ? "Next Question"
              : "View Results",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),

                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [surfaceColor, primaryColor],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 50,
                    height: 6,
                    decoration: BoxDecoration(
                      color: lightTextColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.filter,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Filter Training Content",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(color: Colors.white24),
                  
                  // Category selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.category, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Select Categories",
                          style: TextStyle(
                            color: lightTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${_selectedCategories.length} selected",
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: categories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.category,
                                  size: 50,
                                  color: lightTextColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No categories available",
                                  style: TextStyle(
                                    color: lightTextColor,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = _selectedCategories.contains(category['id']);
                              
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isSelected 
                                        ? [secondaryColor.withOpacity(0.3), secondaryColor.withOpacity(0.1)]
                                        : [surfaceColor, surfaceColor.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? secondaryColor : Colors.white24,
                                    width: 2,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  activeColor: secondaryColor,
                                  checkColor: Colors.white,
                                  value: isSelected,
                                  onChanged: (bool? selected) {
                                    setModalState(() {
                                      if (selected == true) {
                                        _selectedCategories.add(category['id']);
                                      } else {
                                        _selectedCategories.remove(category['id']);
                                      }
                                    });
                                  },
                                  title: Text(
                                    category['category_name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? secondaryColor : textColor,
                                    ),
                                  ),
                                  secondary: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isSelected 
                                            ? [secondaryColor, accentColor]
                                            : [Colors.grey[600]!, Colors.grey[700]!],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      FontAwesomeIcons.layerGroup,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  // Action buttons
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedCategories.clear();
                              });
                              getStaffTrainingPosts();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Reset",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              myfilter();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Apply Filters",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}