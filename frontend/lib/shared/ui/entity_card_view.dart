import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn, BreakpointMap, Breakpoint, BreakpointMapExtension, useBreakpoint;
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../provider/store.provider.dart';

enum EntityCardViewType { list, grid }

class EntityCardView<E> extends HookConsumerWidget {
  static final BreakpointMap<int> _gridWidths = {
    Breakpoint.sm: 2,
  }.cascadeUp(defaultValue: 2);

  final List<E>? entities;
  final Map<String, List<E>>? groupedEntities;
  final List<String> Function(E)? filterableFields;
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

    isFilteredOut(E entity) {
      if (filterableFields == null || filterText.value.isEmpty) return false;
      final fields = filterableFields!(entity);
      return !fields.any(
        (field) => field.toLowerCase().contains(filterText.value.toLowerCase()),
      );
    }

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
                      style: typography.xl2,
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

    buildEntity(E entity) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final gridCount = _gridWidths[breakpoint]!;

          final child = entityCardBuilder(entity);
          return viewType.value == .list
              ? child
              : SizedBox(width: ((constraints.maxWidth / gridCount) - 4 * (gridCount - 1)), child: child);
        },
      );
    }

    return entities?.isEmpty ??
            groupedEntities!.values.every((group) => group.isEmpty)
        ? buildNoEntities()
        : SingleChildScrollView(
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
                                tipBuilder: (_, _) => TextWithShortCutInfo(
                                  'Filter items',
                                  shortcut: ShortcutActionInfo(
                                    mainKey: .keyF,
                                    modifiers: {.control},
                                  ),
                                ),
                                child: ConstrainedBox(
                                  constraints: .new(maxWidth: 200),
                                  child: FTextField(
                                    control: .managed(
                                      onChange: (value) =>
                                          filterText.value = value.text,
                                    ),
                                    focusNode: filterFocusNode,
                                    hint: 'Filter',
                                    prefixBuilder: (_, _, _) => IconTheme(
                                      data: context
                                          .theme
                                          .textFieldStyle
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
                                FTooltip(
                                  tipBuilder: (_, _) => TextWithShortCutInfo(
                                    viewType.value == EntityCardViewType.list
                                        ? 'List View'
                                        : 'Grid View',
                                    shortcut: ShortcutActionInfo(
                                      mainKey: .keyG,
                                      modifiers: {.control},
                                    ),
                                  ),
                                  child: FButton.icon(
                                    variant: .outline,
                                    onPress: () => viewTypeKey.write(
                                      viewType.value == .list ? .grid : .list,
                                    ),
                                    child: Icon(
                                      viewType.value == EntityCardViewType.list
                                          ? LucideIcons.rows3
                                          : LucideIcons.grid3x2,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    CliqGridColumn(
                      child: Builder(
                        builder: (context) {
                          if (entities != null) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 16,
                              children: [
                                for (final entity in entities!)
                                  if (!isFilteredOut(entity))
                                    buildEntity(entity),
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
                                                style: typography.lg.copyWith(
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
