import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:civic_voice_interface/core/theme/app_theme.dart';
import 'package:civic_voice_interface/widgets/glass/glass_card.dart';
import 'package:civic_voice_interface/widgets/animated/particle_background.dart';
import 'package:civic_voice_interface/providers/language_provider.dart';
import 'package:civic_voice_interface/models/service_model_new.dart';
import 'package:civic_voice_interface/features/services/screens/service_detail_screen_new.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final allServices = ServiceModel.getAllServices();
    final categories = ServiceModel.getCategories();
    
    final filteredServices = allServices.where((service) {
      final matchesCategory = _selectedCategory == 'All' || service.category == _selectedCategory;
      final matchesSearch = service.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.deepSpaceBlue,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang.translate('all_services'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.pureWhite,
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: ParticleBackground(
              numberOfParticles: 40,
              particleColor: AppTheme.electricBlue,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildSearchBar(lang),
                ),
                
                // Category Filter
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildCategoryChip(category, isSelected, lang),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Services Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      return _buildServiceCard(filteredServices[index], lang);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(LanguageProvider lang) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: GoogleFonts.inter(color: AppTheme.pureWhite),
        decoration: InputDecoration(
          hintText: lang.translate('search_services'),
          hintStyle: GoogleFonts.inter(
            color: AppTheme.pureWhite.withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(Icons.search, color: AppTheme.electricBlue),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected, LanguageProvider lang) {
    // Translate category name
    String translatedCategory = category;
    if (category != 'All') {
      translatedCategory = lang.translate(category.toLowerCase());
    } else {
      translatedCategory = lang.translate('all');
    }
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.accentGradient
              : const LinearGradient(
                  colors: [
                    AppTheme.glassBackground,
                    AppTheme.glassBackground,
                  ],
                ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppTheme.electricBlue : AppTheme.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          translatedCategory,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: AppTheme.pureWhite,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service, LanguageProvider lang) {
    // Get translated service name and description
    String serviceKey = service.title.toLowerCase().replaceAll(' ', '_');
    String descKey = '${serviceKey}_desc';
    
    String translatedTitle = lang.translate(serviceKey);
    String translatedDesc = lang.translate(descKey);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(service: service),
          ),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    service.color.withValues(alpha: 0.3),
                    service.color.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service.icon,
                size: 32,
                color: service.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              translatedTitle,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.pureWhite,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              translatedDesc,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.pureWhite.withValues(alpha: 0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppTheme.electricBlue,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    service.processingTime,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.electricBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
