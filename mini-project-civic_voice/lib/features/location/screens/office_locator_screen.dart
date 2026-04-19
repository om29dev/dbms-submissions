import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/glass_card.dart';

class OfficeLocatorScreen extends StatefulWidget {
  const OfficeLocatorScreen({super.key});

  @override
  State<OfficeLocatorScreen> createState() => _OfficeLocatorScreenState();
}

class _OfficeLocatorScreenState extends State<OfficeLocatorScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Passport', 'Aadhaar', 'Income Tax', 'RTO'];

  final List<Map<String, dynamic>> _offices = [
    {
      'id': '1',
      'name': 'Passport Seva Kendra, Andheri',
      'category': 'Passport',
      'address': 'The Great Oasis, Plot No D-13, MIDC Andheri (E), Mumbai - 400093',
      'phone': '1800-258-1800',
      'hours': '9:00 AM - 5:30 PM (Mon-Fri)',
      'distance': '3.2 km',
      'lat': 19.1136,
      'lng': 72.8697,
    },
    {
      'id': '2',
      'name': 'Aadhaar Enrollment Center, BKC',
      'category': 'Aadhaar',
      'address': 'Ground Floor, Plot No. C-52, G Block, Bandra Kurla Complex, Mumbai - 400051',
      'phone': '1947',
      'hours': '9:30 AM - 6:00 PM (Mon-Sat)',
      'distance': '5.8 km',
      'lat': 19.0654,
      'lng': 72.8647,
    },
    {
      'id': '3',
      'name': 'Aayakar Bhavan (Income Tax)',
      'category': 'Income Tax',
      'address': 'Maharshi Karve Road, Churchgate, Mumbai - 400020',
      'phone': '1800-180-1961',
      'hours': '9:30 AM - 6:00 PM (Mon-Fri)',
      'distance': '18.4 km',
      'lat': 18.9372,
      'lng': 72.8262,
    },
    {
      'id': '4',
      'name': 'Regional Transport Office (RTO) Andheri',
      'category': 'RTO',
      'address': 'D-111, Ambivali Village, Versova Road, Andheri West, Mumbai - 400053',
      'phone': '022-26366666',
      'hours': '10:00 AM - 5:00 PM (Mon-Sat)',
      'distance': '4.1 km',
      'lat': 19.1311,
      'lng': 72.8268,
    },
  ];

  List<Map<String, dynamic>> get _filteredOffices {
    final query = _searchCtrl.text.toLowerCase();
    return _offices.where((o) {
      final matchesSearch = o['name'].toLowerCase().contains(query) || o['address'].toLowerCase().contains(query);
      final matchesCat = _selectedCategory == 'All' || o['category'] == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();
  }

  Future<void> _launchMaps(double lat, double lng, String name) async {
    final query = Uri.encodeComponent(name);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Govt Offices Near You',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.saffron,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              borderRadius: 30,
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: GoogleFonts.poppins(color: AppColors.textPrimary),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search district, city or office...',
                        hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.2, end: 0, duration: 400.ms),

          // Categories Horizontal List
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.saffron : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.saffron : AppColors.surfaceBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
              },
            ),
          ),
          const SizedBox(height: 16),

          // Results List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _filteredOffices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final office = _filteredOffices[index];
                return _buildOfficeCard(office).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1, end: 0);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOfficeCard(Map<String, dynamic> office) {
    IconData icon;
    Color color;

    switch (office['category']) {
      case 'Passport':
        icon = Icons.airplanemode_active_rounded;
        color = AppColors.accentBlue;
        break;
      case 'Aadhaar':
        icon = Icons.fingerprint_rounded;
        color = AppColors.gold;
        break;
      case 'Income Tax':
        icon = Icons.account_balance_rounded;
        color = AppColors.emeraldLight;
        break;
      case 'RTO':
        icon = Icons.directions_car_rounded;
        color = AppColors.saffron;
        break;
      default:
        icon = Icons.business_rounded;
        color = AppColors.textPrimary;
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      office['name'],
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${office['distance']} away',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.surfaceBorder, height: 1),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on_rounded, office['address']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time_rounded, office['hours']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone_rounded, office['phone']),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchMaps(office['lat'], office['lng'], office['name']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.saffron,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.saffron),
                ),
              ),
              icon: const Icon(Icons.directions_rounded),
              label: Text(
                'Get Directions',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
