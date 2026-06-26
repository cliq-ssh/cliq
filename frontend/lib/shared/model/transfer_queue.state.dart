import '../../modules/session/view/sftp_session_page.dart';

class TransferQueueItem {
  final QueuedFileData file;
  final int startTime;
  FileProgressData progressData;

  int? endTime;
  String? error;

  TransferQueueItem({required this.file, required this.progressData})
    : startTime = DateTime.now().millisecondsSinceEpoch;

  bool get isInProgress => endTime == null && error == null;
}

class TransferQueueState {
  final Map<String, TransferQueueItem> queued;

  const TransferQueueState.initial() : queued = const {};

  const TransferQueueState({required this.queued});

  bool isPending(String id) => queued[id]?.isInProgress == true;

  bool get isAnyPending => queued.values.any((item) => item.isInProgress);

  bool get isEmpty => queued.isEmpty;
  bool get isNotEmpty => queued.isNotEmpty;
}
