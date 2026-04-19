/// AppLanguage enum — legacy screens reference this for language selection.
enum AppLanguage {
  english('en', 'English'),
  hindi('hi', 'हिन्दी'),
  marathi('mr', 'मराठी'),
  tamil('ta', 'தமிழ்');

  final String code;
  final String label;
  const AppLanguage(this.code, this.label);

  static AppLanguage fromCode(String code) => switch (code) {
        'hi' => AppLanguage.hindi,
        'mr' => AppLanguage.marathi,
        'ta' => AppLanguage.tamil,
        _    => AppLanguage.english,
      };

  @override
  String toString() => label;
}
