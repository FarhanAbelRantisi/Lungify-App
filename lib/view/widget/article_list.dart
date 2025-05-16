import 'dart:math';

import 'package:flutter/material.dart';
import 'package:healthbot_app/view/widget/article_card.dart';
import 'package:healthbot_app/services/article_service.dart';
import 'package:healthbot_app/view/screen/feature/article_detail_screen.dart';
import 'package:flutter/foundation.dart'; // Import untuk debugPrint

class ArticleList extends StatefulWidget {
  const ArticleList({super.key});

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  late Future<List<Article>> _articlesFuture;
  final Random _random = Random();

  // Get a random image path from the available lung images
  String _getRandomLungImage() {
    int imageNumber = _random.nextInt(10) + 1; // Random number between 1 and 10
    return 'assets/images/image_lunge$imageNumber.png';
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 initState dipanggil. Memulai fetch artikel.');
    _articlesFuture = fetchPubMedArticlesWithAbstract("lung disease");
    _articlesFuture.then((_) {
      debugPrint('✅ Fetch artikel selesai.');
    }).catchError((error) {
      debugPrint('❌ Terjadi error saat fetch artikel di initState: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 Widget ArticleList sedang dibangun.');
    return FutureBuilder<List<Article>>(
      future: _articlesFuture,
      builder: (context, snapshot) {
        debugPrint('⏳ Status koneksi FutureBuilder: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('   Menampilkan indikator loading.');
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          debugPrint('   Terjadi error saat memuat data: ${snapshot.error}');
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: Text("Gagal memuat artikel.")),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          debugPrint('   Tidak ada data artikel yang diterima.');
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: Text("Tidak ada artikel ditemukan.")),
          );
        }

        final articles = snapshot.data!;
        debugPrint('✅ Berhasil memuat ${articles.length} artikel. Membangun ListView.');
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: articles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final article = articles[index];
            debugPrint('   Membangun ArticleCard untuk artikel ke-$index dengan judul: ${article.title}');
            return GestureDetector(
              onTap: () {
                debugPrint('   Artikel dengan UID ${article.uid} ditekan. Navigasi ke detail.');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleDetailScreen(article: article),
                  ),
                );
              },
              child: ArticleCard(
                logo: 'assets/images/logo_pubmed.png',
                publisher: article.description,
                title: article.title,
                image: _getRandomLungImage(), // Random image for each article
                time: article.publishedDate,
                description: article.abstractText ?? 'Abstract tidak tersedia.',
              ),
            );
          },
        );
      },
    );
  }
}