import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PublicAdProvider with ChangeNotifier {
  List<dynamic> _ads = [];
  bool _isLoading = false;

  List<dynamic> get ads => _ads;
  bool get isLoading => _isLoading;

  Future<void> fetchAds() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/ads/public'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Filter only Active ads
        _ads = data.where((ad) => ad['status'] == 'Active').toList();
      }
    } catch (e) {
      print('Error fetching ads: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Helper to get ads by position
  List<dynamic> getAdsByPosition(String position) {
    return _ads.where((ad) => ad['position'] == position).toList();
  }
}
