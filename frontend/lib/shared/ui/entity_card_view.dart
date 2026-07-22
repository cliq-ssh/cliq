import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show
        CliqGridContainer,
        CliqGridRow,
        CliqGridColumn,
        BreakpointMap,
        Breakpoint,
        BreakpointMapExtension,
        useBreakpoint;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../modules/vaults/provider/vault.provider.dart';
import '../provider/store.provider.dart';

enum EntityCardViewType { list, grid }

class EntityCardView<E> extends HookConsumerWidget {
  static final BreakpointMap<int> _gridWidths = {
    Breakpoint.sm: 2,
  }.cascadeUp(defaultValue: 2);

  final List<E>? entities;
  final Map<String, List<E>>? groupedEntities;
  final List<String> Function(E)? filterableFields;
  final DbId? Function(E)? filterableVaultId;
  final StoreKey<EntityCardViewType> viewTypeKey;
  final String noEntitiesTitle;
  final String noEntitiesSubtitle;
  final String? addEntityTitle;
  final VoidCallback? onAddEntity;
  final Widget Function(E entity) entityCardBuilder;

  const EntityCardView({
    super.key,
    required this.entities,
    required this.viewTypeKey,
    required this.entityCardBuilder,
    required this.noEntitiesTitle,
    required this.noEntitiesSubtitle,
    this.filterableFields,
    required this.filterableVaultId,
    this.addEntityTitle,
    this.onAddEntity,
  }) : groupedEntities = null;

  const EntityCardView.grouped({
    super.key,
    required this.groupedEntities,
    required this.viewTypeKey,
    required this.entityCardBuilder,
    required this.noEntitiesTitle,
    required this.noEntitiesSubtitle,
    this.filterableFields,
    required this.filterableVaultId,
    this.addEntityTitle,
    this.onAddEntity,
  }) : entities = null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.theme.typography;
    final breakpoint = useBreakpoint();
    final viewType = useStore(viewTypeKey);
    final filterText = useState('');
    final filterFocusNode = useFocusNode();
    final filterVaultId = useState<List<DbId>?>(null);

    final defaultVault = useState<Vault?>(null);
    final vaults = ref.watch(vaultProvider);

