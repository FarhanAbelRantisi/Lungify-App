import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:healthbot_app/services/article_service.dart';
import 'package:healthbot_app/utils/text_styles.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        elevation: 0,
        title: Text('Detail Article', style: AppTextStyles.interBold20,)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(article.title, style: AppTextStyles.interBold24),
              const SizedBox(height: 8),
              Text("Published: ${article.publishedDate}", style: AppTextStyles.interRegular14.copyWith(color: Color(0xFF797C7B))),
              const SizedBox(height: 8),
              Text("Journal: ${article.journal ?? '-'}", style: AppTextStyles.interRegular14.copyWith(color: Color(0xFF797C7B))),
              const SizedBox(height: 8),
              Text("DOI: ${article.doi ?? '-'}", style: AppTextStyles.interRegular14.copyWith(color: Color(0xFF797C7B))),
              const SizedBox(height: 8),
              if (article.authors != null)
                Text("Authors: ${article.authors!.join(', ')}", style: AppTextStyles.interRegular14.copyWith(color: Color(0xFF797C7B))),
              const Divider(height: 48),
              Text(
                article.abstractText ?? "No abstract available.",
                style: AppTextStyles.interMedium16,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => launchUrl(Uri.parse(article.link)),
                child: const Text("Buka di PubMed"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
