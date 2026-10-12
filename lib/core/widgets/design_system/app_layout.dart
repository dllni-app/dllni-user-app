import 'package:flutter/material.dart';
import 'alnadha_tokens.dart';

/// One responsive page shell; does not own navigation or business state.
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.child,
    this.header,
    this.bottomAction,
    this.scrollable = true,
    this.padding = const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 20),
  });

  final Widget child;
  final Widget? header;
  final Widget? bottomAction;
  final bool scrollable;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final body = Padding(padding: padding, child: child);
    return Scaffold(
      backgroundColor: AlnadhaTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            ?header,
            Expanded(
              child: scrollable
                  ? SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: body,
                    )
                  : body,
            ),
            if (bottomAction != null) AppBottomActionBar(child: bottomAction!),
          ],
        ),
      ),
    );
  }
}

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.section = AppSection.platform,
  });
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final AppSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AlnadhaTokens.surface,
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 12, 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: 'الرجوع',
              icon: const BackButtonIcon(),
              onPressed:
                  onBack ??
                  (Navigator.canPop(context)
                      ? () => Navigator.of(context).maybePop()
                      : null),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AlnadhaTokens.sectionTitle),
                if (subtitle != null)
                  Text(subtitle!, style: AlnadhaTokens.caption),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.selected = false,
    this.section = AppSection.platform,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final bool selected;
  final AppSection section;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final color = selected ? section.soft : AlnadhaTokens.surface;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AlnadhaTokens.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AlnadhaTokens.cardRadius),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AlnadhaTokens.cardRadius),
            border: Border.all(
              color: selected ? section.accent : AlnadhaTokens.border,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppSectionHeading extends StatelessWidget {
  const AppSectionHeading({
    super.key,
    required this.title,
    this.description,
    this.trailing,
  });
  final String title;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AlnadhaTokens.sectionTitle),
            if (description != null)
              Text(description!, style: AlnadhaTokens.caption),
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

class AppInfoRow extends StatelessWidget {
  const AppInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.leading,
  });
  final String label;
  final String value;
  final IconData? leading;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        if (leading != null) ...[
          Icon(leading, size: 18, color: AlnadhaTokens.muted),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(label, style: AlnadhaTokens.caption)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AlnadhaTokens.body,
          ),
        ),
      ],
    ),
  );
}

class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AlnadhaTokens.surface,
      border: Border(top: BorderSide(color: AlnadhaTokens.border)),
    ),
    child: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
      child: child,
    ),
  );
}
