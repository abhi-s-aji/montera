import 'package:flutter/material.dart';
import '../theme/monetra_design_system.dart';

class MonetraCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;

  const MonetraCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  State<MonetraCard> createState() => _MonetraCardState();
}

class _MonetraCardState extends State<MonetraCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = widget.backgroundColor ?? theme.cardColor;
    
    final bool isInteractive = widget.onTap != null;

    final scale = _isPressed
        ? 0.98
        : _isHovered
            ? 1.02
            : 1.0;

    final content = AnimatedContainer(
      duration: MonetraDesignSystem.durationNormal,
      curve: MonetraDesignSystem.curveDecelerate,
      padding: widget.padding ?? const EdgeInsets.all(MonetraDesignSystem.spaceL),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(MonetraDesignSystem.radiusL),
        border: widget.border ??
            Border.all(color: theme.dividerColor.withValues(alpha: 0.4), width: 1.0),
        boxShadow: isInteractive && _isHovered
            ? MonetraDesignSystem.getShadowMedium(context)
            : MonetraDesignSystem.getShadowSubtle(context),
      ),
      child: widget.child,
    );

    Widget cardWidget = AnimatedScale(
      scale: scale,
      duration: MonetraDesignSystem.durationFast,
      curve: MonetraDesignSystem.curveDecelerate,
      child: content,
    );

    if (isInteractive) {
      cardWidget = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}
