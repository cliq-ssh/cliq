import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../modules/session/view/sftp_session_page.dart';
import '../model/transfer_queue.state.dart';

final transferQueueProvider = NotifierProvider(TransferQueueNotifier.new);

class TransferQueueNotifier extends Notifier<TransferQueueState> {
  @override
  TransferQueueState build() => .initial();

  void add(String id, QueuedFileData file) {
    state = .new(
      queued: {
        ...state.queued,
        id: .new(file: file, progressData: .zero()),
      },
    );
  }

  void remove(String id) {
    state = .new(queued: {...state.queued..remove(id)});
    // TODO: cancel any in-progress transfer
  }

  void setProgress(String id, FileProgressData? data) {
    if (data == null || data.progress < 0) {
      state = .new(queued: {...state.queued..remove(id)});
      return;
    }

    if (data.progress >= 1) {
      setCompleted(id);
      return;
    }

    if (!state.queued.containsKey(id)) return;
    _modify(id, (item) => item.progressData = data);
  }

  void setCompleted(String id) => _modify(
    id,
    (item) => item.endTime = DateTime.now().millisecondsSinceEpoch,
  );
  void setError(String id, String error) =>
      _modify(id, (item) => item.error = error);

  void _modify(String id, void Function(TransferQueueItem) modify) {
    if (!state.queued.containsKey(id)) return;
    final item = state.queued[id]!;
    modify(item);
    state = .new(queued: {...state.queued, id: item});
  }
}
