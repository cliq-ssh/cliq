import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ResponsiveExpandableSidebar extends StatefulHookConsumerWidget {
  final Widget child;
  final ResponsiveSidebarController controller;
  final Color backgroundColor;
  final double minWidth;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext, bool)? headerBuilder;
  final Widget Function(BuildContext, bool)? footerBuilder;
  final List<Widget> Function(BuildContext, bool)? contentBuilder;

  const ResponsiveExpandableSidebar({
    super.key,
    required this.child,
    required this.controller,
    required this.backgroundColor,
    this.headerBuilder,
    this.footerBuilder,
    this.minWidth = 80,
    this.maxWidth = 275,
    this.padding,
    this.contentBuilder,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResponsiveSidebarState();
}

class _ResponsiveSidebarState
    extends ConsumerState<ResponsiveExpandableSidebar> {
  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(widget.controller.isExpanded);

    useEffect(() {
      void listener() => isExpanded.value = widget.controller.isExpanded;
      widget.controller.addListener(listener);
      return () => widget.controller.removeListener(listener);
    }, [widget.controller]);

    return FScaffold(
      childPad: false,
      child: Row(
        children: [
          Container(
            width: isExpanded.value ? widget.maxWidth : widget.minWidth + 1,
            height: double.infinity,
            padding: widget.padding ?? .zero,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              border: Border(
                right: BorderSide(color: context.theme.colors.border, width: 1),
              ),
            ),
            child: Padding(
              padding: const .symmetric(vertical: 16),
              child: Column(
                spacing: 8,
                children: [
                  ?widget.headerBuilder?.call(context, isExpanded.value),
                  if (widget.contentBuilder != null)
                    Expanded(
                      child: ListView(
                        children: widget.contentBuilder!.call(
                          context,
                          isExpanded.value,
                        ),
                      ),
                    ),
                  ?widget.footerBuilder?.call(context, isExpanded.value),
                ],
              ),
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class ResponsiveSidebarController extends ChangeNotifier {
  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void expand() {
    _isExpanded = true;
    notifyListeners();
  }

  void collapse() {
    _isExpanded = false;
    notifyListeners();
  }
}
