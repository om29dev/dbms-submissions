import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass/glass_card.dart';
import '../../../providers/user_provider.dart';
import '../../../models/document_model.dart';
import '../../../core/services/document_inference_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/language_provider.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  final DocumentInferenceService _inferenceService = DocumentInferenceService();
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'All',
    'Identity',
    'Property',
    'Finance',
    'Education',
    'Medical',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inferenceService.dispose();
    super.dispose();
  }

  void _showSearchDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final allDocs = userProvider.currentUser.documents;
    String query = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final results = query.isEmpty
              ? allDocs
              : allDocs
                  .where(
                      (d) => d.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();

          return Dialog(
            backgroundColor: const Color(0xFF0D1117),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    autofocus: true,
                    style: GoogleFonts.inter(color: Colors.white),
                    onChanged: (v) => setDialogState(() => query = v),
                    decoration: InputDecoration(
                      hintText: 'Search documents...',
                      hintStyle: GoogleFonts.inter(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.electricBlue),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppTheme.glassBorder),
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: AppTheme.electricBlue),
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppTheme.glassBackground,
                    ),
                  ),
                ),
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('No results for "$query"',
                        style: GoogleFonts.poppins(color: Colors.white54)),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final doc = results[i];
                        return ListTile(
                          leading: Icon(doc.icon, color: doc.color),
                          title: Text(doc.name,
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Text(doc.category,
                              style: GoogleFonts.inter(
                                  color: Colors.white54, fontSize: 11)),
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() {
                              _selectedCategory =
                                  doc.category == _selectedCategory
                                      ? 'All'
                                      : doc.category;
                              _tabController.animateTo(0);
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _scanDocument(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image != null) {
        if (!context.mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Show processing indicator
        final lang = Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.pureWhite),
                ),
                const SizedBox(width: 16),
                Text(lang.translate('ai_scanning')),
              ],
            ),
            backgroundColor: AppTheme.electricBlue,
            duration: const Duration(seconds: 2),
          ),
        );

        final result = await _inferenceService.verifyDocument(image.path);
        if (!context.mounted) return;
        final file = File(image.path);
        final sizeInMb = (await file.length()) / (1024 * 1024);

        final newDoc = UserDocument(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Scan_${DateFormat('HHmmss').format(DateTime.now())}.jpg',
          category: 'Identity',
          size: '${sizeInMb.toStringAsFixed(1)} MB',
          uploadDate: DateTime.now(),
          icon: Icons.camera_alt,
          color: result.isValid ? AppTheme.success : AppTheme.warning,
          filePath: image.path,
          status: result.isValid ? 'Verified' : 'Invalid',
          isVerified: result.isValid,
          verificationMessage: result.message,
          expiryDate: result.expiryDate,
          extractedText: result.extractedText,
        );

        if (!context.mounted) return;
        userProvider.addDocument(newDoc);

        // Show result feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.isValid ? AppTheme.success : AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );

        _tabController.animateTo(0);
      }
    } catch (e) {
      if (!context.mounted) return;
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${lang.translate('scanning_failed')}: $e'),
            backgroundColor: AppTheme.error),
      );
    }
  }

  Future<void> _pickAndUploadFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        if (!context.mounted) return;
        final platformFile = result.files.single;
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Format size
        final sizeInMb = platformFile.size / (1024 * 1024);
        final sizeStr = '${sizeInMb.toStringAsFixed(1)} MB';

        // Determine icon based on extension
        IconData icon = Icons.description;
        Color color = AppTheme.electricBlue;

        final ext = platformFile.extension?.toLowerCase();
        if (ext == 'pdf') {
          icon = Icons.picture_as_pdf;
          color = AppTheme.error;
        } else if (ext == 'jpg' || ext == 'png') {
          icon = Icons.image;
          color = AppTheme.success;
        }

        final newDoc = UserDocument(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: platformFile.name,
          category: 'Identity', // Default category
          size: sizeStr,
          uploadDate: DateTime.now(),
          icon: icon,
          color: color,
          filePath: platformFile.path,
        );

        userProvider.addDocument(newDoc);

        if (!context.mounted) return;
        final lang = Provider.of<LanguageProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.translate('upload_success')),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        _tabController.animateTo(0);
      }
    } catch (e) {
      if (!context.mounted) return;
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${lang.translate('file_error')}: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSpaceBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1117), Color(0xFF161B22)],
          ),
        ),
        child: RepaintBoundary(
          child: SafeArea(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final documents = userProvider.currentUser.documents;

                return Column(
                  children: [
                    _buildHeader(documents.length),
                    _buildTabBar(),
                    _buildCategoryFilter(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDocumentsList(documents),
                          _buildUploadSection(context),
                          _buildArchivedList(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: _buildUploadFAB(),
    );
  }

  Widget _buildHeader(int docCount) {
    final lang = Provider.of<LanguageProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.electricBlue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.folder_rounded,
              color: AppTheme.pureWhite,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.translate('my_documents'),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.pureWhite,
                  ),
                ),
                Text(
                  '$docCount ${lang.translate('documents_stored')}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.pureWhite.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: const Icon(Icons.search, color: AppTheme.electricBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final lang = Provider.of<LanguageProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: AppTheme.pureWhite,
        unselectedLabelColor: AppTheme.pureWhite.withValues(alpha: 0.5),
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: lang.translate('all_documents')),
          Tab(text: lang.translate('upload')),
          Tab(text: lang.translate('archived')),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.accentGradient : null,
                  color: isSelected ? null : AppTheme.glassBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.electricBlue
                        : AppTheme.glassBorder,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: AppTheme.pureWhite,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentsList(List<UserDocument> documents) {
    final filteredDocs = _selectedCategory == 'All'
        ? documents
        : documents.where((doc) => doc.category == _selectedCategory).toList();

    if (filteredDocs.isEmpty) {
      final lang = Provider.of<LanguageProvider>(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined,
                size: 64, color: AppTheme.pureWhite.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              lang.translate('no_documents_found'),
              style: GoogleFonts.poppins(
                  color: AppTheme.pureWhite.withValues(alpha: 0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filteredDocs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _DocumentCard(document: filteredDocs[index]),
        );
      },
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.electricBlue.withValues(alpha: 0.2),
                        AppTheme.neonCyan.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_rounded,
                    size: 80,
                    color: AppTheme.electricBlue,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  lang.translate('upload_documents'),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.pureWhite,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  lang.translate(
                      'drag_drop'), // Assuming this key covers the description or adding a new one
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.pureWhite.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _scanDocument(context),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(lang.translate('scan_ai')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.electricBlue,
                    foregroundColor: AppTheme.deepSpaceBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: AppTheme.electricBlue.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _pickAndUploadFile(context),
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(lang.translate('choose_files')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.pureWhite,
                    side: const BorderSide(color: AppTheme.glassBorder),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSupportedFormats(),
        ],
      ),
    );
  }

  Widget _buildSupportedFormats() {
    final lang = Provider.of<LanguageProvider>(context);
    final formats = ['PDF', 'JPG', 'PNG', 'DOC', 'DOCX'];
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.translate('supported_formats'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.pureWhite,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: formats.map((format) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.electricBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.electricBlue),
                ),
                child: Text(
                  format,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.electricBlue,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedList() {
    final lang = Provider.of<LanguageProvider>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.archive_outlined,
                size: 80,
                color: AppTheme.pureWhite.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                lang.translate('no_archived_docs'),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.pureWhite,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang.translate('archived_hint'),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.pureWhite.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricBlue.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _tabController.animateTo(1),
        backgroundColor: AppTheme.electricBlue,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final UserDocument document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final dateStr = DateFormat('MMM dd, yyyy').format(document.uploadDate);

    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: document.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              document.icon,
              color: document.color,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.pureWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${document.size} • $dateStr',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.pureWhite.withValues(alpha: 0.6),
                  ),
                ),
                if (document.verificationMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    document.verificationMessage!,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: document.isVerified
                          ? AppTheme.success
                          : AppTheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: document.isVerified
                  ? AppTheme.success.withValues(alpha: 0.2)
                  : (document.status == 'Scan Required'
                      ? AppTheme.glassBackground
                      : AppTheme.error.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              document.status,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: document.isVerified
                    ? AppTheme.success
                    : (document.status == 'Scan Required'
                        ? AppTheme.pureWhite.withValues(alpha: 0.5)
                        : AppTheme.error),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.pureWhite),
            color: AppTheme.deepSpaceBlue,
            onSelected: (value) {
              if (value == 'delete') {
                Provider.of<UserProvider>(context, listen: false)
                    .removeDocument(document.id);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view',
                child: Text(lang.translate('view'),
                    style: const TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(lang.translate('delete'),
                    style: const TextStyle(color: AppTheme.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
