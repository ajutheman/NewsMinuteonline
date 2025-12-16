import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/public_ad_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdWidget extends StatelessWidget {
  final String position;
  const AdWidget({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicAdProvider>(
      builder: (context, provider, _) {
        final ads = provider.getAdsByPosition(position);
        if (ads.isEmpty) return const SizedBox.shrink();

        // Show first active ad for this position
        final ad = ads.first; 

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: InkWell(
            onTap: () {
               if (ad['linkUrl'] != null && ad['linkUrl'].isNotEmpty) {
                 launchUrl(Uri.parse(ad['linkUrl']));
               }
            },
            child: ad['type'] == 'Image' && ad['content'] != null
              ? Image.network(
                  ad['content'],
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, _, __) => const SizedBox.shrink(),
                )
              : Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: Text(ad['content'] ?? 'Ad', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
          ),
        );
      },
    );
  }
}
