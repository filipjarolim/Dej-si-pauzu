import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../foundations/spacing.dart';
import '../foundations/design_tokens.dart';
import '../foundations/colors.dart';
import '../foundations/motion.dart';
import '../widgets/app_button.dart';
import '../widgets/app_scaffold.dart';

// Internal model for mood entries
class MoodEntry {
  final DateTime timestamp;
  final int moodIndex;
  final String note;
  final List<String> activities;

  MoodEntry({
    required this.timestamp,
    required this.moodIndex,
    required this.note,
    required this.activities,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'moodIndex': moodIndex,
        'note': note,
        'activities': activities,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        timestamp: DateTime.parse(json['timestamp']),
        moodIndex: json['moodIndex'],
        note: json['note'] ?? '',
        activities: List<String>.from(json['activities'] ?? []),
      );
}

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> with TickerProviderStateMixin {
  int? _selectedMood;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _selectedActivities = [];
  
  late AnimationController _waveController;
  late AnimationController _rippleController;
  final List<AnimationController> _moodControllers = <AnimationController>[];
  final List<AnimationController> _bounceControllers = <AnimationController>[];
  
  List<MoodEntry> _entries = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _moods = <Map<String, dynamic>>[
    <String, dynamic>{
      'icon': Icons.bedtime,
      'label': 'Unavený',
      'subtitle': 'Potřebuju pauzu',
      'color': const Color(0xFF6366F1), // Indigo
      'emoji': '😴',
      'description': 'Cítím se vyčerpaně',
    },
    <String, dynamic>{
      'icon': Icons.sentiment_dissatisfied,
      'label': 'Nedobře',
      'subtitle': 'Mohlo by být líp',
      'color': const Color(0xFFF97316),
      'emoji': '😕',
      'description': 'Není to ideální',
    },
    <String, dynamic>{
      'icon': Icons.sentiment_neutral,
      'label': 'OK',
      'subtitle': 'V pohodě',
      'color': const Color(0xFFFBBF24),
      'emoji': '😐',
      'description': 'Nic zvláštního',
    },
    <String, dynamic>{
      'icon': Icons.sentiment_satisfied,
      'label': 'Dobře',
      'subtitle': 'Příjemný den',
      'color': const Color(0xFF34D399),
      'emoji': '🙂',
      'description': 'Cítím se dobře',
    },
    <String, dynamic>{
      'icon': Icons.sentiment_very_satisfied,
      'label': 'Skvělý',
      'subtitle': 'Plný energie',
      'color': const Color(0xFFEC4899), // Pink
      'emoji': '🤩',
      'description': 'Cítím se skvěle',
    },
  ];

  final List<String> _activities = [
    'Práce',
    'Rodina',
    'Škola',
    'Jídlo',
    'Sport',
    'Spánek',
    'Relax',
    'Rande',
    'Cestování',
    'Hraní',
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create animation controllers for each mood
    for (int i = 0; i < _moods.length; i++) {
      final AnimationController controller = AnimationController(
        vsync: this,
        duration: AppMotion.medium,
      );
      final AnimationController bounceController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      _moodControllers.add(controller);
      _bounceControllers.add(bounceController);
      // Stagger the initial animations
      Future<void>.delayed(Duration(milliseconds: 50 * i), () {
        if (mounted) {
          controller.forward();
        }
      });
    }
  }

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString('mood_entries');
      if (entriesJson != null) {
        final List<dynamic> decoded = jsonDecode(entriesJson);
        setState(() {
          _entries = decoded.map((e) => MoodEntry.fromJson(e)).toList();
          _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    } catch (e) {
      debugPrint('Error loading mood entries: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveEntry() async {
    if (_selectedMood == null) return;

    final entry = MoodEntry(
      timestamp: DateTime.now(),
      moodIndex: _selectedMood!,
      note: _noteController.text,
      activities: List.from(_selectedActivities),
    );

    setState(() {
      _entries.insert(0, entry);
      _selectedMood = null;
      _activitiesSelectedForEntry(); // Clear selection
      _noteController.clear();
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString('mood_entries', encoded);
      
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Nálada byla uložena'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
        FocusManager.instance.primaryFocus?.unfocus();
      }
    } catch (e) {
      debugPrint('Error saving mood entry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chyba při ukládání')),
        );
      }
    }
  }

  void _activitiesSelectedForEntry() {
    _selectedActivities.clear();
  }

  void _toggleActivity(String activity) {
    setState(() {
      if (_selectedActivities.contains(activity)) {
        _selectedActivities.remove(activity);
      } else {
        _selectedActivities.add(activity);
      }
      HapticFeedback.lightImpact();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _rippleController.dispose();
    _noteController.dispose();
    for (final AnimationController controller in _moodControllers) {
      controller.dispose();
    }
    for (final AnimationController controller in _bounceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectMood(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedMood = index);
    _bounceControllers[index].forward(from: 0.0).then((_) {
      _bounceControllers[index].reverse();
    });
    _rippleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Size screenSize = MediaQuery.of(context).size;

    return AppScaffold(
      appBar: AppBar(title: const Text('Nálada')),
      body: Stack(
        children: <Widget>[
          // Animated background wave (Subtle)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                  painter: _WavePainter(
                    progress: _waveController.value,
                    color: _selectedMood != null
                        ? (_moods[_selectedMood!]['color'] as Color).withOpacity(0.05) // Very subtle
                        : AppColors.primary.withOpacity(0.02),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: AppSpacing.xl),
                // Header section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Jak se cítíš?',
                        style: text.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Zaznamenej svou náladu a sleduj, jak se mění v čase.',
                        style: text.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl + 8),
                
                // Mood selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate width for 3 items per row with spacing
                      // Available width is constraint.maxWidth
                      // Spacing: 2 gaps of AppSpacing.md (16)
                      // Width = (Total - (Items-1)*Gap) / Items
                      final double itemWidth = (constraints.maxWidth - (AppSpacing.md * 2)) / 3;
                      // Clamp to reasonable sizes
                      final double safeItemWidth = itemWidth.clamp(80.0, 140.0);

                      return Center(
                        child: Wrap(
                          spacing: AppSpacing.md,
                          runSpacing: AppSpacing.md,
                          alignment: WrapAlignment.center,
                          children: List<Widget>.generate(
                            _moods.length,
                            (int index) {
                              return _buildMoodCard(index, text, cs, safeItemWidth);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Details Form (Activity & Note)
                if (_selectedMood != null) ...[
                  AnimatedSwitcher(
                    duration: AppMotion.medium,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMoodDetails(_selectedMood!, text, cs),
                        const SizedBox(height: AppSpacing.xl),
                        
                        // Activities
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Co právě děláš?',
                                style: text.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _activities.map((activity) {
                                  final isSelected = _selectedActivities.contains(activity);
                                  return FilterChip(
                                    label: Text(activity),
                                    selected: isSelected,
                                    onSelected: (_) => _toggleActivity(activity),
                                    selectedColor: (_moods[_selectedMood!]['color'] as Color).withValues(alpha: 0.2),
                                    checkmarkColor: _moods[_selectedMood!]['color'] as Color,
                                    labelStyle: TextStyle(
                                      color: isSelected 
                                          ? (_moods[_selectedMood!]['color'] as Color).withValues(alpha: 1.0) // fixed for contrast
                                          : cs.onSurface,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected 
                                            ? (_moods[_selectedMood!]['color'] as Color)
                                            : AppColors.gray200,
                                      ),
                                    ),
                                    backgroundColor: AppColors.white,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),
                        
                        // Note Input
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              labelText: 'Poznámka (volitelné)',
                              hintText: 'Co ti běží hlavou?',
                              prefixIcon: const Icon(Icons.edit_note_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                                borderSide: BorderSide(color: AppColors.gray200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                                borderSide: BorderSide(color: AppColors.gray200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                                borderSide: BorderSide(
                                  color: _moods[_selectedMood!]['color'] as Color,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                            ),
                            maxLines: 2,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Submit button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: AnimatedOpacity(
                    opacity: _selectedMood != null ? 1.0 : 0.4,
                    duration: AppMotion.fast,
                    child: AppButton(
                      label: 'Uložit záznam',
                      onPressed: _selectedMood != null ? _saveEntry : null,
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // History Section
                if (_entries.isNotEmpty || _isLoading) ...[
                 Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Historie nálad',
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_entries.length > 5)
                          TextButton(
                            onPressed: () {
                               // Navigate to full history page
                            },
                            child: const Text('Zobrazit vše'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  if (_isLoading)
                     const Center(child: CircularProgressIndicator())
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: math.min(_entries.length, 5), // Show max 5 recent items
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(_entries[index], text);
                      },
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(int index, TextTheme text, ColorScheme cs, double cardWidth) {
    final Map<String, dynamic> mood = _moods[index];
    final bool isSelected = _selectedMood == index;
    final AnimationController controller = _moodControllers[index];
    final AnimationController bounceController = _bounceControllers[index];

    // Width is now passed in
    final double safeWidth = cardWidth;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[controller, bounceController]),
      builder: (BuildContext context, Widget? child) {
        final double scale = (0.9 + (controller.value * 0.1)) * (1.0 + (bounceController.value * 0.1));
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: 0.5 + (controller.value * 0.5), // More opaque when active
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _selectMood(index),
        child: Container(
          width: safeWidth,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent, // Only white bg when selected
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: (mood['color'] as Color).withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Pure Emoji Scale
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 64 : 56,
                height: isSelected ? 64 : 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (mood['color'] as Color).withOpacity(0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    mood['emoji'] as String,
                    style: TextStyle(
                      fontSize: isSelected ? 40 : 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mood['label'] as String,
                style: text.titleSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.gray900 : AppColors.gray500,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodDetails(int index, TextTheme text, ColorScheme cs) {
    final Map<String, dynamic> mood = _moods[index];
    final Color moodColor = mood['color'] as Color;

    return Container(
      key: ValueKey<int>(index),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: moodColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: moodColor.withValues(alpha: 0.2),
          width: DesignTokens.borderMedium,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: moodColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                mood['emoji'] as String,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  mood['label'] as String,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: moodColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mood['description'] as String,
                  style: text.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(MoodEntry entry, TextTheme text) {
    final int index = entry.moodIndex;
    // Handle invalid index gracefully if moods usage changes later
    if (index >= _moods.length) return const SizedBox.shrink();

    final Map<String, dynamic> mood = _moods[index];
    
    // Format timestamp
    final now = DateTime.now();
    final diff = now.difference(entry.timestamp);
    String timeLabel;
    if (diff.inMinutes < 60) {
      timeLabel = 'Před ${diff.inMinutes} min';
    } else if (diff.inHours < 24 && now.day == entry.timestamp.day) {
      timeLabel = 'Dnes ${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 1 && now.day != entry.timestamp.day) {
       timeLabel = 'Včera';
    } else {
      timeLabel = '${entry.timestamp.day}.${entry.timestamp.month}.';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (mood['color'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                 mood['emoji'] as String,
                 style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mood['label'] as String,
                      style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      timeLabel,
                      style: text.bodySmall?.copyWith(color: AppColors.gray500),
                    ),
                  ],
                ),
                if (entry.activities.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: entry.activities.map((tag) => 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: Text(
                          tag,
                          style: text.labelSmall?.copyWith(
                            color: AppColors.gray700,
                            fontSize: 10,
                          ),
                        ),
                      )
                    ).toList(),
                  ),
                ],
                if (entry.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.note,
                    style: text.bodySmall?.copyWith(
                      color: AppColors.gray700,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double waveHeight = 20;
    final double waveLength = size.width / 2;

    path.moveTo(0, size.height * 0.7);

    for (double x = 0; x <= size.width; x++) {
      final double y = size.height * 0.7 +
          waveHeight *
              math.sin((x / waveLength + progress * 2 * math.pi) * math.pi);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
