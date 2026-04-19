import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String category;
  final String officialWebsite;
  final List<String> requiredDocuments;
  final List<String> eligibilityCriteria;
  final String processingTime;
  final bool isOnlineAvailable;
  final bool isPopular;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.officialWebsite,
    required this.requiredDocuments,
    required this.eligibilityCriteria,
    required this.processingTime,
    this.isOnlineAvailable = true,
    this.isPopular = false,
  });

  static List<ServiceModel> getAllServices() {
    return [];
  }

  static List<String> getCategories() {
    return [
      'All',
      'Identity',
      'Finance',
      'Food Security',
      'Social Welfare',
      'Civil Registration',
      'Property',
      'Travel',
      'Transport',
    ];
  }
}
