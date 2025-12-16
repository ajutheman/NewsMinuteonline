import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/public_news_provider.dart';
import '../utils/constants.dart';
import '../widgets/ad_widget.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('NewsMinute'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
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
             : news['coverImage'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  Image.network(
                    imageUrl, 
                    width: double.infinity, 
                    height: 300, 
                    fit: BoxFit.cover,
                    errorBuilder: (ctx,_,__) => const SizedBox(height: 200, child: Center(child: Icon(Icons.broken_image))),
                  ),
                
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          news['mainCategory']['name']?.toUpperCase() ?? 'NEWS',
                          style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        news['title'],
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.2, fontFamily: 'Merriweather'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(news['author']?['username'] ?? 'NewsMinute Team', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(news['createdAt']?.substring(0,10) ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Article Content (Simple Text for now)
                      Text(
                        news['content'],
                        style: const TextStyle(fontSize: 18, height: 1.6, fontFamily: 'Merriweather'),
                      ),

                      const SizedBox(height: 32),
                      const AdWidget(position: 'ArticleBottom'),
                    ],
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
