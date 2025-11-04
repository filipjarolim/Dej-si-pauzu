import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/motion.dart';
import '../foundations/spacing.dart';

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
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors; // gradient from colors[0] -> colors[1]
  final VoidCallback? onTap;
  final bool showWatermark;
  final IconData? watermarkIcon;

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

    final Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          onHighlightChanged: (bool v) => setState(() => _pressed = v),
          splashColor: cs.onPrimary.withOpacity(0.08),
          highlightColor: Colors.transparent,
          child: Ink(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
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
                            color: Colors.white.withOpacity(0.20),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Optional watermark icon at bottom-right
                if (widget.showWatermark)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon((widget.watermarkIcon ?? widget.icon), color: Colors.black.withOpacity(0.55)),
                    ),
                  ),
                // Foreground header row with small icon + subtitle
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.subtitle,
                              style: text.titleLarge!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              widget.title,
                              style: text.labelLarge!.copyWith(
                                color: Colors.white.withOpacity(0.85),
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

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      child: content,
    );
  }
}
