import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_service.dart';

/// Statistics model
class Statistics {
  final int streakDays;
  final int totalBreathingMinutes;
  final DateTime? lastActivityDate;
  final List<DateTime> activityDates;

  Statistics({
    this.streakDays = 0,
    this.totalBreathingMinutes = 0,
    this.lastActivityDate,
    List<DateTime>? activityDates,
  }) : activityDates = activityDates ?? <DateTime>[];

  Map<String, dynamic> toMap() {
    return {
      'streakDays': streakDays,
      'totalBreathingMinutes': totalBreathingMinutes,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
      'activityDates': activityDates.map((DateTime d) => d.toIso8601String()).toList(),
    };
  }

  factory Statistics.fromMap(Map<String, dynamic> map) {
    return Statistics(
      streakDays: map['streakDays'] as int? ?? 0,
      totalBreathingMinutes: map['totalBreathingMinutes'] as int? ?? 0,
      lastActivityDate: map['lastActivityDate'] != null
          ? DateTime.parse(map['lastActivityDate'] as String)
          : null,
      activityDates: (map['activityDates'] as List<dynamic>?)
              ?.map((dynamic d) => DateTime.parse(d as String))
              .toList() ??
          <DateTime>[],
    );
  }
}

/// Statistics service for tracking user progress
class StatisticsService extends AppService {
  static final StatisticsService _instance = StatisticsService._();
  factory StatisticsService() => _instance;
  
  StatisticsService._();

  Statistics? _cachedStats;
  bool _isInitialized = false;

  /// Get current statistics
  Future<Statistics> getStatistics() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_cachedStats != null) {
      return _cachedStats!;
    }

    return await _loadStatistics();
  }

  /// Initialize service
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _cachedStats = await _loadStatistics();
      _isInitialized = true;
    } catch (e) {
      debugPrint('StatisticsService initialization error: $e');
      _isInitialized = true; // Continue even if loading fails
    }
  }

  /// Record a breathing session completion
  /// [minutes] - duration of the session in minutes
  Future<void> recordBreathingSession(int minutes) async {
    try {
      final Statistics stats = await getStatistics();
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      // Update total minutes
      final int newTotalMinutes = stats.totalBreathingMinutes + minutes;

      // Update streak
      int newStreak = stats.streakDays;
      final DateTime? lastDate = stats.lastActivityDate;
      
      if (lastDate != null) {
        final DateTime lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final DateTime yesterday = DateTime(today.year, today.month, today.day - 1);

        if (lastDay.isAtSameMomentAs(today)) {
          // Same day, don't update streak
        } else if (lastDay.isAtSameMomentAs(yesterday)) {
          // Consecutive day, increment streak
          newStreak++;
        } else {
          // Streak broken, reset to 1
          newStreak = 1;
        }
      } else {
        // First activity
        newStreak = 1;
      }

      // Update activity dates
      final List<DateTime> updatedDates = List<DateTime>.from(stats.activityDates);
      if (!updatedDates.any((DateTime d) =>
          d.year == today.year && d.month == today.month && d.day == today.day)) {
        updatedDates.add(today);
      }

      // Create updated statistics
      final Statistics updatedStats = Statistics(
        streakDays: newStreak,
        totalBreathingMinutes: newTotalMinutes,
        lastActivityDate: now,
        activityDates: updatedDates,
      );

      // Save to storage
      await _saveStatistics(updatedStats);
      _cachedStats = updatedStats;
    } catch (e) {
      debugPrint('Error recording breathing session: $e');
    }
  }

  /// Get formatted streak text
  Future<String> getStreakText() async {
    final Statistics stats = await getStatistics();
    if (stats.streakDays == 0) {
      return 'Začni svou cestu';
    } else if (stats.streakDays == 1) {
      return '1 den v řadě';
    } else if (stats.streakDays < 5) {
      return '${stats.streakDays} dny v řadě';
    } else {
      return '${stats.streakDays} dní v řadě';
    }
  }

  /// Get formatted total time text
  Future<String> getTotalTimeText() async {
    final Statistics stats = await getStatistics();
    if (stats.totalBreathingMinutes == 0) {
      return '0 min';
    } else if (stats.totalBreathingMinutes < 60) {
      return '${stats.totalBreathingMinutes} min';
    } else {
      final int hours = stats.totalBreathingMinutes ~/ 60;
      final int minutes = stats.totalBreathingMinutes % 60;
      if (minutes == 0) {
        return '$hours ${hours == 1 ? 'hodina' : hours < 5 ? 'hodiny' : 'hodin'}';
      } else {
        return '$hours h $minutes min';
      }
    }
  }

  /// Load statistics from storage
  Future<Statistics> _loadStatistics() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      final int streakDays = prefs.getInt('stats_streak_days') ?? 0;
      final int totalMinutes = prefs.getInt('stats_total_minutes') ?? 0;
      final String? lastDateStr = prefs.getString('stats_last_date');
      final List<String>? datesStr = prefs.getStringList('stats_activity_dates');

      final DateTime? lastDate = lastDateStr != null ? DateTime.parse(lastDateStr) : null;
      final List<DateTime> dates = datesStr != null
          ? datesStr.map((String d) => DateTime.parse(d)).toList()
          : <DateTime>[];

      return Statistics(
        streakDays: streakDays,
        totalBreathingMinutes: totalMinutes,
        lastActivityDate: lastDate,
        activityDates: dates,
      );
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      return Statistics();
    }
  }

  /// Save statistics to storage
  Future<void> _saveStatistics(Statistics stats) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('stats_streak_days', stats.streakDays);
      await prefs.setInt('stats_total_minutes', stats.totalBreathingMinutes);
      
      if (stats.lastActivityDate != null) {
        await prefs.setString('stats_last_date', stats.lastActivityDate!.toIso8601String());
      }
      
      final List<String> datesStr = stats.activityDates
          .map((DateTime d) => d.toIso8601String())
          .toList();
      await prefs.setStringList('stats_activity_dates', datesStr);
    } catch (e) {
      debugPrint('Error saving statistics: $e');
    }
  }

  /// Reset statistics (for testing/debugging)
  Future<void> reset() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('stats_streak_days');
      await prefs.remove('stats_total_minutes');
      await prefs.remove('stats_last_date');
      await prefs.remove('stats_activity_dates');
      _cachedStats = Statistics();
    } catch (e) {
      debugPrint('Error resetting statistics: $e');
    }
  }
}

