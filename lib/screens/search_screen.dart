import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/public_news_provider.dart';
import '../widgets/news_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;

  void _search() async {
    if (_controller.text.isEmpty) return;
    setState(() => _loading = true);
    
    final provider = Provider.of<PublicNewsProvider>(context, listen: false);
    final results = await provider.searchNews(_controller.text);
    
    if (mounted) {
      setState(() {
        _results = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _search(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _search),
        ],
      ),
      body: _loading 
         ? const Center(child: CircularProgressIndicator())
         : _results.isEmpty 
             ? Center(child: Text(_controller.text.isEmpty ? 'Type to search' : 'No results found'))
             : ListView.separated(
                 padding: const EdgeInsets.all(16),
                 itemCount: _results.length,
                 separatorBuilder: (_,__) => const SizedBox(height: 16),
                 itemBuilder: (ctx, i) => NewsCard(news: _results[i], isHorizontal: true), // Use horizontal card for list view
               ),
    );
  }
}
