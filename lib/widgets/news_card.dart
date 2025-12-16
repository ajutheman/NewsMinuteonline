import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';

class NewsCard extends StatelessWidget {
  final Map<String, dynamic> news;
  final bool isHorizontal;

  const NewsCard({super.key, required this.news, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    final imageUrl = news['coverImage'] != null && news['coverImage'].toString().startsWith('/')
        ? '${Constants.baseUrl.replaceAll('/api', '')}${news['coverImage']}'
        : news['coverImage'] ?? '';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => GoRouter.of(context).push('/news/${news['slug']}'),
        child: isHorizontal
            ? Row(
                children: [
                  _buildImage(imageUrl, height: 120, width: 120),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildContent(context),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImage(imageUrl, height: 180, width: double.infinity),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildContent(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImage(String url, {required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey.shade100,
      child: url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image, color: Colors.grey),
            )
          : const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (news['mainCategory'] != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              news['mainCategory']['name']?.toUpperCase() ?? 'NEWS',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Text(
          news['title'] ?? 'No Title',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          news['author']?['username'] ?? 'Unknown',
           style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}
