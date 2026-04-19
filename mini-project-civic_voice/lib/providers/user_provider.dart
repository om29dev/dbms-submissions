import 'package:amplify_flutter/amplify_flutter.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../models/application_model.dart';
import '../models/family_member_model.dart';

enum UserType { guest, registered, premium }

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final UserType userType;
  final bool isVerified;
  final int applicationsCount;
  final int completedCount;
  final int pendingCount;
  final DateTime? joinDate;
  final List<UserDocument> documents;
  final List<UserApplication> applications;
  final List<FamilyMember> familyMembers;

  // Personalized demographic fields
  final int? age;
  final double? annualIncome;
  final String? occupation;
  final String? location;
  final bool ownsLand;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    required this.userType,
    this.isVerified = false,
    this.applicationsCount = 0,
    this.completedCount = 0,
    this.pendingCount = 0,
    this.joinDate,
    this.documents = const [],
    this.applications = const [],
    this.familyMembers = const [],
    this.age,
    this.annualIncome,
    this.occupation,
    this.location,
    this.ownsLand = false,
    this.preferences = const {'theme_mode': 'system', 'language': 'en'},
  });

  // Guest user factory
  factory UserProfile.guest() {
    return UserProfile(
      name: 'Guest User',
      email: 'guest@civic.app',
      userType: UserType.guest,
      isVerified: false,
    );
  }

  // Registered user factory
  factory UserProfile.registered({
    required String name,
    required String email,
    String phone = '',
    String avatarUrl = '',
    bool isVerified = false,
    int applicationsCount = 0,
    int completedCount = 0,
    int pendingCount = 0,
    List<UserDocument>? documents,
    List<UserApplication>? applications,
    List<FamilyMember>? familyMembers,
    int? age,
    double? annualIncome,
    String? occupation,
    String? location,
    bool ownsLand = false,
  }) {
    return UserProfile(
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      userType: UserType.registered,
      isVerified: isVerified,
      applicationsCount: applicationsCount,
      completedCount: completedCount,
      pendingCount: pendingCount,
      joinDate: DateTime.now(),
      documents: documents ?? [],
      applications: applications ?? [],
      familyMembers: familyMembers ?? [],
      age: age,
      annualIncome: annualIncome,
      occupation: occupation,
      location: location,
      ownsLand: ownsLand,
    );
  }

  bool get isGuest => userType == UserType.guest;
  bool get isRegistered =>
      userType == UserType.registered || userType == UserType.premium;

  // Check if personalization data is set
  bool get isProfileComplete =>
      age != null && annualIncome != null && location != null;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserType? userType,
    bool? isVerified,
    List<UserDocument>? documents,
    List<UserApplication>? applications,
    List<FamilyMember>? familyMembers,
    int? age,
    double? annualIncome,
    String? occupation,
    String? location,
    bool? ownsLand,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      userType: userType ?? this.userType,
      isVerified: isVerified ?? this.isVerified,
      applicationsCount: applications?.length ?? applicationsCount,
      completedCount: applications
              ?.where((a) => a.status == ApplicationStatus.approved)
              .length ??
          completedCount,
      pendingCount: applications
              ?.where((a) =>
                  a.status == ApplicationStatus.submitted ||
                  a.status == ApplicationStatus.verified)
              .length ??
          pendingCount,
      joinDate: joinDate,
      documents: documents ?? this.documents,
      applications: applications ?? this.applications,
      familyMembers: familyMembers ?? this.familyMembers,
      age: age ?? this.age,
      annualIncome: annualIncome ?? this.annualIncome,
      occupation: occupation ?? this.occupation,
      location: location ?? this.location,
      ownsLand: ownsLand ?? this.ownsLand,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserProvider extends ChangeNotifier {
  UserProfile _currentUser = UserProfile.guest();

  UserProfile get currentUser => _currentUser;
  bool get isGuest => _currentUser.isGuest;
  bool get isLoggedIn => _currentUser.isRegistered;
  bool get isProfileComplete => _currentUser.isProfileComplete;

  // Login as guest
  void loginAsGuest() {
    _currentUser = UserProfile.guest();
    notifyListeners();
  }

  // Login with credentials
  void login({
    required String name,
    required String email,
    String phone = '',
    String avatarUrl = '',
    bool isVerified = false,
    int? age,
    double? annualIncome,
    String? occupation,
    String? location,
    bool ownsLand = false,
    Map<String, dynamic>? preferences,
  }) {
    _currentUser = UserProfile.registered(
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      applicationsCount: 0,
      completedCount: 0,
      pendingCount: 0,
      documents: [],
      applications: [],
      age: age,
      annualIncome: annualIncome,
      occupation: occupation,
      location: location,
      ownsLand: ownsLand,
    );
    if (preferences != null) {
      _currentUser = _currentUser.copyWith(preferences: preferences);
    }
    notifyListeners();
  }

  // Fetch user profile from Data API
  Future<void> fetchUserProfile(String userId) async {
    try {
      final query = '''
        query GetUser(\$id: ID!) {
          getUser(id: \$id) {
            id
            name
            email
            phone
            isVerified
            age
            annualIncome
            location
            occupation
            ownsLand
          }
        }
      ''';

      final operation = Amplify.API.query(
        request: GraphQLRequest<String>(
          document: query,
          variables: {'id': userId},
        ),
      );

      final response = await operation.response;
      if (response.data != null) {
        final data = json.decode(response.data!) as Map<String, dynamic>;
        final user = data['getUser'];
        if (user != null) {
          login(
            name: user['name'] ?? 'User',
            email: user['email'] ?? '',
            phone: user['phone'] ?? '',
            isVerified: user['isVerified'] ?? false,
            age: user['age'] as int?,
            annualIncome: (user['annualIncome'] as num?)?.toDouble(),
            location: user['location'],
            occupation: user['occupation'],
            ownsLand: user['ownsLand'] ?? false,
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  // Add application
  void addApplication(UserApplication app) {
    final List<UserApplication> updatedApps =
        List.from(_currentUser.applications)..add(app);
    _currentUser = _currentUser.copyWith(applications: updatedApps);
    notifyListeners();
  }

  // Update application status
  void updateApplicationStatus(String id, ApplicationStatus status,
      {String? currentStep, String? nextStep, ApplicationEvent? newEvent}) {
    final List<UserApplication> updatedApps =
        _currentUser.applications.map((app) {
      if (app.id == id) {
        final List<ApplicationEvent> updatedTimeline = List.from(app.timeline);
        if (newEvent != null) updatedTimeline.add(newEvent);

        return UserApplication(
          id: app.id,
          schemeId: app.schemeId,
          schemeName: app.schemeName,
          status: status,
          submissionDate: app.submissionDate,
          currentStep: currentStep ?? app.currentStep,
          nextStep: nextStep ?? app.nextStep,
          timeline: updatedTimeline,
        );
      }
      return app;
    }).toList();

    _currentUser = _currentUser.copyWith(applications: updatedApps);
    notifyListeners();
  }

  // Update profile with demographic data
  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    int? age,
    double? annualIncome,
    String? occupation,
    String? location,
    bool? ownsLand,
  }) {
    _currentUser = _currentUser.copyWith(
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      age: age,
      annualIncome: annualIncome,
      occupation: occupation,
      location: location,
      ownsLand: ownsLand,
    );
    notifyListeners();
    _syncToAws();
  }

  Future<void> _syncToAws() async {
    try {
      final authUser = await Amplify.Auth.getCurrentUser();
      final mutation = '''
        mutation UpdateUser(\$input: UpdateUserInput!) {
          updateUser(input: \$input) {
            id
          }
        }
      ''';

      final input = {
        'id': authUser.userId,
        'name': _currentUser.name,
        'email': _currentUser.email,
        'phone': _currentUser.phone,
        'age': _currentUser.age,
        'annualIncome': _currentUser.annualIncome,
        'location': _currentUser.location,
        'occupation': _currentUser.occupation,
        'ownsLand': _currentUser.ownsLand,
      };

      await Amplify.API
          .mutate(
            request: GraphQLRequest<String>(
              document: mutation,
              variables: {'input': input},
            ),
          )
          .response;
    } catch (e) {
      debugPrint('Error syncing profile: $e');
    }
  }

  void updatePreference(String key, dynamic value) {
    final Map<String, dynamic> updatedPrefs = Map.from(_currentUser.preferences)
      ..[key] = value;
    _currentUser = _currentUser.copyWith(preferences: updatedPrefs);
    notifyListeners();
    _syncToAws();
  }

  // Add document
  void addDocument(UserDocument document) {
    final List<UserDocument> updatedDocs = List.from(_currentUser.documents)
      ..add(document);
    _currentUser = _currentUser.copyWith(documents: updatedDocs);
    notifyListeners();
  }

  // Remove document
  void removeDocument(String id) {
    final List<UserDocument> updatedDocs =
        _currentUser.documents.where((doc) => doc.id != id).toList();
    _currentUser = _currentUser.copyWith(documents: updatedDocs);
    notifyListeners();
  }

  // Logout
  void logout() {
    _currentUser = UserProfile.guest();
    notifyListeners();
  }

  // Add family member
  void addFamilyMember(FamilyMember member) {
    final List<FamilyMember> updatedMembers =
        List.from(_currentUser.familyMembers)..add(member);
    _currentUser = _currentUser.copyWith(familyMembers: updatedMembers);
    notifyListeners();
  }

  // Remove family member
  void removeFamilyMember(String id) {
    final List<FamilyMember> updatedMembers =
        _currentUser.familyMembers.where((m) => m.id != id).toList();
    _currentUser = _currentUser.copyWith(familyMembers: updatedMembers);
    notifyListeners();
  }

  // Verify user
  void verifyUser() {
    if (_currentUser.isRegistered) {
      _currentUser = _currentUser.copyWith(isVerified: true);
      notifyListeners();
    }
  }
}
