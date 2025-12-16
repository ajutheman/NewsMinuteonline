import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PublicNewsProvider with ChangeNotifier {
  List<dynamic> _latestNews = [];
  List<dynamic> _breakingNews = [];
  List<dynamic> _categories = [];
  Map<String, dynamic>? _selectedNews;
  bool _isLoading = false;

  List<dynamic> get latestNews => _latestNews;
  List<dynamic> get breakingNews => _breakingNews;
  List<dynamic> get categories => _categories;
  Map<String, dynamic>? get selectedNews => _selectedNews;
  bool get isLoading => _isLoading;

  Future<void> fetchLatestNews() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/news?status=Published'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('news')) {
           _latestNews = data['news'];
        } else if (data is List) {
           _latestNews = data;
        }
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
         final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('news')) {
           _breakingNews = data['news'];
        } else if (data is List) {
           _breakingNews = data;
        }
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/categories'));
      if (response.statusCode == 200) {
        _categories = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchNewsDetail(String slug) async {
    _isLoading = true;
    _selectedNews = null;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/news/$slug'));
      if (response.statusCode == 200) {
        _selectedNews = json.decode(response.body);
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<dynamic>> fetchNewsByCategory(String categoryName) async {
    try {
      // Temporary: fetching all and filtering or using search as proxy if backend doesn't support category name filter directly
      final response = await http.get(Uri.parse('${Constants.baseUrl}/news?status=Published'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> allNews = [];
        if (data is Map<String, dynamic> && data.containsKey('news')) {
           allNews = data['news'];
        } else if (data is List) {
           allNews = data;
        }
        
        return allNews.where((n) => 
          n['mainCategory']['name'].toString().toLowerCase() == categoryName.toLowerCase()
        ).toList();
      }
    } catch (e) {
      print(e);
    }
    return [];
  }

  Future<List<dynamic>> searchNews(String query) async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/news?search=$query&status=Published'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('news')) {
           return data['news'];
        } else if (data is List) {
           return data;
        }
      }
    } catch (e) {
      print(e);
    }
    return [];
  }
}
