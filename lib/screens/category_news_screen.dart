import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/public_news_provider.dart';
import '../widgets/news_card.dart';

class CategoryNewsScreen extends StatefulWidget {
  final String categoryId; // Actually passing Name for now based on router, need to handle both
  const CategoryNewsScreen({super.key, required this.categoryId});

  @override
  State<CategoryNewsScreen> createState() => _CategoryNewsScreenState();
}

class _CategoryNewsScreenState extends State<CategoryNewsScreen> {
  List<dynamic> _news = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    final provider = Provider.of<PublicNewsProvider>(context, listen: false);
    // Simulating "By Category" fetch using the provider's helper
    final result = await provider.fetchNewsByCategory(widget.categoryId);
    if (mounted) {
      setState(() {
        _news = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryId)),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : _news.isEmpty 
           ? const Center(child: Text('No news in this category'))
           : GridView.builder(
               padding: const EdgeInsets.all(16),
               gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
               ),
               itemCount: _news.length,
               itemBuilder: (ctx, i) => NewsCard(news: _news[i]),
             ),
    );
  }
}
