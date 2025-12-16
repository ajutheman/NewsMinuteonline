import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/public_news_provider.dart';
import '../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shimmer_loading.dart';
import 'ad_widget.dart';

// --- 1. Portal Header ---
class PortalHeader extends StatelessWidget {
  const PortalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AdWidget(position: 'HeaderTop'),
        // Top Strip
        Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  'Tuesday, Dec 16, 2025', 
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                ),
                const SizedBox(width: 12), // Replaced generic spacer with fixed spacing for scroll view
                _socialIcon(Icons.facebook),
                _socialIcon(Icons.camera_alt),
                _socialIcon(Icons.ondemand_video), 
                const SizedBox(width: 16),
                Text('ENGLISH', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.search, size: 16),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 24),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('SUBSCRIBE'),
                )
              ],
            ),
          ),
        ),
        
        // Brand Bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return Row(
                children: [
                  IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
                  if (!isMobile) const Spacer(), // Center on desktop
                  if (isMobile) const SizedBox(width: 8),
                  
                  // Logo
                  Expanded(
                    flex: isMobile ? 1 : 0,
                    child: FittedBox(
                       fit: BoxFit.scaleDown,
                       alignment: isMobile ? Alignment.centerLeft : Alignment.center,
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Text(
                             'NewsMinute', 
                             style: GoogleFonts.playfairDisplay(fontSize: 40, fontWeight: FontWeight.w900, color: const Color(0xFFD32F2F), letterSpacing: -1), 
                           ), 
                           const Text(' ONLINE', style: TextStyle(fontSize: 40, color: Color(0xFF1976D2), fontWeight: FontWeight.w300)),
                         ],
                       ),
                    ),
                  ),

                  if (!isMobile) const Spacer(),
                  if (!isMobile) 
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person, size: 16),
                      label: const Text('SIGN IN'),
                      style: TextButton.styleFrom(foregroundColor: Colors.black),
                    )
                ],
              );
            }
          ),
        ),

        // Navigation Bar
        Container(
          decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade300))),
          height: 40,
          child: Consumer<PublicNewsProvider>(
            builder: (context, provider, _) {
              if (provider.categories.isEmpty) {
                 // Fallback or Loader
                 return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
              }
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, size: 20),
                    onPressed: () => GoRouter.of(context).go('/'),
                    tooltip: 'Home',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  ...provider.categories.map((cat) => _navItem(context, cat['name'])).toList(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(icon, size: 14, color: Colors.grey[600]),
    );
  }

  Widget _navItem(BuildContext context, String label, {IconData? icon, Color? color}) {
    return InkWell(
      onTap: () => GoRouter.of(context).go('/category/${label.toLowerCase()}'), // Basic routing
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

// --- 2. Section Header ---
class SectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;

  const SectionHeader({super.key, required this.title, this.accentColor = const Color(0xFFD32F2F)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: accentColor),
          const SizedBox(width: 8),
          Text(title.toUpperCase(), style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black)),
          const Spacer(),
          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        ],
      ),
    );
  }
}

// --- 3. Hero News Card (Center Column) ---
class HeroNewsCard extends StatelessWidget {
  final Map<String, dynamic> news;
  const HeroNewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final imageUrl = news['coverImage'] != null && news['coverImage'].toString().startsWith('/')
        ? '${Constants.baseUrl.replaceAll('/api', '')}${news['coverImage']}'
        : news['coverImage'] ?? '';

    return InkWell(
      onTap: () => GoRouter.of(context).push('/news/${news['slug']}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 300,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const ShimmerLoading.rectangular(height: 300);
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            news['title'],
            style: GoogleFonts.merriweather(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            news['content'] ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }
}

// --- 4. Compact News Tile (Left Column) ---
class CompactNewsTile extends StatelessWidget {
  final Map<String, dynamic> news;
  final bool showImage;

  const CompactNewsTile({super.key, required this.news, this.showImage = true});

  @override
  Widget build(BuildContext context) {
    final imageUrl = news['coverImage'] != null && news['coverImage'].toString().startsWith('/')
        ? '${Constants.baseUrl.replaceAll('/api', '')}${news['coverImage']}'
        : news['coverImage'] ?? '';

    return InkWell(
      onTap: () => GoRouter.of(context).push('/news/${news['slug']}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showImage && imageUrl.isNotEmpty)
              Container(
                width: 80,
                height: 60,
                margin: const EdgeInsets.only(right: 12),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.grey[200]),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const ShimmerLoading.rectangular(height: 60, width: 80);
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 16, color: Colors.grey),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news['mainCategory']['name']?.toUpperCase() ?? 'NEWS',
                    style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF1976D2), fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
