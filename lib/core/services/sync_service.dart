import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

enum SyncOperationType { insert, update, insertMany }

class SyncOperation {
  final String id;
  final SyncOperationType type;
  final String collection;
  final Map<String, dynamic> data;
  final Map<String, dynamic>? filter;
  final DateTime timestamp;

  SyncOperation({
    required this.id,
    required this.type,
    required this.collection,
    required this.data,
    this.filter,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'collection': collection,
    'data': data,
    'filter': filter,
    'timestamp': timestamp.toIso8601String(),
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'],
      type: SyncOperationType.values.firstWhere((e) => e.toString() == json['type']),
      collection: json['collection'],
      data: json['data'],
      filter: json['filter'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class SyncService {
  SyncService._();
  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;

  static const String _queueKey = 'offline_sync_queue';
  final DatabaseService _db = DatabaseService();
  final Connectivity _connectivity = Connectivity();
  
  List<SyncOperation> _queue = [];
  bool _isSyncing = false;
  StreamSubscription? _connectivitySubscription;

  /// Initialize: Load queue and listen to connectivity
  Future<void> initialize() async {
    await _loadQueue();
    
    // Listen for connectivity changes using Stream
    try {
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
        // Check if any result is not none (connected)
        bool isConnected = results.any((r) => r != ConnectivityResult.none);
        if (isConnected) {
          _processQueue();
        }
      });

      // Initial check
      final results = await _connectivity.checkConnectivity();
      if (results.any((r) => r != ConnectivityResult.none)) {
          _processQueue();
      }
    } catch (e) {
      debugPrint('SyncService: Connectivity check failed (likely hot restart). App requires full restart for new plugins. Error: $e');
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Add operation to queue (inserts/updates)
  Future<void> addOperation(SyncOperation op) async {
    _queue.add(op);
    await _saveQueue();
    
    // Try to sync immediately if online
    final results = await _connectivity.checkConnectivity();
    if (results.any((r) => r != ConnectivityResult.none)) {
      _processQueue();
    }
  }

  Future<void> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_queueKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _queue = jsonList.map((e) => SyncOperation.fromJson(e)).toList();
      } catch (e) {
        debugPrint('Error loading sync queue: $e');
      }
    }
  }

  Future<void> _saveQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(_queue.map((e) => e.toJson()).toList());
    await prefs.setString(_queueKey, jsonString);
  }

  Future<void> _processQueue() async {
    if (_isSyncing || _queue.isEmpty) return;
    
    if (!_db.isConnected) {
        // Try to reconnect if not connected
        await _db.initialize();
        if (!_db.isConnected) return;
    }

    _isSyncing = true;
    final List<SyncOperation> failedOps = [];

    debugPrint('Starting sync of ${_queue.length} operations...');

    for (final op in List<SyncOperation>.from(_queue)) {
      try {
        switch (op.type) {
          case SyncOperationType.insert:
            await _db.insertOne(op.collection, op.data);
            break;
          case SyncOperationType.insertMany:
            // Assuming data contains list in a special key or we restructure
            // For simplicity, handle generic data insert
            // (In real implementation, data structure matters)
             await _db.insertOne(op.collection, op.data); 
            break;
          case SyncOperationType.update:
             if (op.filter != null) {
                await _db.updateOne(op.collection, op.filter!, op.data, upsert: true);
             }
            break;
        }
      } catch (e) {
        debugPrint('Sync failed for op ${op.id}: $e');
        failedOps.add(op); // Keep it to retry later
      }
    }

    // Update queue to only contain failed ops
    _queue = failedOps;
    await _saveQueue();
    _isSyncing = false;
    
    debugPrint('Sync complete. Remaining: ${_queue.length}');
  }
}
