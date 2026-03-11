import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';
import '../models/advice.dart';

class ApiService {
  static const String _quotesBaseUrl = 'https://api.quotable.io';
  static const String _adviceBaseUrl = 'https://api.adviceslip.com';

  static Future<Quote> getRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse('$_quotesBaseUrl/random'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Quote.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load quote: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching quote: $e');
    }
  }

  static Future<Quote> getQuoteByTag(String tag) async {
    try {
      final response = await http.get(
        Uri.parse('$_quotesBaseUrl/random?tags=$tag'),
      );

      if (response.statusCode == 200) {
        return Quote.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load quote by tag');
      }
    } catch (e) {
      throw Exception('Error fetching quote by tag: $e');
    }
  }

  static Future<List<Quote>> getPopularQuotes({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_quotesBaseUrl/quotes?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Quote.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular quotes');
      }
    } catch (e) {
      throw Exception('Error fetching popular quotes: $e');
    }
  }

  static Future<Advice> getRandomAdvice() async {
    try {
      final response = await http.get(
        Uri.parse('$_adviceBaseUrl/advice'),
      );

      if (response.statusCode == 200) {
        return Advice.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load advice');
      }
    } catch (e) {
      throw Exception('Error fetching advice: $e');
    }
  }

  static Future<List<Quote>> searchQuotes(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_quotesBaseUrl/quotes?query=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Quote.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search quotes');
      }
    } catch (e) {
      throw Exception('Error searching quotes: $e');
    }
  }
}