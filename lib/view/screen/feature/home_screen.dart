import 'dart:math';

import 'package:flutter/material.dart';
import 'package:healthbot_app/services/article_service.dart';
import 'package:healthbot_app/utils/text_styles.dart';
import 'package:healthbot_app/view/widget/article_card.dart';
import 'package:healthbot_app/view/widget/consultation_card.dart';
import 'package:healthbot_app/view/widget/reminder_card.dart';
import 'package:provider/provider.dart';
import 'package:healthbot_app/viewmodel/reminder_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:healthbot_app/view/screen/feature/article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Article? _firstArticle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    try {
      final articles = await fetchPubMedArticlesWithAbstract("lung disease");
      if (articles.isNotEmpty) {
        setState(() {
          _firstArticle = articles.first;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Failed to fetch article: $e");
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getTodayReminders(ReminderViewModel vm) {
    DateTime now = DateTime.now();
    String todayDate = DateFormat('yyyy-MM-dd').format(now);
    String currentTime = DateFormat('HH:mm').format(now);
    
    return vm.reminders
        .where((reminder) =>
            reminder['date'] == todayDate &&
            (reminder['time'] ?? '').compareTo(currentTime) >= 0)
        .toList();
  }

  // Format day name for ReminderCard
  String _getFormattedDayName() {
    return DateFormat('EEE').format(DateTime.now());
  }

  // Format date for ReminderCard
  String _getFormattedDate() {
    return DateFormat('d').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final reminderVM = Provider.of<ReminderViewModel>(context);
    final todayReminders = _getTodayReminders(reminderVM);
    final Random _random = Random();

  // Get a random image path from the available lung images
  String _getRandomLungImage() {
    int imageNumber = Random().nextInt(10) + 1;
    String path = 'assets/images/image_lunge$imageNumber.png';
    debugPrint('HomeScreen loading image: $path');
    return path;
  }
    
    // Sort reminders by time (closest first)
    todayReminders.sort((a, b) => (a['time'] ?? '').compareTo(b['time'] ?? ''));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Image.asset('assets/images/logotext_healthbot.png', width: 140, height: 31),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Image.asset('assets/images/icon_profile.png', width: 30, height: 30),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Konsultasi Card
              ConsultationCard(onNavigateToTab: widget.onNavigateToTab),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reminder', style: AppTextStyles.interBold20),
                  GestureDetector(
                    onTap: () => widget.onNavigateToTab(3),
                    child: Text('See More', style: AppTextStyles.interMedium14),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              ReminderCard(
                reminders: todayReminders,
                hari: _getFormattedDayName(),
                tanggal: _getFormattedDate(),
                highlightColor: const Color(0xFFD7F1FF),
                highlightBorderColor: const Color(0xFF5BC8FF),
              ),

              const SizedBox(height: 24),

              // Artikel
              Row(
                children: [
                  Text('Article', style: AppTextStyles.interBold20),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => widget.onNavigateToTab(1),
                    child: Text('See More', style: AppTextStyles.interMedium14),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _firstArticle == null
                      ? const Text("Tidak ada artikel tersedia.")
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticleDetailScreen(article: _firstArticle!),
                              ),
                            );
                          },
                          child: ArticleCard(
                            logo: 'assets/images/logo_pubmed.png',
                            publisher: _firstArticle!.description,
                            title: _firstArticle!.title,
                            image: _getRandomLungImage(),
                            time: _firstArticle!.publishedDate,
                            description: _firstArticle!.abstractText ?? 'Tidak ada deskripsi.',
                          ),
                        ),
                        
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}