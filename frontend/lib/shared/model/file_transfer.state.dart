import 'dart:io';
import 'dart:isolate';

import 'package:cliq/modules/session/page/sftp_session.page.dart';

class FileTransferItem {
  final QueuedFileData file;
  final int startTime;
  FileProgressData progressData;

  Isolate? isolateHandle;
  File? tempFile;
  int? endTime;
  String? error;

  new({required this.file, required this.progressData})
    : startTime = DateTime.now().millisecondsSinceEpoch;

  bool get isInProgress => endTime == null && error == null;
}

class FileTransferState {
  final Map<String, FileTransferItem> pending;

  new initial() : pending = const {};

  new({required this.pending});

  bool isPending(String id) => pending[id]?.isInProgress == true;

  bool get isAnyPending => pending.values.any((item) => item.isInProgress);

  bool get isEmpty => pending.isEmpty;
  bool get isNotEmpty => pending.isNotEmpty;

  FileTransferState copyWith({Map<String, FileTransferItem>? pending}) {
    return FileTransferState(pending: pending ?? this.pending);
  }
}
