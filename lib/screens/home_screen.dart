import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/public_news_provider.dart';
import '../providers/public_ad_provider.dart';
import '../widgets/portal_widgets.dart'; // New widgets
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
      newsProvider.fetchCategories();
      adProvider.fetchAds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
               decoration: BoxDecoration(color: Color(0xFFD32F2F)),
               child: Center(child: Text('NewsMinute', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            ),
             Consumer<PublicNewsProvider>(
               builder: (ctx, provider, _) { 
                 return Column(
                   children: provider.categories.map((cat) {
                      return ListTile(
                        title: Text(cat['name']), 
                        onTap: () => GoRouter.of(context).push('/category/${cat['name']}') 
                      );
                   }).toList(),
                 );
               },
             ),
          ],
        ),
      ),
      body: Consumer<PublicNewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.latestNews.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final allNews = provider.latestNews;
          if (allNews.isEmpty) return const Center(child: Text('No news available'));

          // Data Slicing
          final heroNews = allNews.isNotEmpty ? allNews.first : null;
          final editorsPick = allNews.length > 5 ? allNews.sublist(1, 6) : (allNews.length > 1 ? allNews.sublist(1) : []);
          final trending = allNews.length > 10 ? allNews.sublist(6, 11) : (allNews.length > 6 ? allNews.sublist(6) : []);
          final rest = allNews.length > 11 ? allNews.sublist(11) : [];

          return SingleChildScrollView(
            child: Column(
              children: [
                const PortalHeader(), // The Complex Header
                
                // Breaking Ticker
                if (provider.breakingNews.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        const Text('BREAKING:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.breakingNews.map((n) => n['title']).join('   •   '),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main Content Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 900;
                      
                      if (!isDesktop) {
                        // MOBILE LAYOUT (Stacked)
                        return Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             if (heroNews != null) HeroNewsCard(news: heroNews),
                             const SectionHeader(title: "Top Stories"),
                             ...editorsPick.map((n) => CompactNewsTile(news: n)).toList(),
                             const AdWidget(position: 'HomeMiddle'),
                             const SectionHeader(title: "Trending"),
                             ...trending.map((n) => CompactNewsTile(news: n)).toList(),
                           ],
                        );
                      } else {
                        // DESKTOP LAYOUT (3-Column)
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             // LEFT COLUMN (20%) - Editor's Pick
                             Expanded(
                               flex: 2,
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const SectionHeader(title: "EDITOR'S PICK", accentColor: Colors.blue),
                                   ...editorsPick.map((n) => CompactNewsTile(news: n)).toList(),
                                 ],
                               ),
                             ),
                             const SizedBox(width: 24),
                             
                             // CENTER COLUMN (50%) - Hero
                             Expanded(
                               flex: 5,
                               child: Column(
                                 children: [
                                   if (heroNews != null) HeroNewsCard(news: heroNews),
                                   const SizedBox(height: 24),
                                   // Sub-stories grid below hero?
                                   GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, 
                                        crossAxisSpacing: 16, 
                                        mainAxisSpacing: 16, 
                                        childAspectRatio: 3
                                      ),
                                      itemCount: rest.take(4).length,
                                      itemBuilder: (ctx, i) => CompactNewsTile(news: rest[i], showImage: false),
                                   ),
                                 ],
                               ),
                             ),
                             
                             const SizedBox(width: 24),

                             // RIGHT COLUMN (30%) - Ads/Trending
                             Expanded(
                               flex: 3,
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const AdWidget(position: 'SidebarTop'), // Big Ad
                                   const SizedBox(height: 24),
                                   const SectionHeader(title: "LATEST", accentColor: Colors.red),
                                   ...trending.map((n) => CompactNewsTile(news: n, showImage: false)).toList(),
                                 ],
                               ),
                             ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


