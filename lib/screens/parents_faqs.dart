import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:audioplayers/audioplayers.dart';

class ParentsFaqs extends StatefulWidget {
  static const routeName = '/ParentsFaqs';

  const ParentsFaqs({Key? key}) : super(key: key);

  @override
  _ParentsFaqsState createState() => _ParentsFaqsState();
}

class _ParentsFaqsState extends State<ParentsFaqs> {
  List<String> faqTypes = [];
  List<dynamic> allFaqs = [];
  List<dynamic> filteredFaqs = [];
  int selectedIndex = 0;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getFaqData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getFaqData() async {
    try {
      var res = await ApiService.getMethod3("/parentsFaqs");
      dynamic d = jsonDecode(res.body);

      if (d["error"] == false) {
        setState(() {
          faqTypes = List<String>.from(d["faq_types"].values);
          allFaqs = d["data"];
          if (faqTypes.isNotEmpty) {
            filterFaqs(faqTypes[0]);
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching FAQs: $e");
      setState(() => isLoading = false);
    }
  }

  void filterFaqs(String selectedType) {
    setState(() {
      filteredFaqs = allFaqs.where((faq) => faq["faq_type"] == selectedType).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0), // Deeper blue for better contrast
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        title: const Text('Parents FAQs', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              getFaqData();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequently Asked',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20.sp,
                        ),
                      ),
                      Text(
                        'Questions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Find answers to common questions from parents',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 3.h, bottom: 2.h),
                          child: faqTypes.isNotEmpty
                              ? SizedBox(
                                  height: 5.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                                    itemCount: faqTypes.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = index;
                                            filterFaqs(faqTypes[index]);
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                                          decoration: BoxDecoration(
                                            color: selectedIndex == index
                                                ? const Color(0xFF1565C0)
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: selectedIndex == index
                                                ? [
                                                    BoxShadow(
                                                      color: const Color(0xFF1565C0).withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 3),
                                                    )
                                                  ]
                                                : null,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            faqTypes[index],
                                            style: TextStyle(
                                              color: selectedIndex == index ? Colors.white : Colors.black87,
                                              fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: filteredFaqs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.question_answer_outlined, size: 15.w, color: Colors.grey),
                                      SizedBox(height: 2.h),
                                      Text(
                                        "No FAQs available",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                                  itemCount: filteredFaqs.length,
                                  itemBuilder: (context, index) {
                                    return FaqCard(
                                      index: index + 1,
                                      question: filteredFaqs[index]["Question"],
                                      answer: filteredFaqs[index]["Answer"],
                                      audioUrl: filteredFaqs[index]["uploads"],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class FaqCard extends StatefulWidget {
  final int index;
  final String question;
  final String answer;
  final String? audioUrl;

  const FaqCard({
    required this.index,
    required this.question,
    required this.answer,
    this.audioUrl,
    Key? key,
  }) : super(key: key);

  @override
  _FaqCardState createState() => _FaqCardState();
}

class _FaqCardState extends State<FaqCard> with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final String baseUrl = "https://careerdefenceacademy.com/includes/parents_faq/";

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Listen for audio duration and position changes
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  void togglePlayPause() async {
    if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
      String fullAudioUrl = "$baseUrl${widget.audioUrl}";

      try {
        if (isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play(UrlSource(fullAudioUrl));
        }
        setState(() {
          isPlaying = !isPlaying;
        });
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.white,
          child: InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
                if (isExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${widget.index}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1565C0),
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.question,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: const Color(0xFF1565C0),
                          size: 6.w,
                        ),
                      ),
                    ],
                  ),
                  SizeTransition(
                    sizeFactor: _animation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 11.w, top: 2.h, right: 2.w),
                          child: Text(
                            widget.answer,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                        if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty)
                          Container(
                            margin: EdgeInsets.only(top: 2.h, left: 11.w),
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.headphones,
                                      size: 4.w,
                                      color: Colors.grey.shade700,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      "Audio Explanation",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11.sp,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.5.h),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: togglePlayPause,
                                      child: Container(
                                        width: 10.w,
                                        height: 10.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1565C0),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF1565C0).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isPlaying ? Icons.pause : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 5.w,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SliderTheme(
                                            data: SliderThemeData(
                                              trackHeight: 0.5.h,
                                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 1.5.w),
                                              overlayShape: RoundSliderOverlayShape(overlayRadius: 2.w),
                                              activeTrackColor: const Color(0xFF1565C0),
                                              inactiveTrackColor: Colors.grey.shade300,
                                              thumbColor: const Color(0xFF1565C0),
                                              overlayColor: const Color(0xFF1565C0).withOpacity(0.2),
                                            ),
                                            child: Slider(
                                              min: 0,
                                              max: _duration.inSeconds.toDouble(),
                                              value: _position.inSeconds.toDouble(),
                                              onChanged: (value) async {
                                                await _audioPlayer.seek(Duration(seconds: value.toInt()));
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  _formatDuration(_position),
                                                  style: TextStyle(
                                                    fontSize: 9.sp,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                Text(
                                                  _formatDuration(_duration),
                                                  style: TextStyle(
                                                    fontSize: 9.sp,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}