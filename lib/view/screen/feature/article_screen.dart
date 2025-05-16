import 'package:flutter/material.dart';
import 'package:healthbot_app/utils/text_styles.dart';
import 'package:healthbot_app/view/widget/article_list.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  _ArticleScreenScreenState createState() => _ArticleScreenScreenState();
}

class _ArticleScreenScreenState extends State<ArticleScreen> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        centerTitle: true,
        elevation: 0,
        title: Text('Article', style: AppTextStyles.interBold20,)
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArticleList(),

              const SizedBox(height: 20)
            ]
          ),
        ),
      ),
    );
  }
}