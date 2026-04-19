import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/citizen_profile_provider.dart';
import '../../../../widgets/glass_card.dart';
import '../../../../models/citizen_profile_model.dart';

class CitizenProfileDashboard extends StatefulWidget {
  const CitizenProfileDashboard({super.key});

  @override
  State<CitizenProfileDashboard> createState() =>
      _CitizenProfileDashboardState();
}

class _CitizenProfileDashboardState extends State<CitizenProfileDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<CitizenProfileProvider>().profile == null) {
        context.read<CitizenProfileProvider>().fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CitizenProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Citizen Digital Profile',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.saffron,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.saffron),
            onPressed: () => provider.fetchProfile(),
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: provider.isLoading && provider.profile == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.saffron))
            : provider.profile == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Profile data not found.",
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchProfile(),
                          child: const Text("Retry Fetch"),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(context, provider.profile!),
                        const SizedBox(height: 32),
                        Text('Digital Identity',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildIdentitySection(context, provider),
                        const SizedBox(height: 32),
                        Text('History Highlights',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildHistorySection(provider.profile!),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, dynamic profile) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.saffron, AppColors.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: Center(
                  child: Text(
                    profile.fullName.substring(0, 1),
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.fullName,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('${profile.district}, ${profile.state}',
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _tag('${profile.age} Years'),
                        _tag('₹${profile.income}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: profile.isKycVerified
                            ? AppColors.emeraldLight.withValues(alpha: 0.1)
                            : AppColors.semanticError.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: profile.isKycVerified
                                ? AppColors.emeraldLight
                                : AppColors.semanticError),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              profile.isKycVerified
                                  ? Icons.verified
                                  : Icons.warning,
                              color: profile.isKycVerified
                                  ? AppColors.emeraldLight
                                  : AppColors.semanticError,
                              size: 14),
                          const SizedBox(width: 4),
                          Text(
                              profile.isKycVerified
                                  ? 'KYC Verified'
                                  : 'KYC Pending',
                              style: GoogleFonts.inter(
                                  color: profile.isKycVerified
                                      ? AppColors.emeraldLight
                                      : AppColors.semanticError,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.surfaceBorder),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showEditDialog(
                context, context.read<CitizenProfileProvider>()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.edit_note, color: AppColors.saffron, size: 16),
                const SizedBox(width: 4),
                Text('Edit Profile Details',
                    style: GoogleFonts.inter(
                        color: AppColors.saffron,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _contactInfo(Icons.phone, profile.mobile),
              _contactInfo(Icons.email, profile.email),
            ],
          )
        ],
      ),
    ).animate().slideY(begin: 0.1, end: 0);
  }

  void _showEditDialog(BuildContext context, CitizenProfileProvider provider) {
    final ageCtrl =
        TextEditingController(text: provider.profile!.age.toString());
    final incomeCtrl =
        TextEditingController(text: provider.profile!.income.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        title: Text('Update Profile',
            style: GoogleFonts.playfairDisplay(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ageCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Age',
                  labelStyle: TextStyle(color: AppColors.textMuted)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: incomeCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Annual Income',
                  labelStyle: TextStyle(color: AppColors.textMuted)),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final current = provider.profile!;
              final updated = CitizenProfileModel(
                id: current.id,
                fullName: current.fullName,
                mobile: current.mobile,
                email: current.email,
                state: current.state,
                district: current.district,
                age: int.tryParse(ageCtrl.text) ?? current.age,
                income: double.tryParse(incomeCtrl.text) ?? current.income,
                isKycVerified: current.isKycVerified,
                linkedDocuments: current.linkedDocuments,
                appliedSchemes: current.appliedSchemes,
              );
              provider.updateProfile(updated);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
            color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _contactInfo(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentBlue),
        const SizedBox(width: 8),
        Text(value,
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildIdentitySection(
      BuildContext context, CitizenProfileProvider provider) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ...provider.profile!.linkedDocuments.map((doc) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, color: AppColors.textMuted),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Text(doc,
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 14))),
                    const Icon(Icons.check_circle,
                        color: AppColors.emeraldLight, size: 18),
                  ],
                ),
              )),
          const Divider(color: AppColors.surfaceBorder),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Future integration: Link DigiLocker.')));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppColors.saffron, size: 20),
                const SizedBox(width: 8),
                Text('Link New Document',
                    style: GoogleFonts.poppins(
                        color: AppColors.saffron, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildHistorySection(dynamic profile) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: AppColors.accentBlue),
              const SizedBox(width: 12),
              Text('Previously Applied Schemes',
                  style:
                      GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: profile.appliedSchemes
                .map<Widget>((scheme) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.bgDeep,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Text(scheme,
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary, fontSize: 12)),
                    ))
                .toList(),
          )
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
