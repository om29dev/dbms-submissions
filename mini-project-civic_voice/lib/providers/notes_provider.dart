import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../core/services/reminder_service.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? reminderTime;
  final String? audioPath;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.reminderTime,
    this.audioPath,
  });
}

class NotesProvider with ChangeNotifier {
  final List<Note> _notes = [];
  final ReminderService _reminderService = ReminderService();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  List<Note> get notes => _notes;
  bool get isRecording => _isRecording;
  bool _isRecording = false;

  void addNote(String title, String content,
      {DateTime? reminderTime, String? audioPath}) {
    final note = Note(
      id: DateTime.now().toIso8601String(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      reminderTime: reminderTime,
      audioPath: audioPath,
    );
    _notes.add(note);

    if (reminderTime != null) {
      _reminderService.scheduleReminder(
        id: note.hashCode,
        title: title,
        body: content,
        scheduledTime: reminderTime,
      );
    }

    notifyListeners();
  }

  Future<void> startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/note_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);

      _isRecording = true;
      notifyListeners();
    }
  }

  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    _isRecording = false;
    notifyListeners();
    return path;
  }

  Future<void> playNote(String path) async {
    await _player.play(DeviceFileSource(path));
  }

  void deleteNote(String id) {
    final note = _notes.firstWhere((n) => n.id == id);
    if (note.audioPath != null) {
      final file = File(note.audioPath!);
      if (file.existsSync()) file.deleteSync();
    }
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
