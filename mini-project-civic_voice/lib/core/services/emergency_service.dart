import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class DisasterGuide {
  final String title;
  final String iconAsset;
  final List<String> doSteps;
  final List<String> dontSteps;
  final Color color;

  DisasterGuide({
    required this.title,
    required this.iconAsset,
    required this.doSteps,
    required this.dontSteps,
    required this.color,
  });
}

class EmergencyService {
  // Offline Data: Disaster Guides
  final List<DisasterGuide> guides = [
    DisasterGuide(
      title: 'Earthquake',
      iconAsset: 'assets/icons/earthquake.png', // Placeholder
      color: Colors.brown,
      doSteps: [
        'Drop, Cover, and Hold On.',
        'Stay indoors until shaking stops.',
        'Stay away from glass, windows, outside doors and walls.',
        'If outside, move to a clear area away from trees and power lines.'
      ],
      dontSteps: [
        'Do not use elevators.',
        'Do not run outside during shaking.',
        'Do not stand in a doorway.'
      ],
    ),
    DisasterGuide(
      title: 'Flood',
      iconAsset: 'assets/icons/flood.png',
      color: const Color(0xFFFF6B1A),
      doSteps: [
        'Move to higher ground immediately.',
        'Listen to evacuation orders.',
        'Disconnect electrical appliances.',
        'Turn off gas and water mains.'
      ],
      dontSteps: [
        'Do not walk through moving water.',
        'Do not drive into flooded areas.',
        'Do not touch electrical equipment if you are wet.'
      ],
    ),
    DisasterGuide(
      title: 'Fire',
      iconAsset: 'assets/icons/fire.png',
      color: Colors.orange,
      doSteps: [
        'Stay low to the ground to avoid smoke.',
        'Test doors for heat before opening.',
        'Use stairs, not elevators.',
        'Call 112 once you are safe.'
      ],
      dontSteps: [
        'Do not hide in closets or under beds.',
        'Do not go back inside for any reason.',
        'Do not delay calling help.'
      ],
    ),
  ];

  // Get current location for SOS
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  // Trigger SOS call
  Future<void> callEmergencyNumber() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '112',
    );
    await launchUrl(launchUri);
  }
}
