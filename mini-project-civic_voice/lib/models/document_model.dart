import 'package:flutter/material.dart';

class UserDocument {
  final String id;
  final String name;
  final String category;
  final String size;
  final DateTime uploadDate;
  final String status;
  final IconData icon;
  final Color color;
  final String? filePath;
  
  // AI Verification Fields
  final bool isVerified;
  final String? verificationMessage;
  final DateTime? expiryDate;
  final String? extractedText;

  UserDocument({
    required this.id,
    required this.name,
    required this.category,
    required this.size,
    required this.uploadDate,
    this.status = 'Scan Required',
    required this.icon,
    required this.color,
    this.filePath,
    this.isVerified = false,
    this.verificationMessage,
    this.expiryDate,
    this.extractedText,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'size': size,
      'uploadDate': uploadDate.toIso8601String(),
      'status': status,
      'filePath': filePath,
      'isVerified': isVerified,
      'verificationMessage': verificationMessage,
      'expiryDate': expiryDate?.toIso8601String(),
      'extractedText': extractedText,
    };
  }
}
