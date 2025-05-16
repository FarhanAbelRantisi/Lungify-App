import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class GeminiService {
  // API key for Gemini
  final String apiKey = 'AIzaSyDlJjZC_3RnB_FnDvcOY8pnoXS6m2i1bLw';
  
  // Corrected API endpoint URL for Gemini
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  // Method to check network connectivity
  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Method to send prompt to Gemini API and get response
  Future<String> getGeminiResponse(String prompt) async {
    try {
      // First check if we have network connectivity
      bool isConnected = await _checkConnectivity();
      if (!isConnected) {
        print("ERROR: No network connectivity detected");
        return "No internet connection. Please check your connection and try again.";
      }
      
      print("INFO: ${DateTime.now()}: Sending request to Gemini API: $baseUrl");
      
      String enhancedPrompt =
          "You are Lungify, a friendly AI assistant that focuses on health and wellness." +
          "Provide accurate health information and assistance in a concise manner, with language that user use." +
          "Provide an answer like in a typical chat." +
          "User question: $prompt";
      
      print("INFO: ${DateTime.now()}: Enhanced prompt: $enhancedPrompt");
      
      final requestBody = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': enhancedPrompt
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1000,
        },
      });
      
      print("INFO: ${DateTime.now()}: Request body: ${requestBody.substring(0, min(200, requestBody.length))}...");
      
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print("ERROR: ${DateTime.now()}: API request timed out after 30 seconds");
          return http.Response('{"error": "timeout"}', 408);
        },
      );

      // Debug information
      print("INFO: ${DateTime.now()}: Response status code: ${response.statusCode}");
      
      if (response.statusCode == 408) {
        return "Request time has expired. The server may be busy, please try again later.";
      }
      
      if (response.statusCode == 200) {
        try {
          print("INFO: ${DateTime.now()}: Response body (first 200 chars): ${response.body.substring(0, min(200, response.body.length))}...");
          
          final jsonResponse = jsonDecode(response.body);
          print("INFO: ${DateTime.now()}: Successfully decoded JSON response");
          
          // Proper error handling for JSON parsing
          if (jsonResponse.containsKey('candidates') && 
              jsonResponse['candidates'].isNotEmpty &&
              jsonResponse['candidates'][0].containsKey('content') &&
              jsonResponse['candidates'][0]['content'].containsKey('parts') &&
              jsonResponse['candidates'][0]['content']['parts'].isNotEmpty) {
            
            print("INFO: ${DateTime.now()}: Found valid response structure");
            final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
            print("INFO: ${DateTime.now()}: Extracted text (first 100 chars): ${text.substring(0, min(100, text.length))}...");
            return text;
          } else if (jsonResponse.containsKey('error')) {
            print("ERROR: ${DateTime.now()}: API returned error: ${jsonResponse['error']}");
            return "Terjadi kesalahan pada sistem. Detail: ${jsonResponse['error']['message'] ?? 'Unknown error'}";
          } else {
            print("ERROR: ${DateTime.now()}: Unexpected response structure: ${response.body}");
            return "Sorry, I cannot process your request at this time. Please try again.";
          }
        } catch (e) {
          print("ERROR: ${DateTime.now()}: Error parsing JSON response: $e");
          return "An error occurred while processing the response from the server. Please try again.";
        }
      } else {
        print("ERROR: ${DateTime.now()}: API Error: Status ${response.statusCode}, Body: ${response.body}");
        
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson.containsKey('error') && errorJson['error'].containsKey('message')) {
            print("ERROR: ${DateTime.now()}: API error message: ${errorJson['error']['message']}");
            
            // Check for specific error types
            String errorMessage = errorJson['error']['message'];
            if (errorMessage.contains("API key")) {
              return "Terjadi masalah dengan kunci API. Silakan hubungi administrator aplikasi.";
            } else if (errorMessage.contains("quota")) {
              return "The API quota has been exceeded. Please try again later.";
            }
          }
        } catch (e) {
          print("ERROR: ${DateTime.now()}: Failed to parse error response: $e");
        }
        
        return "Sorry, I am having difficulty connecting right now. (Kode: ${response.statusCode}). please try again later.";
      }
    } catch (e, stacktrace) {
      print("ERROR: ${DateTime.now()}: Exception in Gemini service: $e");
      print("Stack trace: $stacktrace");
      
      if (e.toString().contains("SocketException") || e.toString().contains("Connection refused")) {
        return "Unable to connect to the server. Please check your internet connection and try again.";
      }
      
      return "An error occurred while processing your request. Please try again.";
    }
  }
  
  // Helper function to get minimum of two integers
  int min(int a, int b) {
    return a < b ? a : b;
  }
}