// ═══════════════════════════════════════════════════════════════════════════════
// DOCUMENT VAULT SERVICE — AWS Amplify (S3 + DynamoDB) backed document storage
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'document_ai_service.dart';
import '../../models/cvi_document_model.dart';

class DocumentVaultService {
  // ────────────────────────────────────────────────────────────────────────────
  // UPLOAD DOCUMENT — compress → upload to S3 → AI extract → save metadata
  // ────────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> uploadDocument({
    required Uint8List imageBytes,
    required String documentType,
    String? customName,
  }) async {
    try {
      await Amplify.Auth.getCurrentUser();
      // userId is currently used implicitly by Amplify Auth rules (owner-based)

      // Step 1: Upload to S3
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final actualName = customName ?? documentType;
      final fileName = '${actualName.replaceAll(' ', '_')}_$timestamp.jpg';
      final storageKey = 'documents/$fileName';

      await Amplify.Storage.uploadData(
        data: StorageDataPayload.bytes(
          imageBytes,
          contentType: 'image/jpeg',
        ),
        path: StoragePath.fromString('public/$storageKey'),
      ).result;

      // Step 2: AI extraction via Gemini
      final extractedData = await DocumentAIService.extractFromDocumentBytes(
        imageBytes: imageBytes,
        documentType: documentType,
      );

      // Check for extraction error
      if (extractedData.containsKey('error')) {
        return {
          'success': false,
          'error': 'AI Extraction failed: ${extractedData['error']}',
        };
      }

      final confidence =
          (extractedData['confidence'] as num?)?.toDouble() ?? 0.0;

      // Step 3: Save document metadata to DynamoDB via GraphQL
      final docMutation = '''
        mutation CreateUserDocument(\$input: CreateUserDocumentInput!) {
          createUserDocument(input: \$input) {
            id
            name
            category
            size
            uploadDate
            status
            filePath
            isVerified
            extractedText
          }
        }
      ''';

      final docInput = {
        'name': customName ?? fileName,
        'category': documentType,
        'size': '${(imageBytes.length / 1024).toStringAsFixed(1)} KB',
        'uploadDate': DateTime.now().toUtc().toIso8601String(),
        'status': 'Verified',
        'filePath': storageKey,
        'isVerified': confidence > 0.6,
        'extractedText': json.encode(extractedData),
      };

      final operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: docMutation,
          variables: {'input': docInput},
        ),
      );

      final response = await operation.response;
      if (response.hasErrors) {
        throw Exception('GraphQL Errors: ${response.errors}');
      }

      // Step 4: Merge extracted data (Stubbbed for now as we need UserExtractedData table)
      // await _mergeExtractedData(userId: userId, extractedData: extractedData);

      return {
        'success': true,
        'confidence': confidence,
        'extractedData': extractedData,
        'filePath': storageKey,
      };
    } catch (e) {
      debugPrint('DocumentVault: Upload error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // FETCH USER DOCUMENTS from DynamoDB
  // ────────────────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getUserDocuments() async {
    try {
      const listQuery = '''
        query ListUserDocuments {
          listUserDocuments {
            items {
              id
              name
              category
              size
              uploadDate
              status
              filePath
              isVerified
              extractedText
            }
          }
        }
      ''';

      final operation = Amplify.API.query(
        request: GraphQLRequest<String>(document: listQuery),
      );

      final response = await operation.response;
      if (response.hasErrors) {
        debugPrint('DocumentVault: GraphQL Errors: ${response.errors}');
        return [];
      }

      final data =
          response.data != null ? SafeDecode.decode(response.data!) : {};
      final items = data['listUserDocuments']?['items'] as List? ?? [];

      return items.map((i) {
        final map = Map<String, dynamic>.from(i);
        return {
          'id': map['id'],
          'name': map['name'],
          'document_type': map['category'],
          'size': map['size'],
          'upload_date': map['uploadDate'],
          'status': map['status'],
          'file_path': map['filePath'],
          'is_verified': map['isVerified'],
          'extracted_text': map['extractedText'],
        };
      }).toList();
    } catch (e) {
      debugPrint('DocumentVault: Fetch error: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // FETCH EXTRACTED DATA for form auto-fill
  // ────────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUserExtractedData() async {
    try {
      final docs = await getUserDocuments();
      if (docs.isEmpty) return {};

      // Map the List<Map<String, dynamic>> to List<CVIDocument> for merging logic
      final cviDocs = docs.map((d) {
        final extractedMap = d['extracted_text'] != null
            ? SafeDecode.decode(d['extracted_text'] as String)
            : <String, dynamic>{};

        return CVIDocument(
          id: d['id'] as String,
          type: DocumentType.values.firstWhere(
            (e) => e.name == d['document_type'],
            orElse: () => DocumentType.other,
          ),
          fileName: d['name'] as String,
          localPath: d['file_path'] as String,
          uploadedAt: DateTime.tryParse(d['upload_date'] as String? ?? '') ??
              DateTime.now(),
          isVerified: d['is_verified'] as bool? ?? false,
          extractedData: extractedMap,
        );
      }).toList();

      final merged = DocumentAIService.mergeExtractedData(cviDocs);
      return merged.toJson();
    } catch (e) {
      debugPrint('DocumentVault: Extraction merge error: $e');
      return {};
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // GET DOWNLOAD URL for S3 objects
  // ────────────────────────────────────────────────────────────────────────────

  static Future<String?> getDocumentSignedUrl(String storageKey) async {
    try {
      final result = await Amplify.Storage.getUrl(
        path: StoragePath.fromString('public/$storageKey'),
        options: const StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            expiresIn: Duration(hours: 1),
          ),
        ),
      ).result;
      return result.url.toString();
    } catch (e) {
      debugPrint('DocumentVault: URL error: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // DOWNLOAD DOCUMENT to the device's Downloads folder
  // ────────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> downloadDocument({
    required String storageKey,
    required String fileName,
  }) async {
    try {
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null) {
        return {
          'success': false,
          'error': 'Could not find downloads directory'
        };
      }

      final localPath = '${downloadsDir.path}/$fileName';
      final localFile = AWSFile.fromPath(localPath);

      final operation = Amplify.Storage.downloadFile(
        path: StoragePath.fromString('public/$storageKey'),
        localFile: localFile,
      );

      final result = await operation.result;
      return {
        'success': true,
        'path': result.localFile.path,
      };
    } catch (e) {
      debugPrint('DocumentVault: Download error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // DELETE DOCUMENT from S3 + DynamoDB
  // ────────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> deleteDocument(
      String documentId, String storageKey) async {
    try {
      // 1. Delete from S3
      await Amplify.Storage.remove(
        path: StoragePath.fromString('public/$storageKey'),
      ).result;

      // 2. Delete from DynamoDB
      const deleteMutation = '''
        mutation DeleteUserDocument(\$input: DeleteUserDocumentInput!) {
          deleteUserDocument(input: \$input) {
            id
          }
        }
      ''';

      final operation = Amplify.API.mutate(
        request: GraphQLRequest<String>(
          document: deleteMutation,
          variables: {
            'input': {'id': documentId}
          },
        ),
      );

      final response = await operation.response;
      if (response.hasErrors) {
        return {'success': false, 'error': 'GraphQL Error: ${response.errors}'};
      }

      return {'success': true};
    } catch (e) {
      debugPrint('DocumentVault: Delete error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // SAVE FORM FILL HISTORY
  // ────────────────────────────────────────────────────────────────────────────

  static Future<void> saveFormFillHistory({
    required String serviceId,
    required String serviceName,
    required int fieldsTotal,
    required int fieldsAutoFilled,
    required Map<String, dynamic> filledData,
    String status = 'draft',
  }) async {
    // Stub: Need to add form_fill_history table to schema.graphql
    debugPrint('DocumentVault: Form history save (stubbed)');
  }
}

/// Helper for safe JSON decoding from GraphQL strings
class SafeDecode {
  static Map<String, dynamic> decode(String jsonStr) {
    try {
      return (json.decode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      return {};
    }
  }
}
