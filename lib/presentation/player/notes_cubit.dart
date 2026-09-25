import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/notes_repository.dart';

enum NoteStatus { idle, typing, saved }

/// The student's note for one lesson, saved shortly after typing stops.
class NotesCubit extends Cubit<NoteStatus> {
  NotesCubit({
    required this.courseId,
    required this.lessonId,
    required NotesRepository repository,
  }) : _repository = repository,
       initialText = repository.getNote(courseId, lessonId),
       super(NoteStatus.idle);

  final String courseId;
  final String lessonId;
  final String initialText;
  final NotesRepository _repository;

  Timer? _debounce;
  String? _unsaved;

  void onChanged(String text) {
    _unsaved = text;
    emit(NoteStatus.typing);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _flush);
  }

  Future<void> _flush() async {
    final text = _unsaved;
    if (text == null) return;
    _unsaved = null;
    await _repository.saveNote(courseId, lessonId, text);
    if (!isClosed) emit(NoteStatus.saved);
  }

  @override
  Future<void> close() async {
    _debounce?.cancel();
    await _flush(); // keep what was typed right before leaving
    return super.close();
  }
}
