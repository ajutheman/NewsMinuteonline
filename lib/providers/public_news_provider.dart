import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PublicNewsProvider with ChangeNotifier {
  List<dynamic> _latestNews = [];
  List<dynamic> _breakingNews = [];
  Map<String, dynamic>? _selectedNews;
  bool _isLoading = false;

  List<dynamic> get latestNews => _latestNews;
  List<dynamic> get breakingNews => _breakingNews;
  Map<String, dynamic>? get selectedNews => _selectedNews;
  bool get isLoading => _isLoading;

  Future<void> fetchLatestNews() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/news?status=Published'));
      if (response.statusCode == 200) {
        _latestNews = json.decode(response.body);
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBreakingNews() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/news?status=Published&newsType=Breaking'));
      if (response.statusCode == 200) {
        _breakingNews = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }
}
