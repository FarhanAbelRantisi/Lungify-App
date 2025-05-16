import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import 'package:healthbot_app/models/chat_message.dart';
import 'package:healthbot_app/utils/text_styles.dart';
import 'package:healthbot_app/view/widget/massage_bubble.dart';
import 'package:healthbot_app/services/gemini_service.dart';
import 'package:healthbot_app/services/history_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HealthbotScreen extends StatefulWidget {
  final ChatMessage? initialQuestion;
  final ChatMessage? initialAnswer;
  final bool fromHistory;

  const HealthbotScreen({
    super.key,
    this.initialQuestion,
    this.initialAnswer,
    this.fromHistory = false,
  });

  @override
  _HealthbotScreenState createState() => _HealthbotScreenState();
}

class _HealthbotScreenState extends State<HealthbotScreen> with WidgetsBindingObserver {
  final Logger _logger = Logger('HealthBotScreen');
  final TextEditingController controller = TextEditingController();
  final List<ChatMessage> messages = [];
  final List<ChatMessage> pendingMessages = [];
  bool isLoading = false;
  final GeminiService _geminiService = GeminiService();
  final HistoryService _historyService = HistoryService();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadMessages();
  }

  @override
  void didUpdateWidget(HealthbotScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuestion != widget.initialQuestion ||
        oldWidget.initialAnswer != widget.initialAnswer) {
      print("INFO: ${DateTime.now()}: HealthbotScreen updated with new initial messages");
      _loadMessages();
    }
  }

  void _loadMessages() {
    setState(() {
      messages.clear();
      messages.add(ChatMessage(
        text: "Hello, I'am Lungify! I'am here as your lung health partner!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      if (widget.initialQuestion != null) {
        messages.add(widget.initialQuestion!);
      }
      if (widget.initialAnswer != null) {
        messages.add(widget.initialAnswer!);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _savePendingMessages();
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final ConnectivityResult result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print("ERROR: ${DateTime.now()}: HealthBotScreen: Error checking connectivity: $e");
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });

    if (!_isConnected) {
      print("WARNING: ${DateTime.now()}: HealthBotScreen: No internet connection");
      if (!isLoading) {
        _showSnackBar("No internet connection. Some features may not work.");
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _savePendingMessages() async {
    for (var message in pendingMessages) {
      bool saved = await _historyService.addChatMessage(message);
      if (!saved) {
        print("ERROR: ${DateTime.now()}: Failed to save message: ${message.text}");
      }
    }
    pendingMessages.clear();
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      final userMessage = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());
      messages.add(userMessage);
      pendingMessages.add(userMessage);
      messages.add(ChatMessage(text: "Identifying problems...", isUser: false, timestamp: DateTime.now()));
    });

    if (FirebaseAuth.instance.currentUser == null) {
      try {
        print("INFO: ${DateTime.now()}: HealthBotScreen: No user logged in, attempting anonymous login");
        UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
        print("INFO: ${DateTime.now()}: HealthBotScreen: Anonymous login successful: UID=${userCredential.user?.uid}");
      } catch (e) {
        print("ERROR: ${DateTime.now()}: HealthBotScreen: Anonymous login failed: $e");
        setState(() {
          isLoading = false;
          messages.removeLast();
          messages.add(ChatMessage(text: "Failed login: $e", isUser: false, timestamp: DateTime.now()));
        });
        return;
      }
    }

    try {
      print("INFO: ${DateTime.now()}: HealthBotScreen: Sending message to Gemini: $text");

      String response;
      try {
        response = await _geminiService.getGeminiResponse(text);
        print("INFO: ${DateTime.now()}: HealthBotScreen: Successfully received response from Gemini");
      } catch (e) {
        print("ERROR: ${DateTime.now()}: HealthBotScreen: Error in Gemini response: $e");
        response = "Sorry, there is a problem while processing your request.";
      }

      if (response.isNotEmpty) {
        print("INFO: ${DateTime.now()}: HealthBotScreen: Response length: ${response.length} chars");
        setState(() {
          isLoading = false;
          messages.removeLast();
          final botMessage = ChatMessage(text: response, isUser: false, timestamp: DateTime.now());
          messages.add(botMessage);
          pendingMessages.add(botMessage);
        });
      } else {
        print("WARNING: ${DateTime.now()}: HealthBotScreen: Empty response received");
        setState(() {
          isLoading = false;
          messages.removeLast();
          final errorMessage = ChatMessage(
            text: "Sorry, I can't process your request today.",
            isUser: false,
            timestamp: DateTime.now(),
          );
          messages.add(errorMessage);
          pendingMessages.add(errorMessage);
        });
      }
    } catch (e) {
      print("ERROR: ${DateTime.now()}: HealthBotScreen: Error in sendMessage: $e");
      setState(() {
        isLoading = false;
        messages.removeLast();
        final errorMessage = ChatMessage(
          text: "Problem: $e",
          isUser: false,
          timestamp: DateTime.now(),
        );
        messages.add(errorMessage);
        pendingMessages.add(errorMessage);
      });
    }
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: widget.fromHistory ? false : true,
        title: Image.asset(
          'assets/images/logotext_healthbot2.png',
          height: 20,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: messages.map((msg) => MessageBubble(msg)).toList(),
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFB1B1B1)),
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask HealthBot Anything?',
                        hintStyle: AppTextStyles.interRegular16,
                        border: InputBorder.none,
                      ),
                      onSubmitted: sendMessage,
                    ),
                  ),
                  Image.asset('assets/images/icon_mic.png', width: 35),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => sendMessage(controller.text),
                    child: const Icon(Icons.send, color: Color(0xFF24786D)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}