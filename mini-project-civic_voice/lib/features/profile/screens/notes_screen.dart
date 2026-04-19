import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass/glass_card.dart';
import '../../../providers/notes_provider.dart';
import 'package:intl/intl.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final notes = notesProvider.notes;

    return Scaffold(
      backgroundColor: AppTheme.deepSpaceBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voice Notes & Reminders',
          style: GoogleFonts.poppins(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.mic_none, size: 64, color: AppTheme.pureWhite.withValues(alpha: 0.3)),
                   const SizedBox(height: 16),
                   Text(
                     'No notes yet',
                     style: GoogleFonts.poppins(
                       color: AppTheme.pureWhite.withValues(alpha: 0.5),
                       fontSize: 18,
                     ),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     'Say "Take a note..." or "Remind me to..."',
                     style: GoogleFonts.inter(
                       color: AppTheme.pureWhite.withValues(alpha: 0.3),
                       fontSize: 14,
                     ),
                   ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final note = notes[index];
                return Dismissible(
                  key: Key(note.id),
                  onDismissed: (_) => notesProvider.deleteNote(note.id),
                  background: Container(
                    color: AppTheme.error.withValues(alpha: 0.8),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                note.title,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.electricBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (note.audioPath != null)
                              IconButton(
                                icon: const Icon(Icons.play_circle_fill, color: AppTheme.electricBlue, size: 32),
                                onPressed: () => notesProvider.playNote(note.audioPath!),
                              ),
                            if (note.reminderTime != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.warning.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.alarm, size: 14, color: AppTheme.warning),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM d, h:mm a').format(note.reminderTime!),
                                      style: GoogleFonts.inter(
                                        color: AppTheme.warning,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note.content,
                          style: GoogleFonts.inter(
                            color: AppTheme.pureWhite.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('MMM d').format(note.createdAt),
                              style: GoogleFonts.inter(
                                color: AppTheme.pureWhite.withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          if (notesProvider.isRecording) {
            final path = await notesProvider.stopRecording();
            if (path != null) {
              notesProvider.addNote('Voice Note', 'Audio recorded at ${DateFormat('HH:mm').format(DateTime.now())}', audioPath: path);
            }
          } else {
            await notesProvider.startRecording();
          }
        },
        backgroundColor: notesProvider.isRecording ? AppTheme.error : AppTheme.electricBlue,
        child: Icon(notesProvider.isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}
