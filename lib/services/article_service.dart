import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter/foundation.dart'; // Import untuk debugPrint

class Article {
  final String uid;
  final String title;
  final String description; // biasanya nama jurnal/source
  final String publishedDate;
  final String link;
  final String? abstractText;
  final List<String>? authors;
  final String? doi;
  final String? journal;

  Article({
    required this.uid,
    required this.title,
    required this.description,
    required this.publishedDate,
    required this.link,
    this.abstractText,
    this.authors,
    this.doi,
    this.journal,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      uid: json['uid'],
      title: json['title'] ?? '',
      description: json['source'] ?? '',
      publishedDate: json['pubdate'] ?? '',
      link: 'https://pubmed.ncbi.nlm.nih.gov/${json["uid"]}/',
      authors: json['authors'] != null
          ? List<String>.from(
              (json['authors'] as List)
                  .map((a) => (a as Map<String, dynamic>)['name'] ?? '')
                  .whereType<String>(),
            )
          : [],
      doi: json['elocationid'],
      journal: json['fulljournalname'],
    );
  }

  Article copyWith({String? abstractText}) {
    return Article(
      uid: uid,
      title: title,
      description: description,
      publishedDate: publishedDate,
      link: link,
      authors: authors,
      doi: doi,
      journal: journal,
      abstractText: abstractText ?? this.abstractText,
    );
  }
}

// 🔍 Langkah 1: Ambil UID dari hasil pencarian
Future<List<String>> searchPubMedUids(String keyword) async {
  final uri = Uri.parse(
    'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=$keyword&retmax=10&retmode=json',
  );

  debugPrint('🔎 Mencari UID dengan URL: $uri');
  try {
    final response = await http.get(uri);
    debugPrint('   Status Kode Respons (Cari UID): ${response.statusCode}');
    if (response.statusCode == 200) {
      debugPrint('   Data Respons (Cari UID): ${response.body}');
      final data = json.decode(response.body);
      final uids = List<String>.from(data['esearchresult']['idlist']);
      debugPrint('   UID yang Ditemukan: $uids');
      return uids;
    } else {
      debugPrint('   Gagal mencari UID. Status kode: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to search PubMed');
    }
  } catch (e) {
    debugPrint('   Terjadi error saat mencari UID: $e');
    throw Exception('Failed to search PubMed: $e');
  }
}

// 🧠 Langkah 2: Ambil metadata ringkas via ESummary
Future<List<Article>> fetchPubMedArticles(String keyword) async {
  final uids = await searchPubMedUids(keyword);
  if (uids.isEmpty) {
    debugPrint('🧠 Tidak ada UID yang ditemukan dari pencarian.');
    return [];
  }

  final idString = uids.join(',');
  final uri = Uri.parse(
    'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=$idString&retmode=json',
  );

  debugPrint('🧠 Mengambil summary artikel dengan URL: $uri');
  try {
    final response = await http.get(uri);
    debugPrint('   Status Kode Respons (Summary): ${response.statusCode}');
    if (response.statusCode == 200) {
      debugPrint('   Data Respons (Summary): ${response.body}');
      final data = json.decode(response.body);
      final summaries = data['result'];
      List<Article> articles = [];

      for (var uid in uids) {
        if (summaries.containsKey(uid)) {
          final articleJson = summaries[uid];
          articleJson['uid'] = uid;
          articles.add(Article.fromJson(articleJson));
        } else {
          debugPrint('   Peringatan: Summary untuk UID $uid tidak ditemukan.');
        }
      }
      debugPrint('   Artikel yang Berhasil Diambil (Tanpa Abstrak): ${articles.length}');
      return articles;
    } else {
      debugPrint('   Gagal mengambil summary artikel. Status kode: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to fetch article summaries');
    }
  } catch (e) {
    debugPrint('   Terjadi error saat mengambil summary artikel: $e');
    throw Exception('Failed to fetch article summaries: $e');
  }
}

// 🧾 Langkah 3: Ambil Abstract dari EFetch
Future<String?> fetchAbstract(String uid) async {
  final uri = Uri.parse(
    'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=$uid&retmode=xml',
  );

  debugPrint('🧾 Mengambil abstrak untuk UID $uid dengan URL: $uri');
  try {
    final response = await http.get(uri);
    debugPrint('   Status Kode Respons (Abstrak): ${response.statusCode}');
    if (response.statusCode != 200) {
      debugPrint('   Gagal mengambil abstrak untuk UID $uid. Status kode: ${response.statusCode}, Body: ${response.body}');
      return null;
    }

    debugPrint('   Data Respons (Abstrak): ${response.body}');
    final document = XmlDocument.parse(response.body);
    final abstractText = document
        .findAllElements('AbstractText')
        .map((e) => e.text.trim())
        .join('\n\n');

    debugPrint('   Abstrak yang Diperoleh untuk UID $uid: $abstractText');
    return abstractText.isEmpty ? null : abstractText;
  } catch (e) {
    debugPrint('   Terjadi error saat mengambil abstrak untuk UID $uid: $e');
    return null;
  }
}

// 🔄 Kombinasi: Fetch artikel + abstract secara lengkap
Future<List<Article>> fetchPubMedArticlesWithAbstract(String keyword) async {
  final baseArticles = await fetchPubMedArticles(keyword);
  List<Article> articlesWithAbstract = [];

  debugPrint('🔄 Memulai pengambilan abstrak untuk ${baseArticles.length} artikel.');
  for (final article in baseArticles) {
    debugPrint('   Mengambil abstrak untuk artikel dengan UID: ${article.uid}');
    final abstract = await fetchAbstract(article.uid);
    articlesWithAbstract.add(article.copyWith(abstractText: abstract));
    debugPrint('   Abstrak untuk UID ${article.uid} selesai diambil.');
  }
  debugPrint('🔄 Selesai mengambil abstrak untuk semua artikel. Total artikel dengan abstrak: ${articlesWithAbstract.length}');
  return articlesWithAbstract;
}