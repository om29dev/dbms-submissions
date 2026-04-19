import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../config/ai_config.dart';

class AWSBedrockService {
  static const String _region = AIConfig.bedrockRegion;

  /// Invokes a Bedrock model with SigV4 signing.
  static Future<Map<String, dynamic>> invokeModel({
    required String modelId,
    required Map<String, dynamic> body,
    String api = 'invoke',
  }) async {
    try {
      // 1. Get AWS Credentials from Amplify Auth
      final session =
          await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      final credentials = session.credentialsResult.value;

      final signer = AWSSigV4Signer(
        credentialsProvider: AWSCredentialsProvider(
          AWSCredentials(
            credentials.accessKeyId,
            credentials.secretAccessKey,
            credentials.sessionToken,
          ),
        ),
      );

      final scope = AWSCredentialScope(
        region: _region,
        service: AWSService.bedrock,
      );

      // 2. Build the request
      final endpoint = 'bedrock-runtime.$_region.amazonaws.com';
      // Bedrock requires the modelId to be percent-encoded in the path for signing (specifically the colon)
      final encodedModelId = Uri.encodeComponent(modelId);
      final path = '/model/$encodedModelId/$api';
      final bodyBytes = utf8.encode(jsonEncode(body));

      final request = AWSHttpRequest.post(
        Uri.parse('https://$endpoint$path'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Amz-Content-Sha256': hex.encode(sha256.convert(bodyBytes).bytes),
        },
        body: bodyBytes,
      );

      // 3. Sign and Send
      debugPrint('Bedrock: Requesting $modelId at $endpoint$path');
      final signedRequest = await signer.sign(
        request,
        credentialScope: scope,
        serviceConfiguration: const BaseServiceConfiguration(
          signBody: true,
        ),
      );

      final client = AWSHttpClient();
      final operation = client.send(signedRequest);
      final response = await operation.response;

      final responseBody = await response.decodeBody();
      debugPrint('Bedrock Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('Bedrock Success Result: $responseBody');
        return jsonDecode(responseBody) as Map<String, dynamic>;
      } else {
        final errorMsg = 'Bedrock Error ${response.statusCode}: $responseBody';
        debugPrint(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e, stack) {
      debugPrint('Bedrock Service Exception: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  /// Specialized helper for Llama 3 (Meta)
  static Future<String> chatWithLlama3(String prompt,
      {double temperature = 0.5}) async {
    final body = {
      'prompt': prompt,
      'max_gen_len': 512,
      'temperature': temperature,
      'top_p': 0.9,
    };

    final result = await invokeModel(
      modelId: AIConfig.bedrockLlama3,
      body: body,
    );

    return result['generation'] as String? ?? '';
  }

  /// Specialized helper for Document Extraction using Multimodal Vision (Converse API)
  static Future<Map<String, dynamic>> extractWithVision({
    required String prompt,
    required Uint8List imageBytes,
    String? systemPrompt,
    String? modelId,
    String mimeType = 'image/jpeg',
  }) async {
    final format = mimeType.split('/').last; // e.g., 'jpeg', 'png'
    final validFormats = ['jpeg', 'png', 'gif', 'webp'];
    final safeFormat = validFormats.contains(format) ? format : 'jpeg';

    final body = {
      if (systemPrompt != null)
        "system": [
          {"text": systemPrompt}
        ],
      "messages": [
        {
          "role": "user",
          "content": [
            {
              "image": {
                "format": safeFormat,
                "source": {"bytes": base64Encode(imageBytes)}
              }
            },
            {"text": prompt}
          ]
        }
      ],
      "inferenceConfig": {
        "maxTokens": 2048,
        "temperature": 0.0,
        "topP": 0.9,
      }
    };

    final result = await invokeModel(
      modelId: modelId ?? AIConfig.bedrockNovaLite,
      body: body,
      api: 'converse',
    );

    // Converse API response structure: output.message.content[{text: ...}]
    final output = result['output'];
    if (output != null && output['message'] != null) {
      final content = output['message']['content'] as List;

      // Robust search for the text block in the content list
      String? text;
      for (final item in content) {
        if (item is Map && item.containsKey('text')) {
          text = item['text'] as String;
          break;
        }
      }

      if (text != null) {
        // Parse JSON from text - handle markdown markers or preambles
        try {
          final jsonStart = text.indexOf('{');
          final jsonEnd = text.lastIndexOf('}') + 1;
          if (jsonStart != -1 && jsonEnd > jsonStart) {
            final jsonStr = text.substring(jsonStart, jsonEnd);
            final Map<String, dynamic> parsed =
                jsonDecode(jsonStr) as Map<String, dynamic>;

            // Robust numeric normalization (Convert string numbers to doubles)
            parsed.forEach((key, value) {
              if (value is String) {
                final double? d = double.tryParse(value);
                if (d != null &&
                    (key == 'confidence' || key.contains('score'))) {
                  parsed[key] = d;
                }
              }
            });

            return parsed;
          }
        } catch (e) {
          debugPrint('JSON Parse Error: $e in text: $text');
        }
      }
    }

    throw Exception(
        'Failed to extract valid JSON from Vision response: $result');
  }
}
