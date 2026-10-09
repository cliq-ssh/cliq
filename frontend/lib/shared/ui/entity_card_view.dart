import 'package:cliq/modules/vaults/extension/vault.extension.dart';
import 'package:cliq/modules/vaults/provider/vault.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/ui/cliq_tooltip.dart';
import 'package:cliq/shared/ui/list_icon.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show
        Breakpoint,
        BreakpointMap,
        BreakpointMapExtension,
        CliqGridColumn,
        CliqGridContainer,
        CliqGridRow,
        useBreakpoint;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

enum EntityCardViewType { list, grid }

class EntityCardView<E> extends HookConsumerWidget {
  static final BreakpointMap<int> _gridWidths = {Breakpoint.sm: 2}
      .cascadeUp(defaultValue: 2);

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

  const new({
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

  const new grouped({
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

    final vaults = ref.watch(vaultProvider);

    final viewType = useStore(viewTypeKey);

    final filterFocusNode = useFocusNode();
    final filterTextController = useTextEditingController();
    final filteredVaultIds = useState<Set<DbId>>(const {});
    final popoverController = useFPopoverController();

    isFilteredOut(E entity) {
      if (filterableVaultId != null) {
        final vaultId = filterableVaultId!(entity);
        if (vaultId != null && filteredVaultIds.value.contains(vaultId)) {
          return true;
        }
      }

      if (filterableFields == null || filterTextController.value.text.isEmpty) {
        return false;
      }

      final fields = filterableFields!(entity);
      return !fields.any(
        (field) => field.toLowerCase().contains(
          filterTextController.value.text.toLowerCase(),
        ),
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
                sizes: const {.sm: 12, .md: 8},
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: .center,
                  mainAxisAlignment: .center,
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
                        prefix: const Icon(LucideIcons.plus),
                        onPress: onAddEntity,
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

    buildNoMatch() {
      return CliqGridContainer(
        alignment: Alignment.center,
        children: [
          CliqGridRow(
            alignment: WrapAlignment.center,
            children: [
              CliqGridColumn(
                sizes: const {.sm: 12, .md: 8},
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
                            filterTextController.clear();
                            filteredVaultIds.value = const {};
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
                      (constraints.maxWidth / gridCount) - 4 * (gridCount - 1),
                  child: child,
                );
        },
      );
    }

    buildFilterSubmenu() {
      return FSubmenuItem(
        title: Text('filter'.tr()),
        prefix: const Icon(LucideIcons.listFilter),
        submenu: [
          .group(
            children: [
              for (final v in VaultExtension.sortVaults(vaults.entities))
                .item(
                  title: Text(v.getDisplayName(context)),
                  prefix: ListIcon(
                    type: .checkbox,
                    selected: !filteredVaultIds.value.contains(v.id),
                  ),
                  onPress: () {
                    final newSet = Set<DbId>.from(filteredVaultIds.value);
                    if (newSet.contains(v.id)) {
                      newSet.remove(v.id);
                    } else {
                      newSet.add(v.id);
                    }
                    filteredVaultIds.value = newSet;
                  },
                ),
            ],
          ),
        ],
      );
    }

    buildLayoutSubmenu() {
      return FSubmenuItem(
        title: Text('layout'.tr()),
        prefix: const Icon(LucideIcons.layoutGrid),
        submenu: [
          .group(
            children: [
              .item(
                title: Text('layout_grid'.tr()),
                prefix: ListIcon(selected: viewType.value == .grid),
                onPress: () {
                  popoverController.hide();
                  viewTypeKey.write(.grid);
                },
              ),
              .item(
                title: Text('layout_list'.tr()),
                prefix: ListIcon(selected: viewType.value == .list),
                onPress: () {
                  popoverController.hide();
                  viewTypeKey.write(.list);
                },
              ),
            ],
          ),
        ],
      );
    }

    buildDesktopMenu() {
      return FPopoverMenu(
        control: .managed(controller: popoverController),
        menu: [
          .group(children: [buildFilterSubmenu()]),
          .group(children: [buildLayoutSubmenu()]),
        ],
        builder: (_, controller, _) {
          return FButton.icon(
            variant: .outline,
            onPress: controller.toggle,
            child: const Icon(LucideIcons.ellipsis),
          );
        },
      );
    }

    buildMobileMenu() {
      return FPopoverMenu(
        control: .managed(controller: popoverController),
        menu: [
          if (addEntityTitle != null && onAddEntity != null)
            .group(
              children: [
                .item(
                  prefix: const Icon(LucideIcons.plus),
                  title: Text(addEntityTitle!),
                  onPress: () {
                    popoverController.hide();
                    onAddEntity!();
                  },
                ),
              ],
            ),
          .group(children: [buildFilterSubmenu()]),
          .group(children: [buildLayoutSubmenu()]),
        ],
        builder: (_, controller, _) {
          return FButton.icon(
            variant: .outline,
            onPress: controller.toggle,
            child: const Icon(LucideIcons.ellipsis),
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
              if (filterableFields != null)
                CliqGridColumn(
                  sizes: const {.sm: 8, .md: 6, .lg: 4},
                  child: Padding(
                    padding: const .only(bottom: 16),
                    child: CliqTooltip(
                      text: TextWithShortcutInfo(
                        'filter_items'.tr(),
                        shortcut: KeyboardShortcut(
                          .keyF,
                          modifiers: {.control},
                        ),
                      ),
                      child: FTextField(
                        control: .managed(controller: filterTextController),
                        focusNode: filterFocusNode,
                        hint: 'filter'.tr(),
                        prefixBuilder: (_, _, _) => IconTheme(
                          data: context.theme.textFieldStyles.md.iconStyle.base,
                          child: const Padding(
                            padding: .only(left: 8, right: 4),
                            child: Icon(LucideIcons.search),
                          ),
                        ),
                        clearable: (value) => value.text.isNotEmpty,
                      ),
                    ),
                  ),
                ),
              CliqGridColumn(
                sizes: filterableFields == null
                    ? const {}
                    : const {.sm: 4, .md: 6, .lg: 8},
                child: Row(
                  spacing: 8,
                  mainAxisSize: .min,
                  mainAxisAlignment: .end,
                  children: breakpoint < .md
                      ? [buildMobileMenu()]
                      : [
                          if (addEntityTitle != null && onAddEntity != null)
                            Row(
                              mainAxisSize: .min,
                              children: [
                                FButton(
                                  variant: .outline,
                                  prefix: const Icon(LucideIcons.plus),
                                  onPress: onAddEntity,
                                  child: Text(addEntityTitle!),
                                ),
                              ],
                            ),
                          buildDesktopMenu(),
                        ],
                ),
              ),
              CliqGridColumn(
                child: ValueListenableBuilder(
                  valueListenable: filterTextController,
                  builder: (context, _, _) {
                    if (isFilterViewEmpty()) {
                      return buildNoMatch();
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
