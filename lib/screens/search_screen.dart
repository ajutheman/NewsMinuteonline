import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/public_news_provider.dart';
import '../widgets/portal_widgets.dart';
import '../widgets/ad_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;
  bool _searched = false;

  void _search() async {
    if (_controller.text.isEmpty) return;
    setState(() { _loading = true; _searched = true; });
    
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
             const SliverToBoxAdapter(child: PortalHeader()),
             
             // Search Bar Area
             SliverToBoxAdapter(
               child: Container(
                 padding: const EdgeInsets.all(16),
                 color: Colors.grey[50],
                 child: Column(
                   children: [
                     TextField(
                       controller: _controller,
                       autofocus: true,
                       decoration: InputDecoration(
                         hintText: 'Search for news, topics...',
                         filled: true,
                         fillColor: Colors.white,
                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                         suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _search),
                       ),
                       onSubmitted: (_) => _search(),
                     ),
                     const SizedBox(height: 16),
                     const AdWidget(position: 'SearchTop'),
                   ],
                 ),
               ),
             ),

             if (_loading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),

             if (_searched && !_loading && _results.isEmpty)
                const SliverFillRemaining(child: Center(child: Text('No results found for your search'))),

             if (_results.isNotEmpty)
               SliverPadding(
                 padding: const EdgeInsets.all(16),
                 sliver: SliverList(
                   delegate: SliverChildBuilderDelegate(
                     (context, index) {
                       return CompactNewsTile(news: _results[index]); // Using our portal widget
                     },
                     childCount: _results.length,
                   ),
                 ),
               ),

          ],
        ),
      ),
    );
  }
}
