import 'package:flutter/material.dart';
import 'package:healthbot_app/view/screen/feature/home_screen.dart';
import 'package:healthbot_app/view/screen/feature/article_screen.dart';
import 'package:healthbot_app/view/screen/feature/healthbot_screen.dart';
import 'package:healthbot_app/view/screen/feature/reminder_screen.dart';
import 'package:healthbot_app/view/screen/feature/history_screen.dart';
import 'package:healthbot_app/view/widget/navbar.dart';
import 'package:healthbot_app/models/chat_message.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  ChatMessage? _selectedQuestion;
  ChatMessage? _selectedAnswer;
  UniqueKey _healthbotKey = UniqueKey();

  void _navigateToTab(int index, {ChatMessage? question, ChatMessage? answer}) {
    print("INFO: ${DateTime.now()}: Navigating to tab $index, question: ${question?.text}, answer: ${answer?.text}");
    setState(() {
      _selectedIndex = index;
      _selectedQuestion = question;
      _selectedAnswer = answer;
      if (index == 2 && (question != null || answer != null)) {
        _healthbotKey = UniqueKey(); // Force HealthbotScreen to recreate
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(onNavigateToTab: _navigateToTab),
      const ArticleScreen(),
      HealthbotScreen(
        key: _healthbotKey,
        initialQuestion: _selectedQuestion,
        initialAnswer: _selectedAnswer,
        fromHistory: _selectedQuestion != null || _selectedAnswer != null,
      ),
      const ReminderScreen(),
      HistoryScreen(onNavigateToTab: _navigateToTab),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index != 2) {
              _selectedQuestion = null;
              _selectedAnswer = null;
              _healthbotKey = UniqueKey(); // Reset HealthbotScreen when leaving
            }
          });
        },
      ),
    );
  }
}