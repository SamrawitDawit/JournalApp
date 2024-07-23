import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  Future<String> getDailyQuote() async {
    try {
      final response = await http.get(Uri.parse('https://api.quotable.io/random'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Fetched quote: ${data['content']}');
        return data['content'];
      } else {
        print('Failed to fetch quote. Status code: ${response.statusCode}');
        return "Believe you can and you're halfway there.";
      }
    } catch (e) {
      print('Error fetching quote: $e');
      return "Believe you can and you're halfway there.";
    }
  }
}
