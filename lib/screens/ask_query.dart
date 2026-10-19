import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/screens/login.dart';
import 'dart:convert';
import 'package:careerapp/services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';

class AskQuery extends StatefulWidget {
  const AskQuery({Key? key}) : super(key: key);

  @override
  _AskQueryState createState() => _AskQueryState();
}

class _AskQueryState extends State<AskQuery> with TickerProviderStateMixin {
  String? text;
  var user_id = '';
  var user_name = '';
  var data = [];
  late TextEditingController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  late AnimationController _typingAnimationController;
  
  final List<String> avatars = [
    "assets/user2.png",
    "assets/logo.jpg",
  ];
  
  final List<Message> messages = [];
  final rand = Random();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    if (mounted) {
      getUserData();
    }
    
    // Add haptic feedback when typing
    _controller.addListener(() {
      if (_controller.text.isNotEmpty && _controller.text.length % 10 == 0) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  Future<void> chooseFile() async {
    // Placeholder for file picking functionality
    // You would implement the actual file picking here
    
    Fluttertoast.showToast(
      msg: "File attachment coming soon",
      backgroundColor: Colors.blue.shade700,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
    
    // Your existing file upload code would go here
    var request = http.MultipartRequest(
        "POST", Uri.parse('${ApiService.baseUrl}/chatFile'));
    request.fields['user_id'] = user_id;
    request.fields['user_name'] = user_name;
    // request.files.add(await http.MultipartFile.fromPath('file', filePath));
    
    request.send().then((response) {
      http.Response.fromStream(response).then((onValue) {
        try {
          if (kDebugMode) {
            print(onValue);
          }
        } catch (e) {
          // handle exception
        }
      });
    });
  }

  Future<void> getUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      dynamic userData = json.decode(prefs.getString('userData')!);
      user_id = userData["user_id"];
      user_name = userData["user_name"];
      await getData(user_id);
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getData(String id) async {
    try {
      var res = await ApiService.getMethod("/getAppChat?user_id=$id");
      data = jsonDecode(res.body);

      messages.clear();
      for (var i = 0; i < data.length; i++) {
        messages.add(Message(
          int.parse(data[i]["type"]),
          data[i]["message"].toString(),
          data[i]["attachment"].toString(),
          DateTime.now().subtract(Duration(minutes: i * 5)), // Mock timestamp
        ));
      }

      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error loading messages: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Live Support",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => getUserData(),
          ),
        ],
      ),
      body: user_id.isEmpty
          ? _buildLoginPrompt()
          : _isLoading
              ? _buildLoadingIndicator()
              : Column(
                  children: <Widget>[
                    _buildChatHeader(),
                    Expanded(
                      child: _buildMessageList(isDarkMode),
                    ),
                    _buildBottomBar(context, isDarkMode),
                  ],
                ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo.jpg',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Please login to access Live Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Login Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
        FadeInTextSwitcher(
  textList: ['Loading your conversations...', 'Almost there...'],
)

        ],
      ),
    );
  }


  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(avatars[1]),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Support Team",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Online",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("About Live Support"),
                  content: const Text(
                    "Our support team is available to help you with any questions or issues you may have. "
                    "Average response time: 5-10 minutes.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(bool isDarkMode) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.jpg',
              width: 100,
              height: 100,
              opacity: const AlwaysStoppedAnimation(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              "No messages yet",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Start a conversation with our support team",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12.0);
      },
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        Message message = messages[index];
        bool showTimestamp = index == messages.length - 1 || 
                            index == 0 ||
                            messages[index].timestamp.day != messages[index + 1].timestamp.day;
        
        return Column(
          children: [
            if (showTimestamp)
              _buildDateDivider(message.timestamp),
            _buildMessageRow(message, current: message.user == 0, isDarkMode: isDarkMode),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    String dateText;
    if (messageDate == today) {
      dateText = "Today";
    } else if (messageDate == yesterday) {
      dateText = "Yesterday";
    } else {
      dateText = DateFormat('MMMM d, yyyy').format(timestamp);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              dateText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 8.0,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.attach_file_rounded),
            color: Colors.blue,
            onPressed: chooseFile,
          ),
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.send,
              controller: _controller,
              maxLines: null,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                border: InputBorder.none,
                hintText: "Type your message...",
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              onEditingComplete: _save,
            ),
          ),
          AnimatedBuilder(
            animation: _typingAnimationController,
            builder: (context, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: _isSending 
                      ? Colors.grey 
                      : (_controller.text.isEmpty 
                          ? Colors.grey.withOpacity(0.5) 
                          : Colors.blue),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: _controller.text.isEmpty 
                      ? [] 
                      : [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10 * _typingAnimationController.value,
                            spreadRadius: 2,
                          ),
                        ],
                ),
                child: IconButton(
                  icon: _isSending 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  color: Colors.white,
                  onPressed: _controller.text.isEmpty || _isSending ? null : _save,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_controller.text.isEmpty || _isSending) return;

    final messageText = _controller.text;
    setState(() {
      _isSending = true;
      messages.insert(0, Message(0, messageText, '', DateTime.now()));
      _controller.clear();
    });
    
    // Provide immediate feedback
    HapticFeedback.mediumImpact();
    _scrollToBottom();

    var data = json.encode({
      "user_id": user_id,
      "user_name": user_name,
      "message": messageText
    });

    try {
      var response = await ApiService.postMethod(
        '/chat_message',
        data,
      );
      
      if (response["error"] == false) {
        // Message sent successfully
        FocusScope.of(context).requestFocus(FocusNode());
      } else {
        // Show error and revert the message
        Fluttertoast.showToast(
          msg: "Failed to send message. Please try again.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        setState(() {
          messages.removeAt(0);
        });
      }
    } catch (err) {
      // Show error and revert the message
      Fluttertoast.showToast(
        msg: "Network error. Please check your connection.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        messages.removeAt(0);
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Widget _buildMessageRow(Message message, {required bool current, required bool isDarkMode}) {
    final timeString = DateFormat('h:mm a').format(message.timestamp);
    final bubbleColor = current 
        ? Colors.blue.shade600
        : (isDarkMode ? Colors.grey.shade700 : Colors.white);
    final textColor = current 
        ? Colors.white 
        : (isDarkMode ? Colors.white : Colors.black87);
    
    return Row(
      mainAxisAlignment: current ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (!current) ...[
         Padding(
  padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
  child: Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.blue.shade100,
    ),
    child: const Icon(
      Icons.school_rounded, // Student cap icon
      size: 18,
      color: Colors.blue,
    ),
  ),
),

          const SizedBox(width: 8.0),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.only(bottom: 5, right: 5),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: current ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                if (message.description.isNotEmpty)
                  _buildMessageBubble(
                    message.description,
                    current,
                    bubbleColor,
                    textColor,
                  ),
                if (message.file != 'null' && message.file.isNotEmpty)
                  _buildFileBubble(message.file, current, bubbleColor, textColor),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (current) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 12,
                          color: Colors.blue.shade400,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (current) ...[
          const SizedBox(width: 8.0),
         Padding(
  padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
  child: Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.blue.shade100,
    ),
    child: const Icon(
      Icons.school_rounded, // Student cap icon
      size: 18,
      color: Colors.blue,
    ),
  ),
),

        ],
      ],
    );
  }

  Widget _buildMessageBubble(String text, bool current, Color bubbleColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: current
            ? const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )
            : const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildFileBubble(String fileName, bool current, Color bubbleColor, Color textColor) {
    return GestureDetector(
      onTap: () async {
        var path = "${ApiService.websiteUrl}chat_files/$fileName";
        if (await canLaunch(path)) {
          await launch(path);
        } else {
          Fluttertoast.showToast(
            msg: "Cannot open file",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: current
              ? const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(fileName),
              color: textColor.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                fileName,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.download,
              color: textColor.withOpacity(0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class FadeInTextSwitcher extends StatefulWidget {
  final List<String> textList;
  final Duration switchDuration;
  final TextStyle? style;

  const FadeInTextSwitcher({
    Key? key,
    required this.textList,
    this.switchDuration = const Duration(seconds: 2),
    this.style,
  }) : super(key: key);

  @override
  _FadeInTextSwitcherState createState() => _FadeInTextSwitcherState();
}

class _FadeInTextSwitcherState extends State<FadeInTextSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.switchDuration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.textList.length;
          });
          _controller.forward(from: 0.0);
        }
      });

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Text(
        widget.textList[_currentIndex],
        style: widget.style ?? const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}


class Message {
  final int user;
  final String description;
  final String file;
  final DateTime timestamp;

  Message(this.user, this.description, this.file, this.timestamp);
}