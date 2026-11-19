import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/worker/sftp_worker.dart';
import 'package:cliq/modules/session/worker/ssh_worker.dart';
import 'package:cliq/modules/session/worker/worker_core.dart';
import 'package:flterm/flterm.dart';

/// Disposable resources used by a [SshSession].
class const SessionResources({
  required final SshWorkerHandle? ssh,
  required final SftpWorkerHandle? sftp,
  required final TerminalController? terminalController,
}) {
  WorkerHandle get worker => (ssh ?? sftp)!;

  /// Disposes any resources associated with this session.
  void dispose() {
    ssh?.dispose();
    sftp?.dispose();
    terminalController?.dispose();
  }
}
