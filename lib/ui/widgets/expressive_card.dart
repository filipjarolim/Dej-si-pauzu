import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/motion.dart';
import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';

class ExpressiveCard extends StatefulWidget {
  const ExpressiveCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    this.onTap,
    this.showWatermark = false,
    this.watermarkIcon,
    this.plain = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors; // gradient from colors[0] -> colors[1]
  final VoidCallback? onTap;
  final bool showWatermark;
  final IconData? watermarkIcon;
  final bool plain; // when true: white background, black outlines playful style

  @override
  State<ExpressiveCard> createState() => _ExpressiveCardState();
}

class _ExpressiveCardState extends State<ExpressiveCard> {
  bool _pressed = false;

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.selectionClick();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool plain = widget.plain;
    final Color fg = plain ? AppColors.black : AppColors.white;

    final Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onHighlightChanged: (bool v) => setState(() => _pressed = v),
          splashColor: (plain ? AppColors.primary : cs.onPrimary).withOpacity(0.08),
          highlightColor: Colors.transparent,
          child: Ink(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              color: plain ? AppColors.white : null,
              border: plain
                  ? Border.all(
                      color: AppColors.gray300.withOpacity(0.6),
                      width: DesignTokens.borderMedium,
                    )
                  : null,
              boxShadow: plain ? DesignTokens.shadowMd : null,
              gradient: plain
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.colors,
                    ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // Large, bold background title with low contrast
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints c) {
                    final double fontSize = c.maxWidth * 0.28; // proportional to width
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Align(
                        alignment: const Alignment(-0.95, 0.2),
                        child: Text(
                          widget.title.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: text.displaySmall!.copyWith(
                            fontSize: fontSize,
                            height: 0.9,
                            letterSpacing: -1.0,
                            fontWeight: FontWeight.w800,
                            color: (plain ? AppColors.black : AppColors.white).withOpacity(plain ? 0.04 : 0.20),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Optional watermark icon at bottom-right
                if (widget.showWatermark)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: plain
                            ? AppColors.black.withOpacity(0.04)
                            : AppColors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: plain
                            ? Border.all(
                                color: AppColors.black.withOpacity(0.08),
                                width: DesignTokens.borderThin,
                              )
                            : null,
                      ),
                      child: Icon(
                        (widget.watermarkIcon ?? widget.icon),
                        size: DesignTokens.iconMd,
                        color: plain
                            ? AppColors.black.withOpacity(0.3)
                            : AppColors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                // Foreground header row with small icon + subtitle
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: DesignTokens.containerMd,
                        height: DesignTokens.containerMd,
                        decoration: BoxDecoration(
                          color: plain
                              ? AppColors.primary.withOpacity(0.08)
                              : AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                          border: plain
                              ? Border.all(
                                  color: AppColors.primary.withOpacity(0.15),
                                  width: DesignTokens.borderThin,
                                )
                              : null,
                        ),
                        child: Icon(
                          widget.icon,
                          size: DesignTokens.iconMd,
                          color: plain ? AppColors.primary : fg.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.subtitle,
                              style: text.titleLarge!.copyWith(
                                color: fg,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.title,
                              style: text.labelLarge!.copyWith(
                                color: fg.withOpacity(plain ? 0.85 : 0.85),
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return RepaintBoundary(
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.smooth, // Optimized for performance
        child: content,
      ),
    );
  }
}
