// In lib/api_services/ocr_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OcrService {
  // IMPORTANT: Paste your new, restricted API key from Google Cloud here.
  static const String _apiKey = "AIzaSyBGLIbJGz1xViHAWB_dTqGg66QahnAlohw";
  static const String _endpoint = "https://vision.googleapis.com/v1/images:annotate";

  Future<String?> processImage(String imagePath) async {
    try {
      // 1. Read image bytes and convert to a Base64 string
      final imageBytes = await File(imagePath).readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // 2. Construct the JSON request body for the Vision API
      final Map<String, dynamic> requestBody = {
        "requests": [
          {
            "image": {
              "content": base64Image,
            },
            "features": [
              {
                "type": "TEXT_DETECTION",
                "maxResults": 1,
              }
            ]
          }
        ]
      };

      // 3. Make the POST request
      final uri = Uri.parse('$_endpoint?key=$_apiKey');
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        // 4. Parse the complex JSON response to find the text
        if (responseBody['responses'] != null &&
            responseBody['responses'][0]['fullTextAnnotation'] != null) {

          final String text = responseBody['responses'][0]['fullTextAnnotation']['text'];
          debugPrint("Google Vision Success: $text");
          return text;
        } else {
          debugPrint("Google Vision Warning: No text found in the image.");
          return "No text found.";
        }
      } else {
        debugPrint("Google Vision API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Error during Google Vision API call: $e");
      return null;
    }
  }
}