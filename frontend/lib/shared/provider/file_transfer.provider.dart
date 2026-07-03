import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:cliq/shared/model/file_transfer.state.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../../modules/credentials/data/credential_service.dart';
import '../../modules/credentials/provider/credential_service.provider.dart';
import '../../modules/session/model/session.model.dart';
import '../../modules/session/model/sftp_transfer.model.dart';
import '../../modules/session/model/sftp_transfer_params.model.dart';
import '../../modules/session/view/sftp_session_page.dart';
import '../../modules/settings/provider/known_host_service.provider.dart';

final fileTransferProvider = NotifierProvider(FileTransferNotifier.new);

class FileTransferNotifier extends Notifier<FileTransferState> {
  static final Logger _log = Logger('FileTransferNotifier');

  @override
  FileTransferState build() => .initial();

  /// Transfers data from remote to local, local to remote or remote to remote via SFTP.
  /// This runs in a separate isolate to avoid overloading the main thread
  ///
  /// Returns a stream of [FileProgressData] objects, which can be used to track the progress of the transfer.
  Stream<FileProgressData> transferSftp(
    String id, {
    ShellSession? source,
    ShellSession? destination,
    String? sourcePath,
    String? destinationPath,
    String? localPath,
  }) {
    assert(source != null || localPath != null);
    assert(destination != null || localPath != null);

    _log.fine(
      "Starting SFTP transfer for item $id: "
      "sourcePath=$sourcePath, "
      "destinationPath=$destinationPath, "
      "localPath=$localPath",
    );

    final controller = StreamController<FileProgressData>();

    resolveParams(ShellSession? session) async {
      if (session == null) return null;
      final conn = session.connection;
      final creds = await ref
          .read(credentialServiceProvider)
          .findByIds(conn.identity?.credentialIds ?? conn.credentialIds);
      final (password, keys) =
          await CredentialService.collectAuthenticationMethods(creds);

      // find hostKey for the source/destination host
      final hostKey = await ref
          .read(knownHostServiceProvider)
          .findKeyForHost(conn.addressAndPort);

      return SftpConnectParams(
        host: conn.address,
        port: conn.port,
        username: conn.effectiveUsername!,
        hostKey: hostKey!, // must exist since we're already connected
        password: password,
        keyPems: keys.map((k) => (k as dynamic).toPem() as String).toList(),
      );
    }

    Future<void> run() async {
      final port = ReceivePort();

      final isolate = await Isolate.spawn(
        sftpTransferIsolate,
        SftpTransferParams(
          sendPort: port.sendPort,
          source: await resolveParams(source),
          sourcePath: sourcePath ?? localPath!,
          destination: await resolveParams(destination),
          destinationPath: destinationPath ?? localPath!,
        ),
      );

      _modify(id, (item) => item.isolateHandle = isolate);

      await for (final msg in port) {
        final data = msg as FileProgressData;

        // should never happen
        if (data.error != null || data.progress < 0) {
          port.close();
          controller.addError(Exception(data.error ?? "Unknown error"));
          break;
        }

        controller.add(data);

        if (data.progress >= 1.0) {
          port.close();
          break;
        }
      }
      await controller.close();
    }

    run().catchError(controller.addError);
    return controller.stream;
  }

  void add(String id, QueuedFileData file, {File? tempFile}) {
    final item = FileTransferItem(file: file, progressData: .zero())
      ..tempFile = tempFile;

    state = state.copyWith(queued: {...state.pending, id: item});
    _log.fine("Added file transfer item: $id");
  }

  Future<void> remove(String id) async {
    await _cleanup(id);
    state = state.copyWith(queued: .from(state.pending)..remove(id));
    _log.fine("Removed file transfer item: $id");
  }

  void setProgress(String id, FileProgressData? data) {
    if (data == null || data.progress < 0) {
      state = state.copyWith(queued: .from(state.pending)..remove(id));
      return;
    }

    if (data.progress >= 1) {
      complete(id);
      return;
    }

    if (!state.pending.containsKey(id)) return;
    _modify(id, (item) => item.progressData = data);
  }

  void complete(String id) {
    _modify(id, (item) => item.endTime = DateTime.now().millisecondsSinceEpoch);
    _log.fine("Completed file transfer item: $id");
  }

  void cancel(BuildContext context, String id) {
    _modify(id, (item) => item.error = "Cancelled");
    _cleanup(id);
    _log.fine("Cancelled file transfer item: $id");
  }

  /// Kills the isolate & cleans up any temporary files, if applicable.
  Future<void> _cleanup(String id) async {
    if (!state.pending.containsKey(id)) return;
    final item = state.pending[id]!;

    if (item.isolateHandle != null) {
      item.isolateHandle?.kill(priority: Isolate.immediate);
      _modify(id, (item) => item.isolateHandle = null);
      _log.fine("Killed isolate for file transfer item: $id");
    }

    if (item.tempFile != null) {
      try {
        if (await item.tempFile!.exists()) {
          await item.tempFile!.delete(recursive: true);
          _log.fine(
            "Deleted temporary file for transfer item $id: ${item.tempFile!.path}",
          );
        }
      } catch (e) {
        _log.warning(
          "Failed to delete temporary file for transfer item $id: $e",
        );
      }
      _modify(id, (item) => item.tempFile = null);
    }
  }

  void _modify(String id, void Function(FileTransferItem) modify) {
    if (!state.pending.containsKey(id)) return;
    final item = state.pending[id]!;
    modify(item);
    state = state.copyWith(queued: {...state.pending, id: item});
  }
}
