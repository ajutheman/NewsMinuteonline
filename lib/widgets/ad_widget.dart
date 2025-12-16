import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/public_ad_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdWidget extends StatelessWidget {
  final String position;
  const AdWidget({super.key, required this.position});

  @override

class _AdWidgetState extends State<AdWidget> {
  List<dynamic> _ads = [];

  @override
  void initState() {
    super.initState();
    _fetchAds();
  }

  Future<void> _fetchAds() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/ads/public?position=${widget.position}'));
      if (response.statusCode == 200) {
        setState(() {
          _ads = json.decode(response.body);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ads.isEmpty) return const SizedBox.shrink();

    // Rotate or Show First Ad
    final ad = _ads.first;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Text('Advertisement', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          if (ad['type'] == 'Image')
            Image.network(ad['content'], height: 100, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox())
          else if (ad['type'] == 'Text')
             Text(ad['content'], style: const TextStyle(fontWeight: FontWeight.bold))
          else
            const Text('Ad Content Placeholder'),
        ],
      ),
    );
  }
}
