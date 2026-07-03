import 'dart:io';
import 'dart:isolate';

import '../../modules/session/view/sftp_session_page.dart';

class FileTransferItem {
  final QueuedFileData file;
  final int startTime;
  FileProgressData progressData;

  Isolate? isolateHandle;
  File? tempFile;
  int? endTime;
  String? error;

  FileTransferItem({required this.file, required this.progressData})
    : startTime = DateTime.now().millisecondsSinceEpoch;

  bool get isInProgress => endTime == null && error == null;
}

class FileTransferState {
  final Map<String, FileTransferItem> queued;

  FileTransferState.initial() : queued = const {};

  FileTransferState({required this.queued});

  bool isPending(String id) => queued[id]?.isInProgress == true;

  bool get isAnyPending => queued.values.any((item) => item.isInProgress);

  bool get isEmpty => queued.isEmpty;
  bool get isNotEmpty => queued.isNotEmpty;

  FileTransferState copyWith({Map<String, FileTransferItem>? queued}) {
    return FileTransferState(queued: queued ?? this.queued);
  }
}
