import 'package:cliq/shared/data/database.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

extension VaultExtension on Vault {
  static List<Vault> sortVaults(List<Vault> vaults) {
    return vaults.toList()..sort((a, b) {
      if (a.owner == null && b.owner != null) {
        return -1;
      } else if (a.owner != null && b.owner == null) {
        return 1;
      } else if (a.owner != null && b.owner != null) {
        return a.owner!.compareTo(b.owner!);
      }
      return 0;
    });
  }

  String getDisplayName(BuildContext context) {
    if (owner != null && owner!.isNotEmpty) {
      return 'vault_user'.tr(context: context, args: [owner!]);
    }
    return 'vault_local'.tr(context: context);
  }
}
