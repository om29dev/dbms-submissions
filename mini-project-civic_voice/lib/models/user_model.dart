import 'package:flutter/foundation.dart';

/// Indian states and UTs for location-aware service filtering.
enum IndianState {
  andhraPradesh,
  arunachalPradesh,
  assam,
  bihar,
  chhattisgarh,
  goa,
  gujarat,
  haryana,
  himachalPradesh,
  jharkhand,
  karnataka,
  kerala,
  madhyaPradesh,
  maharashtra,
  manipur,
  meghalaya,
  mizoram,
  nagaland,
  odisha,
  punjab,
  rajasthan,
  sikkim,
  tamilNadu,
  telangana,
  tripura,
  uttarPradesh,
  uttarakhand,
  westBengal,
  // UTs
  andamanNicobar,
  chandigarh,
  dadraHaveliDamanDiu,
  delhi,
  jammuKashmir,
  ladakh,
  lakshadweep,
  puducherry,
}

extension IndianStateEx on IndianState {
  String get label => switch (this) {
        IndianState.andhraPradesh         => 'Andhra Pradesh',
        IndianState.arunachalPradesh      => 'Arunachal Pradesh',
        IndianState.assam                 => 'Assam',
        IndianState.bihar                 => 'Bihar',
        IndianState.chhattisgarh          => 'Chhattisgarh',
        IndianState.goa                   => 'Goa',
        IndianState.gujarat               => 'Gujarat',
        IndianState.haryana               => 'Haryana',
        IndianState.himachalPradesh       => 'Himachal Pradesh',
        IndianState.jharkhand             => 'Jharkhand',
        IndianState.karnataka             => 'Karnataka',
        IndianState.kerala                => 'Kerala',
        IndianState.madhyaPradesh         => 'Madhya Pradesh',
        IndianState.maharashtra           => 'Maharashtra',
        IndianState.manipur               => 'Manipur',
        IndianState.meghalaya             => 'Meghalaya',
        IndianState.mizoram               => 'Mizoram',
        IndianState.nagaland              => 'Nagaland',
        IndianState.odisha                => 'Odisha',
        IndianState.punjab                => 'Punjab',
        IndianState.rajasthan             => 'Rajasthan',
        IndianState.sikkim                => 'Sikkim',
        IndianState.tamilNadu             => 'Tamil Nadu',
        IndianState.telangana             => 'Telangana',
        IndianState.tripura               => 'Tripura',
        IndianState.uttarPradesh          => 'Uttar Pradesh',
        IndianState.uttarakhand           => 'Uttarakhand',
        IndianState.westBengal            => 'West Bengal',
        IndianState.andamanNicobar        => 'Andaman & Nicobar Islands',
        IndianState.chandigarh            => 'Chandigarh',
        IndianState.dadraHaveliDamanDiu   => 'Dadra & Nagar Haveli and Daman & Diu',
        IndianState.delhi                 => 'Delhi',
        IndianState.jammuKashmir          => 'Jammu & Kashmir',
        IndianState.ladakh                => 'Ladakh',
        IndianState.lakshadweep           => 'Lakshadweep',
        IndianState.puducherry            => 'Puducherry',
      };

  String get value => name;

  static IndianState fromString(String value) =>
      IndianState.values.firstWhere(
        (e) => e.name == value,
        orElse: () => IndianState.delhi,
      );
}

/// Represents a user of the Civic Voice Interface.
@immutable
class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? mobile;

  /// BCP 47 language code: en, hi, mr, ta.
  final String language;

  final IndianState? state;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  /// True for unauthenticated/browse-only users.
  final bool isGuest;

  /// Optional Aadhaar number (stored masked — last 4 digits only).
  final String? aadhaarLastFour;

  /// List of service IDs bookmarked by this user.
  final List<String> bookmarkedServiceIds;

  /// List of completed conversation session IDs.
  final List<String> sessionIds;

  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.mobile,
    required this.language,
    this.state,
    required this.createdAt,
    this.lastLoginAt,
    this.isGuest = false,
    this.aadhaarLastFour,
    this.bookmarkedServiceIds = const [],
    this.sessionIds = const [],
  });

  /// Creates a guest user for unauthenticated browsing.
  factory UserModel.guest() => UserModel(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Guest',
        language: 'en',
        createdAt: DateTime.now(),
        isGuest: true,
      );

  /// Returns user's initials (max 2 chars) for avatar display.
  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get hasEmail  => email != null && email!.isNotEmpty;
  bool get hasMobile => mobile != null && mobile!.isNotEmpty;
  bool get hasState  => state != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'mobile': mobile,
        'language': language,
        'state': state?.value,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'isGuest': isGuest,
        'aadhaarLastFour': aadhaarLastFour,
        'bookmarkedServiceIds': bookmarkedServiceIds,
        'sessionIds': sessionIds,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String?,
        mobile: json['mobile'] as String?,
        language: json['language'] as String? ?? 'en',
        state: json['state'] != null
            ? IndianStateEx.fromString(json['state'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastLoginAt: json['lastLoginAt'] != null
            ? DateTime.parse(json['lastLoginAt'] as String)
            : null,
        isGuest: json['isGuest'] as bool? ?? false,
        aadhaarLastFour: json['aadhaarLastFour'] as String?,
        bookmarkedServiceIds:
            List<String>.from(json['bookmarkedServiceIds'] as List? ?? []),
        sessionIds: List<String>.from(json['sessionIds'] as List? ?? []),
      );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? language,
    IndianState? state,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isGuest,
    String? aadhaarLastFour,
    List<String>? bookmarkedServiceIds,
    List<String>? sessionIds,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        mobile: mobile ?? this.mobile,
        language: language ?? this.language,
        state: state ?? this.state,
        createdAt: createdAt ?? this.createdAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
        isGuest: isGuest ?? this.isGuest,
        aadhaarLastFour: aadhaarLastFour ?? this.aadhaarLastFour,
        bookmarkedServiceIds: bookmarkedServiceIds ?? this.bookmarkedServiceIds,
        sessionIds: sessionIds ?? this.sessionIds,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UserModel(id: $id, name: $name, isGuest: $isGuest)';
}
