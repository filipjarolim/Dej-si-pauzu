import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import '../foundations/colors.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final Animation<double> animation;
  final VoidCallback? onLongPress;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.animation,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2), // Slide up slightly
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
        child: Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () {
              if (onLongPress != null) {
                HapticFeedback.heavyImpact();
                onLongPress!();
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
              child: isUser ? _buildUserBubble() : _buildAIBubble(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepBlue, AppColors.violet], // Vibrant Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildAIBubble(BuildContext context) {
    // Solid White "Paper-like" for high contrast
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // Almost solid white
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: _buildMarkdownContent(context, text),
    );
  }

  Widget _buildMarkdownContent(BuildContext context, String text) {
    // Split by navigation tags for AI messages
    final RegExp navRegex = RegExp(r'\[\[NAVIGATE:([^\]]+)\]\]');
    final List<Widget> children = [];
    int lastMatchEnd = 0;

    for (final Match match in navRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        children.add(MarkdownBody(
          data: text.substring(lastMatchEnd, match.start),
          styleSheet: MarkdownStyleSheet(
            // Dark text for white bubble - Fix for invisible text
            p: const TextStyle(color: Color(0xFF2C3E50), fontSize: 17, height: 1.5),
            strong: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold),
            listBullet: const TextStyle(color: AppColors.primary, fontSize: 17), 
            blockquote: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
            code: const TextStyle(backgroundColor: Color(0xFFF1F5F9), color: AppColors.deepBlue, fontFamily: 'monospace'),
          ),
        ));
      }

      final String route = match.group(1)!;
      children.add(
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
          child: _buildNavigationChip(context, route),
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      children.add(MarkdownBody(
        data: text.substring(lastMatchEnd),
        styleSheet: MarkdownStyleSheet(
            // Dark text for white bubble
            p: const TextStyle(color: Color(0xFF2C3E50), fontSize: 17, height: 1.5),
            h1: const TextStyle(color: Color(0xFF2C3E50), fontSize: 22, fontWeight: FontWeight.bold),
            h2: const TextStyle(color: Color(0xFF2C3E50), fontSize: 20, fontWeight: FontWeight.bold),
            h3: const TextStyle(color: Color(0xFF2C3E50), fontSize: 18, fontWeight: FontWeight.bold),
            strong: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold),
            listBullet: const TextStyle(color: AppColors.primary, fontSize: 17),
            blockquote: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
            blockquoteDecoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
            ),
            code: const TextStyle(
              backgroundColor: Colors.transparent, 
              color: AppColors.deepBlue, 
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            codeblockDecoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Light grey for code blocks
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildNavigationChip(BuildContext context, String route) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          FocusScope.of(context).unfocus(); // Close keyboard
          context.go(route); // Use go instead of push to avoid duplicate keys/stacking
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.white),
              const SizedBox(width: 8),
              Text(
                'Otevřít ${route.split('/').last.toUpperCase()}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // Staggered sine wave
                    final double offset = 4.0 *
                        (0.5 + 0.5 * 
                            // math.sin(...) - needs import math. Using simple absolute calculation or adding math import.
                            // Simplified bounce:
                             _controller.value * 6.28 + (index * 1.0) 
                        ); 
                    // To avoid importing math just for sin, let's use a scale transition or opacity
                    // Or I can just import dart:math
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5 + (0.5 * ((_controller.value + index * 0.33) % 1.0)).clamp(0.0, 0.4)), // Simple pulsing
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
