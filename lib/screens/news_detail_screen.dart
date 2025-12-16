import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/public_news_provider.dart';
import '../utils/constants.dart';
import '../widgets/ad_widget.dart';
import '../widgets/portal_widgets.dart';

class NewsDetailScreen extends StatefulWidget {
  final String slug;
  const NewsDetailScreen({super.key, required this.slug});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<PublicNewsProvider>(context, listen: false).fetchNewsDetail(widget.slug)
    );
  }

  @override
  void didUpdateWidget(covariant NewsDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      Future.microtask(() => 
        Provider.of<PublicNewsProvider>(context, listen: false).fetchNewsDetail(widget.slug)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('NewsMinute', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w900, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<PublicNewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final news = provider.selectedNews;
          if (news == null) {
            return const Center(child: Text('Note: Article not found or loading...'));
          }

          final imageUrl = news['coverImage'] != null && news['coverImage'].toString().startsWith('/')
             ? '${Constants.baseUrl.replaceAll('/api', '')}${news['coverImage']}'
             : news['coverImage'] ?? '';
          
          // Suggest related news (using latest news as fallback for now)
          final relatedNews = provider.latestNews.where((n) => n['_id'] != news['_id']).take(4).toList();

          return Center( 
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000), // Max width for desktop readability
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const AdWidget(position: 'HeaderTop'),
                    // 1. Header Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          news['mainCategory']['name']?.toUpperCase() ?? 'NEWS',
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        news['title'],
                        style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w900, height: 1.2),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const CircleAvatar(radius: 18, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white, size: 20)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(news['author']?['username'] ?? 'NewsMinute Team', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(news['createdAt']?.substring(0,10) ?? '', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 11)),
                            ],
                          ),
                          const Spacer(),
                          IconButton(icon: const Icon(Icons.share, size: 20), onPressed: () {}),
                          IconButton(icon: const Icon(Icons.bookmark_border, size: 20), onPressed: () {}),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Hero Image
                if (imageUrl.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                    ),
                  ),

                // 3. Content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Text
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news['content'],
                              style: GoogleFonts.merriweather(fontSize: 18, height: 1.8, color: Colors.grey[900]),
                            ),
                            const SizedBox(height: 32),
                            const SectionHeader(title: "RELATED NEWS"),
                            ...relatedNews.map((n) => CompactNewsTile(news: n)).toList(),
                          ],
                        ),
                      ),
                      
                      // Sidebar (Desktop only, else hide or stack)
                      if (MediaQuery.of(context).size.width > 800) ...[
                        const SizedBox(width: 32),
                        const Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              AdWidget(position: 'ArticleSidebar'),
                              SizedBox(height: 24),
                              Text("Trending", style: TextStyle(fontWeight: FontWeight.bold)),
                              // Could add trending list here
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                
                 const Padding(
                   padding: EdgeInsets.all(16.0),
                   child: AdWidget(position: 'ArticleBottom'),
                 ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  }
}
