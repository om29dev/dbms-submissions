import 'dart:async';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/foundation.dart';

import '../../amplifyconfiguration.dart';

class AwsAmplifyService {
  static bool get isInitialized => Amplify.isConfigured;
  static Completer<void>? _initCompleter;

  static Future<void> initialize() async {
    if (isInitialized) return;

    // If already initializing, wait for the existing one to complete
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      debugPrint('[AwsAmplifyService] initialize: Adding plugins...');
      final authPlugin = AmplifyAuthCognito();
      final apiPlugin = AmplifyAPI();
      final storagePlugin = AmplifyStorageS3();

      await Amplify.addPlugins([authPlugin, apiPlugin, storagePlugin]);

      debugPrint('[AwsAmplifyService] initialize: Configuring Amplify...');
      await Amplify.configure(amplifyconfig);
      debugPrint(
          '[AwsAmplifyService] initialize: Successfully configured AWS Amplify');
      _initCompleter!.complete();
    } on Exception catch (e) {
      debugPrint('[AwsAmplifyService] initialize Error: $e');
      // If it's already configured error, we can treat it as success or handled
      if (e.toString().contains('AmplifyAlreadyConfiguredException')) {
        _initCompleter?.complete();
      } else {
        _initCompleter?.completeError(e);
        _initCompleter = null; // Allow retry on fatal errors
      }
    }
  }
}
