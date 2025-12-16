import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/public_news_provider.dart';
import '../providers/public_ad_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final newsProvider = Provider.of<PublicNewsProvider>(context, listen: false);
      final adProvider = Provider.of<PublicAdProvider>(context, listen: false);
      newsProvider.fetchLatestNews();
      newsProvider.fetchBreakingNews();
      adProvider.fetchAds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('NewsMinute', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Merriweather', letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => GoRouter.of(context).push('/search'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
               decoration: BoxDecoration(color: Colors.black),
               child: Center(child: Text('NewsMinute', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            ),
             ...['Politics', 'Business', 'Technology', 'Sports', 'Entertainment', 'Health', 'World'].map((cat) {
               return ListTile(
                 title: Text(cat),
                 onTap: () => GoRouter.of(context).push('/category/$cat'),
               );
             }),
          ],
        ),
      ),
      body: Consumer<PublicNewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.latestNews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final featuredNews = provider.latestNews.isNotEmpty ? provider.latestNews.first : null;
          final restNews = provider.latestNews.length > 1 ? provider.latestNews.sublist(1) : [];

          return CustomScrollView(
            slivers: [
              // Breaking News Ticker
              if (provider.breakingNews.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        const Text('BREAKING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.breakingNews.map((n) => n['title']).join('   •   '),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
               // Top Ad Banner
               const SliverToBoxAdapter(child: AdWidget(position: 'TopBanner')),

              // Hero Section (Featured Article)
              if (featuredNews != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NewsCard(news: featuredNews, isHorizontal: false), 
                        const SizedBox(height: 24),
                        const Divider(),
                      ],
                    ),
                  ),
                ),

              // Latest News Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.75, // Taller cards
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return NewsCard(news: restNews[index]);
                    },
                    childCount: restNews.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          );
        },
      ),
    );
  }
}

