import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthbot_app/models/chat_message.dart';
import 'package:healthbot_app/utils/text_styles.dart';
import 'package:healthbot_app/services/history_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final void Function(int, {ChatMessage? question, ChatMessage? answer}) onNavigateToTab;

  const HistoryScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final historyService = HistoryService();

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9F9),
          centerTitle: true,
          elevation: 0,
          title: Image.asset(
            'assets/images/logotext_healthbot2.png',
            height: 20,
          ),
        ),
        body: const Center(
          child: Text('Please log in to view chat history.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        elevation: 0,
        title: Text('History', style: AppTextStyles.interBold20,
        ),
      ),
      body: StreamBuilder<List<Map<String, ChatMessage>>>(
        stream: historyService.getChatHistoryPairs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading chat history.'));
          }

          final pairs = snapshot.data ?? [];

          if (pairs.isEmpty) {
            return const Center(child: Text('No chat history available.'));
          }

          // Group pairs by date
          final groupedPairs = <String, List<Map<String, ChatMessage>>>{};
          for (var pair in pairs) {
            final date = DateFormat('yyyy-MM-dd').format(pair['question']!.timestamp);
            if (!groupedPairs.containsKey(date)) {
              groupedPairs[date] = [];
            }
            groupedPairs[date]!.add(pair);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: groupedPairs.keys.length,
            itemBuilder: (context, index) {
              final date = groupedPairs.keys.elementAt(index);
              final datePairs = groupedPairs[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      DateFormat('MMMM dd, yyyy').format(DateTime.parse(date)),
                      style: AppTextStyles.interBold16.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  ...datePairs.map((pair) => _buildHistoryCard(context, pair)).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, ChatMessage> pair) {
    final question = pair['question']!;
    final answer = pair['answer']!;

    return GestureDetector(
      onTap: () {
        onNavigateToTab(2, question: question, answer: answer);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        color: const Color(0xFFFDFDFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFE3E9F3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.text,
                style: AppTextStyles.interBold18.copyWith(color: const Color(0xFF24786D)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                answer.text,
                style: AppTextStyles.interRegular16.copyWith(color: Color(0xFF3B3B3B)),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}