    useEffect(() {
      ref.read(vaultProvider.notifier).findOrCreateLocalVault().then((vault) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          defaultVault.value = vault;
        });
      });
      return null;
    }, []);

    isFilteredOut(E entity) {
      if (filterableVaultId != null && filterVaultId.value != null) {
        final vaultId = filterableVaultId!(entity);
        if (vaultId == null || !filterVaultId.value!.contains(vaultId)) {
          return true;
        }
      }

      if (filterableFields == null || filterText.value.isEmpty) return false;

      final fields = filterableFields!(entity);
      return !fields.any(
        (field) => field.toLowerCase().contains(filterText.value.toLowerCase()),
      );
    }

    isFilterViewEmpty() =>
        entities?.every(isFilteredOut) ??
        groupedEntities!.values.every((group) => group.every(isFilteredOut));

    buildNoEntities() {
      return CliqGridContainer(
        alignment: Alignment.center,
        children: [
          CliqGridRow(
            alignment: WrapAlignment.center,
            children: [
              CliqGridColumn(
                sizes: {.sm: 12, .md: 8},
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      noEntitiesTitle,
                      textAlign: TextAlign.center,
                      style: typography.body.xl2,
                    ),
                    Text(noEntitiesSubtitle, textAlign: TextAlign.center),
                    if (addEntityTitle != null && onAddEntity != null) ...[
                      const SizedBox(height: 8),
                      FButton(
                        prefix: Icon(LucideIcons.plus),
                        onPress: onAddEntity!,
                        child: Text(addEntityTitle!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    buildNoFilteredEntities() {
      return CliqGridContainer(
        alignment: Alignment.center,
        children: [
          CliqGridRow(
            alignment: WrapAlignment.center,
            children: [
              CliqGridColumn(
                sizes: {.sm: 12, .md: 8},
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: .center,
                  mainAxisAlignment: .center,
                  children: [
                    Text(
                      'filters_no_match'.tr(),
                      textAlign: TextAlign.center,
                      style: typography.body.md.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: .center,
                      children: [
                        FButton(
                          variant: .outline,
                          onPress: () {
                            filterText.value = '';
                            filterVaultId.value = null;
                          },
                          child: Text('filters_reset'.tr()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    buildEntity(E entity) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final gridCount = _gridWidths[breakpoint]!;

          final child = entityCardBuilder(entity);
          return PlatformUtils.isMobile || viewType.value == .list
              ? child
              : SizedBox(
                  width:
                      ((constraints.maxWidth / gridCount) -
                      4 * (gridCount - 1)),
                  child: child,
                );
        },
      );
    }

    buildMenu() {
      onVaultTap(DbId vaultId) {
        final current = filterVaultId.value ?? [];
        if (current.contains(vaultId)) {
          filterVaultId.value = current.where((id) => id != vaultId).toList();
        } else {
          filterVaultId.value = [...current, vaultId];
        }
      }

      return FPopoverMenu(
        menu: [
          .group(
            children: [
              .item(
                title: Text('show_all_vaults'.tr()),
                prefix: filterVaultId.value == null
                    ? Icon(LucideIcons.check)
                    : SizedBox(width: 16),
                onPress: () {
                  filterVaultId.value = filterVaultId.value == null ? [] : null;
                },
              ),
            ],
          ),
          if (filterVaultId.value != null)
            .group(
              children: [
                if (defaultVault.value != null)
                  .item(
                    prefix:
                        filterVaultId.value?.contains(defaultVault.value!.id) ??
                            false
                        ? Icon(LucideIcons.check)
                        : SizedBox(width: 16),
                    title: Text('local_vault'.tr()),
                    onPress: () => onVaultTap(defaultVault.value!.id),
                  ),
                for (final v in vaults.entities.where((v) => !v.isDefault))
                  .item(
                    prefix: filterVaultId.value?.contains(v.id) ?? false
                        ? Icon(LucideIcons.check)
                        : SizedBox(width: 16),
                    title: Text(v.label),
                    onPress: () => onVaultTap(v.id),
                  ),
              ],
            ),
          if (PlatformUtils.isDesktop)
            .group(
              children: [
                .item(
                  title: Text('views.grid'.tr()),
                  prefix: viewType.value == .grid
                      ? Icon(LucideIcons.check)
                      : SizedBox(width: 16),
                  onPress: () => viewTypeKey.write(.grid),
                ),
                .item(
                  title: Text('views.list'.tr()),
                  prefix: viewType.value == .list
                      ? Icon(LucideIcons.check)
                      : SizedBox(width: 16),
                  onPress: () => viewTypeKey.write(.list),
                ),
              ],
            ),
        ],
        builder: (_, controller, _) {
          return FButton.icon(
            variant: .outline,
            onPress: controller.toggle,
            child: Icon(LucideIcons.ellipsis),
          );
        },
      );
    }

    if (entities?.isEmpty ??
        groupedEntities!.values.every((group) => group.isEmpty)) {
      return buildNoEntities();
    }

    return SingleChildScrollView(
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                child: Padding(
                  padding: const .only(bottom: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: .spaceBetween,
                    children: [
                      if (filterableFields != null)
                        FTooltip(
                          tipBuilder: (_, _) => TextWithShortcutInfo(
                            'filter_items'.tr(),
                            shortcut: KeyboardShortcut(
                              .keyF,
                              modifiers: {.control},
                            ),
                          ),
                          child: ConstrainedBox(
                            constraints: .new(maxWidth: 200),
                            child: SizedBox(
                              child: FTextField(
                                control: .managed(
                                  onChange: (value) =>
                                      filterText.value = value.text,
                                ),
                                focusNode: filterFocusNode,
                                hint: 'filter'.tr(),
                                prefixBuilder: (_, _, _) => IconTheme(
                                  data: context
                                      .theme
                                      .textFieldStyles
                                      .md
                                      .iconStyle
                                      .base,
                                  child: Padding(
                                    padding: const .only(left: 8, right: 4),
                                    child: Icon(LucideIcons.search),
                                  ),
                                ),
                                clearable: (value) => value.text.isNotEmpty,
                              ),
                            ),
                          ),
                        ),
                      Row(
                        spacing: 8,
                        mainAxisSize: .min,
                        children: [
                          if (addEntityTitle != null && onAddEntity != null)
                            Row(
                              mainAxisSize: .min,
                              children: [
                                FButton(
                                  variant: .outline,
                                  prefix: Icon(LucideIcons.plus),
                                  onPress: onAddEntity!,
                                  child: Text(addEntityTitle!),
                                ),
                              ],
                            ),
                          buildMenu(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              CliqGridColumn(
                child: Builder(
                  builder: (context) {
                    if (isFilterViewEmpty()) {
                      return buildNoFilteredEntities();
                    }

                    if (entities != null) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 16,
                        children: [
                          for (final entity in entities!)
                            if (!isFilteredOut(entity)) buildEntity(entity),
                        ],
                      );
                    }

                    return Column(
                      spacing: 16,
                      children: [
                        for (final group in groupedEntities!.entries)
                          if (group.value.any(
                            (entity) => !isFilteredOut(entity),
                          ))
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    spacing: 8,
                                    crossAxisAlignment: .start,
                                    children: [
                                      Text(
                                        group.key,
                                        style: typography.body.lg.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 16,
                                        children: [
                                          for (final entity in group.value)
                                            if (!isFilteredOut(entity))
                                              buildEntity(entity),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
