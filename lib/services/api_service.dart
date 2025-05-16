import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> sendToBot(String message) async {
    print("INFO: ${DateTime.now()}: ApiService: Sending request to rag_function with message: $message");
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("INFO: ${DateTime.now()}: ApiService: User logged in with UID: ${user.uid}");
      } else {
        print("ERROR: ${DateTime.now()}: ApiService: No user logged in before calling function");
        return {
          'response': 'No user logged in',
          'success': false,
        };
      }
      
      // Method 1: Use the httpsCallable approach (recommended for Firebase)
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'rag_function',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 60),
        ),
      );
      
      // Create the payload in the exact format expected
      final Map<String, dynamic> params = {
        'question': message,
        'collection': 'document_chunks',
        'top_k': 3,
      };

      print("FINE: ${DateTime.now()}: ApiService: Calling rag_function with parameters: ${jsonEncode(params)}");

      // Call the function with the data directly
      final result = await callable.call(params);

      print("INFO: ${DateTime.now()}: ApiService: Received response from rag_function: ${result.data}");

      if (result.data is Map && result.data.containsKey('answer')) {
        return {
          'response': result.data['answer'] ?? "No answer returned",
          'success': true,
        };
      } else {
        print("WARNING: ${DateTime.now()}: ApiService: Unexpected response format: ${result.data}");
        return {
          'response': result.data.toString(),
          'success': true,
        };
      }
    } catch (e) {
      print("ERROR: ${DateTime.now()}: ApiService: Error calling rag_function: $e");
      if (e is FirebaseFunctionsException) {
        print("ERROR: ${DateTime.now()}: ApiService: Firebase function error - Code: ${e.code}, Message: ${e.message}, Details: ${e.details}");
        return {
          'response': 'Server error: ${e.code} - ${e.message}',
          'success': false,
        };
      }
      return {
        'response': 'Error connecting to server: $e',
        'success': false,
      };
    }
  }
  
  // Alternative method using direct HTTP request
  static Future<Map<String, dynamic>> sendToBotWithHttp(String message) async {
    print("INFO: ${DateTime.now()}: ApiService: Sending HTTP request to rag_function with message: $message");
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("INFO: ${DateTime.now()}: ApiService: User logged in with UID: ${user.uid}");
        // Get ID token for authentication
        String? idToken = await user.getIdToken();
        
        // Cloud Function URL - replace with your function URL
        String functionUrl = 'https://us-central1-healthbot-app.cloudfunctions.net/rag_function';
        
        // Create the payload
        final Map<String, dynamic> params = {
          'question': message,
          'collection': 'document_chunks',
          'top_k': 3,
        };
        
        print("FINE: ${DateTime.now()}: ApiService: Sending HTTP request with parameters: ${jsonEncode(params)}");
        
        // Send HTTP POST request
        final response = await http.post(
          Uri.parse(functionUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode(params),
        );
        
        print("INFO: ${DateTime.now()}: ApiService: Received HTTP response status: ${response.statusCode}");
        
        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          print("INFO: ${DateTime.now()}: ApiService: Parsed response: $result");
          
          if (result is Map && result.containsKey('answer')) {
            return {
              'response': result['answer'] ?? "No answer returned",
              'success': true,
            };
          } else {
            print("WARNING: ${DateTime.now()}: ApiService: Unexpected response format: $result");
            return {
              'response': result.toString(),
              'success': true,
            };
          }
        } else {
          print("ERROR: ${DateTime.now()}: ApiService: HTTP error: ${response.statusCode} - ${response.body}");
          return {
            'response': 'Server error: ${response.statusCode} - ${response.body}',
            'success': false,
          };
        }
      } else {
        print("ERROR: ${DateTime.now()}: ApiService: No user logged in before calling function");
        return {
          'response': 'No user logged in',
          'success': false,
        };
      }
    } catch (e) {
      print("ERROR: ${DateTime.now()}: ApiService: Error in HTTP request: $e");
      return {
        'response': 'Error connecting to server: $e',
        'success': false,
      };
    }
  }
}