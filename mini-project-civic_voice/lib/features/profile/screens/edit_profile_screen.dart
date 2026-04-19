import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/citizen_profile_provider.dart';
import '../../../widgets/cvi_button.dart';
import '../../../widgets/indian_card.dart';
import '../../../widgets/decorative/jali_pattern.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _aadhaarCtrl;
  late final TextEditingController _panCtrl;
  late final TextEditingController _rationCtrl;
  late final TextEditingController _disabilityCtrl;

  // State
  DateTime? _dob;
  String? _gender;
  String? _maritalStatus;
  String? _occupation;
  String? _incomeRange;
  String? _casteCategory;
  String? _state;
  bool _isDisabled = false;
  bool _isSaving = false;

  // Dropdown options
  static const _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  static const _maritalStatuses = ['Single', 'Married', 'Widowed', 'Divorced'];
  static const _occupations = [
    'Salaried',
    'Self-Employed',
    'Farmer',
    'Student',
    'Unemployed',
    'Other'
  ];
  static const _incomeRanges = [
    'Below ₹1 Lakh',
    '₹1L – ₹3L',
    '₹3L – ₹5L',
    '₹5L – ₹10L',
    'Above ₹10 Lakh',
  ];
  static const _casteCategories = [
    'General',
    'OBC',
    'SC',
    'ST',
    'NT-DNT',
    'EWS',
  ];

  @override
  void initState() {
    super.initState();
    final p = context.read<CitizenProfileProvider>().profile;
    _nameCtrl = TextEditingController(text: p?.fullName ?? '');
    _districtCtrl = TextEditingController(text: p?.district ?? '');
    _pincodeCtrl = TextEditingController(text: p?.pincode ?? '');
    _aadhaarCtrl = TextEditingController(text: p?.aadhaarLastFour ?? '');
    _panCtrl = TextEditingController(text: p?.panMasked ?? '');
    _rationCtrl = TextEditingController(text: p?.rationCardNumber ?? '');
    _disabilityCtrl = TextEditingController(text: p?.disabilityType ?? '');
    _dob = p?.dateOfBirth;
    _gender = p?.gender;
    _maritalStatus = p?.maritalStatus;
    _occupation = p?.occupation;
    _incomeRange = p?.annualIncomeRange;
    _casteCategory = p?.casteCategory;
    _state = (p?.state.isNotEmpty == true) ? p!.state : null;
    _isDisabled = p?.isDisabled ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _districtCtrl.dispose();
    _pincodeCtrl.dispose();
    _aadhaarCtrl.dispose();
    _panCtrl.dispose();
    _rationCtrl.dispose();
    _disabilityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<CitizenProfileProvider>();
    final current = provider.profile;
    if (current == null) return;

    final updated = current.copyWith(
      fullName: _nameCtrl.text.trim(),
      state: _state ?? current.state,
      district:
          _districtCtrl.text.trim().isEmpty ? null : _districtCtrl.text.trim(),
      pincode:
          _pincodeCtrl.text.trim().isEmpty ? null : _pincodeCtrl.text.trim(),
      dateOfBirth: _dob,
      gender: _gender,
      maritalStatus: _maritalStatus,
      occupation: _occupation,
      annualIncomeRange: _incomeRange,
      casteCategory: _casteCategory,
      aadhaarLastFour:
          _aadhaarCtrl.text.trim().isEmpty ? null : _aadhaarCtrl.text.trim(),
      panMasked: _panCtrl.text.trim().isEmpty ? null : _panCtrl.text.trim(),
      rationCardNumber:
          _rationCtrl.text.trim().isEmpty ? null : _rationCtrl.text.trim(),
      isDisabled: _isDisabled,
      disabilityType: _isDisabled && _disabilityCtrl.text.trim().isNotEmpty
          ? _disabilityCtrl.text.trim()
          : null,
    );

    final ok = await provider.updateProfile(updated);
    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.emerald,
          content: Text('Profile saved successfully!',
              style: GoogleFonts.inter(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
        ));
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.semanticError,
          content: Text('Failed to save. Please try again.',
              style: GoogleFonts.inter(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: now.subtract(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.saffron,
            surface: AppColors.bgMid,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: JaliPattern(opacity: 0.03)),
          Form(
            key: _formKey,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: AppColors.bgDeep.withValues(alpha: 0.95),
                  elevation: 0,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  title: Text('Edit Profile',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF6B1A))),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: AppColors.saffron, strokeWidth: 2))
                          : TextButton(
                              onPressed: _save,
                              child: Text('Save',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.saffron,
                                      fontWeight: FontWeight.w600)),
                            ),
                    )
                  ],
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Section 1: Personal ─────────────────────────────
                      _sectionHeader('Personal Information', '👤'),
                      const SizedBox(height: 12),
                      IndianCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _textField(
                              controller: _nameCtrl,
                              label: 'Full Name',
                              icon: Icons.person_outline_rounded,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Name is required'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            // Date of Birth
                            GestureDetector(
                              onTap: _pickDob,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.surfaceBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.cake_outlined,
                                        color: AppColors.textMuted, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _dob != null
                                            ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                                            : 'Date of Birth',
                                        style: GoogleFonts.inter(
                                          color: _dob != null
                                              ? AppColors.textPrimary
                                              : AppColors.textMuted,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today_outlined,
                                        color: AppColors.textMuted, size: 18),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _dropdown(
                              label: 'Gender',
                              icon: Icons.wc_rounded,
                              value: _gender,
                              items: _genders,
                              onChanged: (v) => setState(() => _gender = v),
                            ),
                            const SizedBox(height: 16),
                            _dropdown(
                              label: 'Marital Status',
                              icon: Icons.favorite_border_rounded,
                              value: _maritalStatus,
                              items: _maritalStatuses,
                              onChanged: (v) =>
                                  setState(() => _maritalStatus = v),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 50.ms),
                      const SizedBox(height: 24),

                      // ── Section 2: Location ─────────────────────────────
                      _sectionHeader('Location', '📍'),
                      const SizedBox(height: 12),
                      IndianCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _stateDropdown(),
                            const SizedBox(height: 16),
                            _textField(
                              controller: _districtCtrl,
                              label: 'District',
                              icon: Icons.location_city_outlined,
                            ),
                            const SizedBox(height: 16),
                            _textField(
                              controller: _pincodeCtrl,
                              label: 'Pincode',
                              icon: Icons.pin_drop_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty) return null;
                                if (v.length != 6) {
                                  return 'Enter a valid 6-digit pincode';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 24),

                      // ── Section 3: Financial & Social ────────────────────
                      _sectionHeader('Financial & Social', '💰'),
                      const SizedBox(height: 12),
                      IndianCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _dropdown(
                              label: 'Occupation',
                              icon: Icons.work_outline_rounded,
                              value: _occupation,
                              items: _occupations,
                              onChanged: (v) => setState(() => _occupation = v),
                            ),
                            const SizedBox(height: 16),
                            _dropdown(
                              label: 'Annual Income Range',
                              icon: Icons.currency_rupee_rounded,
                              value: _incomeRange,
                              items: _incomeRanges,
                              onChanged: (v) =>
                                  setState(() => _incomeRange = v),
                            ),
                            const SizedBox(height: 16),
                            _dropdown(
                              label: 'Caste Category',
                              icon: Icons.groups_outlined,
                              value: _casteCategory,
                              items: _casteCategories,
                              onChanged: (v) =>
                                  setState(() => _casteCategory = v),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 24),

                      // ── Section 4: Document IDs ──────────────────────────
                      _sectionHeader('Document IDs', '🪪'),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Only the last 4 digits of Aadhaar are stored. PAN is stored in masked form.',
                          style: GoogleFonts.inter(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                      ),
                      IndianCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _textField(
                              controller: _aadhaarCtrl,
                              label: 'Aadhaar Last 4 Digits',
                              icon: Icons.fingerprint_rounded,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty) return null;
                                if (v.length != 4) {
                                  return 'Enter exactly 4 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _textField(
                              controller: _panCtrl,
                              label: 'PAN (e.g. ABCDE1234F)',
                              icon: Icons.credit_card_rounded,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z0-9]')),
                              ],
                              validator: (v) {
                                if (v == null || v.isEmpty) return null;
                                if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$')
                                    .hasMatch(v.toUpperCase())) {
                                  return 'Enter a valid PAN format';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _textField(
                              controller: _rationCtrl,
                              label: 'Ration Card Number',
                              icon: Icons.article_outlined,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),

                      // ── Section 5: Disability ────────────────────────────
                      _sectionHeader('Disability', '♿'),
                      const SizedBox(height: 12),
                      IndianCard(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              title: Text('Person with Disability',
                                  style: GoogleFonts.inter(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
                              value: _isDisabled,
                              activeThumbColor: AppColors.saffron,
                              activeTrackColor:
                                  AppColors.saffron.withValues(alpha: 0.3),
                              inactiveTrackColor: AppColors.bgDeep,
                              onChanged: (v) => setState(() => _isDisabled = v),
                            ),
                            if (_isDisabled) ...[
                              const Divider(
                                  color: AppColors.surfaceBorder, height: 1),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 12, 20, 12),
                                child: _textField(
                                  controller: _disabilityCtrl,
                                  label: 'Disability Type',
                                  icon: Icons.accessible_rounded,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(delay: 250.ms),
                      const SizedBox(height: 32),

                      // ── Save Button ─────────────────────────────────────
                      CviButton(
                        text: _isSaving ? 'Saving…' : 'Save Profile',
                        variant: CviButtonVariant.gold,
                        onPressed: _isSaving ? null : _save,
                      ).animate().fadeIn(delay: 300.ms),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, String emoji) {
    return Row(
      children: [
        Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
                color: AppColors.saffron,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title,
            style: GoogleFonts.poppins(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16)),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.saffron, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.semanticError, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      dropdownColor: AppColors.bgMid,
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.saffron, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e,
                    style: GoogleFonts.inter(color: AppColors.textPrimary)),
              ))
          .toList(),
    );
  }

  Widget _stateDropdown() {
    final states = IndianState.values.map((s) => s.label).toList();
    return DropdownButtonFormField<String>(
      initialValue: _state,
      onChanged: (v) => setState(() => _state = v),
      dropdownColor: AppColors.bgMid,
      isExpanded: true,
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: 'State / UT',
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: const Icon(Icons.map_outlined,
            color: AppColors.textMuted, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.saffron, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: states
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text(s,
                    style: GoogleFonts.inter(
                        color: AppColors.textPrimary, fontSize: 14)),
              ))
          .toList(),
    );
  }
}
