import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/public_news_provider.dart';
import '../widgets/portal_widgets.dart';

class CategoryNewsScreen extends StatefulWidget {
  final String categoryId;
  const CategoryNewsScreen({super.key, required this.categoryId});

  @override
  State<CategoryNewsScreen> createState() => _CategoryNewsScreenState();
}

class _CategoryNewsScreenState extends State<CategoryNewsScreen> {
  List<dynamic> _newsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryNews();
  }

  @override
  void didUpdateWidget(covariant CategoryNewsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      _fetchCategoryNews();
    }
  }

  Future<void> _fetchCategoryNews() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<PublicNewsProvider>(context, listen: false);
    final results = await provider.fetchNewsByCategory(widget.categoryId);
    
    if (mounted) {
      setState(() {
        _newsList = results;
        _isLoading = false;
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SectionHeader(title: widget.categoryId, accentColor: Colors.blue),
              ),
            ),
            
            if (_isLoading)
               const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            
            if (!_isLoading && _newsList.isEmpty)
               const SliverFillRemaining(child: Center(child: Text("No news found in this category"))),

            if (!_isLoading && _newsList.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                         // Fallback to simple tile if needed, but styling as card
                         return Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Expanded(child: HeroNewsCard(news: _newsList[index])),
                           ],
                         );
                      },
                      childCount: _newsList.length,
                    ),
                ),
              ),
              
             const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}
