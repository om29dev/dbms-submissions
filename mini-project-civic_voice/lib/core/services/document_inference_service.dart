import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'reasoning_engine.dart';

class VerificationResult {
  final bool isValid;
  final String message;
  final DateTime? expiryDate;
  final String? extractedText;
  final bool isPoorQuality;

  VerificationResult({
    required this.isValid,
    required this.message,
    this.expiryDate,
    this.extractedText,
    this.isPoorQuality = false,
  });
}

class DocumentInferenceService {
  final ReasoningEngine _groqEngine = ReasoningEngine();

  Future<VerificationResult> verifyDocument(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) {
      return VerificationResult(isValid: false, message: "File not found");
    }

    // 1. Quality Check (Basic Brightness)
    final bool isLowQuality = await _checkImageQuality(file);
    if (isLowQuality) {
      return VerificationResult(
        isValid: false, 
        message: "Your photo is too dark or blurry, please retake",
        isPoorQuality: true,
      );
    }

    // 2. Auto-Enhance (Contrast Normalization)
    await _enhanceImage(file);

    // 3. Resize & Convert to Base64 (Optimize for Vision API)
    // Resize to max 1024 width/height to keep payload small
    final img.Image? originalImage = img.decodeImage(await file.readAsBytes());
    if (originalImage == null) {
      return VerificationResult(isValid: false, message: "Could not process image file");
    }
    
    final img.Image resizedImage = img.copyResize(
      originalImage, 
      width: originalImage.width > 1024 ? 1024 : originalImage.width,
      maintainAspect: true
    );
    
    // Encode to JPG with reduced quality for compact size
    final List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 85);
    final String base64Image = base64Encode(compressedBytes);

    // 4. Intelligence Check via Groq Vision (No Google APIs involved)
    final aiResult = await _groqEngine.verifyDocumentImage(base64Image);
    
    DateTime? foundExpiry;
    if (aiResult['expiryDate'] != null) {
      try {
        foundExpiry = DateTime.parse(aiResult['expiryDate']);
      } catch (_) {}
    }

    return VerificationResult(
      isValid: aiResult['isValid'] ?? true,
      message: aiResult['message'] ?? "Verified with Groq Vision",
      expiryDate: foundExpiry,
      extractedText: aiResult['extractedText'] ?? "",
    );
  }

  Future<void> _enhanceImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return;

      // Apply contrast stretch (normalization)
      final enhanced = img.normalize(image, min: 0, max: 255);
      
      // Save back to file
      await file.writeAsBytes(img.encodeJpg(enhanced, quality: 90));
    } catch (e) {
      debugPrint("Enhancement failed: $e");
    }
  }

  Future<bool> _checkImageQuality(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return true;

      // Basic brightness check
      double totalBrightness = 0;
      int step = 20; // Faster sampling
      int count = 0;

      for (int y = 0; y < image.height; y += step) {
        for (int x = 0; x < image.width; x += step) {
          final pixel = image.getPixel(x, y);
          totalBrightness += (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b);
          count++;
        }
      }

      final avgBrightness = totalBrightness / count;
      return avgBrightness < 40;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    // No resources to close manually for now
  }
}
