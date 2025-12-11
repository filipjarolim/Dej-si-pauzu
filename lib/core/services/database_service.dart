import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:uuid/uuid.dart';
import 'app_service.dart';
import 'sync_service.dart';

/// MongoDB database service
class DatabaseService extends AppService {
  DatabaseService._();
  static final DatabaseService _instance = DatabaseService._();
  factory DatabaseService() => _instance;

  Db? _database;
  bool _isConnected = false;

  /// Get database instance
  Db? get database => _database;

  /// Check if connected
  bool get isConnected => _isConnected;


  @override
  Future<void> initialize() async {
    try {
      final String? uri = dotenv.env['MONGODB_URI'];
      final String dbName = dotenv.env['MONGODB_DATABASE_NAME'] ?? 'dejsipauzu';

      if (uri == null || uri.isEmpty) {
        debugPrint('Warning: MONGODB_URI is not set in .env file');
        _isConnected = false;
        return;
      }

      // Ensure database name is in the URI path
      // Format should be: mongodb+srv://user:pass@host/dbname?options
      String connectionUri = uri;
      
      // Find the position after @ (host starts here)
      final int atIndex = uri.indexOf('@');
      if (atIndex != -1) {
        final String afterAt = uri.substring(atIndex + 1);
        final int slashIndex = afterAt.indexOf('/');
        final int questionIndex = afterAt.indexOf('?');
        
        // Check if database name exists between / and ?
        bool hasDbName = false;
        if (slashIndex != -1) {
          if (questionIndex == -1) {
            // Has / but no ?, check if there's text after /
            hasDbName = afterAt.substring(slashIndex + 1).isNotEmpty;
          } else {
            // Has both / and ?, check if there's text between them
            hasDbName = slashIndex + 1 < questionIndex;
          }
        }
        
        if (!hasDbName) {
          // Insert database name
          if (questionIndex != -1) {
            // Insert before ?
            connectionUri = '${uri.substring(0, atIndex + 1 + slashIndex + 1)}$dbName${afterAt.substring(questionIndex)}';
          } else if (slashIndex != -1) {
            // Has / but no database name, append dbname
            connectionUri = '$uri$dbName';
          } else {
            // No / at all, add /dbname
            connectionUri = '$uri/$dbName';
          }
        }
      } else {
        // No @ found, try simple append
        if (!uri.contains('/$dbName') && !uri.endsWith('/')) {
          connectionUri = '$uri/$dbName';
        }
      }

      // Mask password in debug output
      final String maskedUri = connectionUri.replaceAll(RegExp(r':([^:@]+)@'), ':****@');
      debugPrint('Connecting to MongoDB: $maskedUri');
      
      try {
        _database = await Db.create(connectionUri);
        await _database!.open();
        _isConnected = true;

        // Test connection by getting collection names
        await _database!.getCollectionNames();
        debugPrint('MongoDB connected successfully');
      } catch (e) {
        // If mongodb+srv fails, try to provide helpful error message
        if (connectionUri.contains('mongodb+srv://')) {
          debugPrint('MongoDB connection error with mongodb+srv:// scheme: $e');
          debugPrint('Make sure your MongoDB Atlas cluster allows connections from your IP address');
          debugPrint('Also verify that the username and password are correct');
        }

        rethrow;
      }
    } catch (e) {
      _isConnected = false;
      debugPrint('MongoDB connection error: $e');
      // Don't rethrow - allow app to continue without database
    }
    
    // Initialize Sync Service
    await SyncService().initialize();
  }

  /// Get a collection
  DbCollection getCollection(String name) {
    if (_database == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database!.collection(name);
  }

  /// Insert a document (Offline-First)
  Future<void> insertOne(String collection, Map<String, dynamic> document) async {
    // 1. Add ID if missing
    if (!document.containsKey('_id')) {
      document['_id'] = const Uuid().v4();
    }

    // 2. Queue operation
    final op = SyncOperation(
      id: const Uuid().v4(),
      type: SyncOperationType.insert,
      collection: collection,
      data: document,
      timestamp: DateTime.now(),
    );
    
    await SyncService().addOperation(op);
    debugPrint('Queued insert for $collection');
    
    // 3. Return immediately (Optimistic)
    return;
  }

  /// Insert multiple documents
  Future<BulkWriteResult> insertMany(String collection, List<Map<String, dynamic>> documents) async {
    final DbCollection coll = getCollection(collection);
    return await coll.insertMany(documents);
  }

  /// Find documents
  Future<List<Map<String, dynamic>>> find(
    String collection, {
    Map<String, dynamic>? filter,
    Map<String, dynamic>? sort,
    int? limit,
    int? skip,
  }) async {
    final DbCollection coll = getCollection(collection);
    
    // Build query selector
    final Map<String, dynamic> query = filter ?? <String, dynamic>{};
    
    // Execute find query - find() returns a Stream
    Stream<Map<String, dynamic>> stream = coll.find(query);
    
    // Apply sort if provided
    if (sort != null && sort.isNotEmpty) {
      // Note: Sorting needs to be applied via cursor or query builder
      // For now, we'll collect all results and sort in memory if needed
      // In production, consider using aggregation pipeline for better performance
    }
    
    final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];
    int count = 0;
    await for (final Map<String, dynamic> doc in stream) {
      // Apply skip manually
      if (skip != null && count < skip) {
        count++;
        continue;
      }
      // Apply limit manually
      if (limit != null && results.length >= limit) {
        break;
      }
      results.add(doc);
      count++;
    }
    
    // Apply sort in memory if provided
    if (sort != null && sort.isNotEmpty) {
      results.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        for (final MapEntry<String, dynamic> entry in sort.entries) {
          final String key = entry.key;
          final int direction = entry.value == -1 ? -1 : 1;
          final dynamic aVal = a[key];
          final dynamic bVal = b[key];
          if (aVal == null && bVal == null) continue;
          if (aVal == null) return direction;
          if (bVal == null) return -direction;
          final int comparison = Comparable.compare(
            aVal.toString(),
            bVal.toString(),
          );
          if (comparison != 0) return comparison * direction;
        }
        return 0;
      });
    }
    
    return results;
  }

  /// Find one document
  Future<Map<String, dynamic>?> findOne(
    String collection, {
    Map<String, dynamic>? filter,
  }) async {
    final DbCollection coll = getCollection(collection);
    return await coll.findOne(filter ?? {});
  }

  /// Update one document (Offline-First)
  Future<void> updateOne(
    String collection,
    Map<String, dynamic> filter,
    Map<String, dynamic> update, {
    bool upsert = false,
  }) async {
      // Queue operation
      final op = SyncOperation(
        id: const Uuid().v4(),
        type: SyncOperationType.update,
        collection: collection,
        data: update,
        filter: filter,
        timestamp: DateTime.now(),
      );
      
      await SyncService().addOperation(op);
      debugPrint('Queued update for $collection');
  }

  /// Update many documents
  Future<WriteResult> updateMany(
    String collection,
    Map<String, dynamic> filter,
    Map<String, dynamic> update,
  ) async {
    final DbCollection coll = getCollection(collection);
    final ModifierBuilder modifier = ModifierBuilder();
    update.forEach((String key, dynamic value) {
      modifier.set(key, value);
    });
    return await coll.updateMany(
      filter,
      modifier,
    );
  }

  /// Delete one document
  Future<WriteResult> deleteOne(String collection, Map<String, dynamic> filter) async {
    final DbCollection coll = getCollection(collection);
    return await coll.deleteOne(filter);
  }

  /// Delete many documents
  Future<WriteResult> deleteMany(String collection, Map<String, dynamic> filter) async {
    final DbCollection coll = getCollection(collection);
    return await coll.deleteMany(filter);
  }

  /// Count documents
  Future<int> count(String collection, {Map<String, dynamic>? filter}) async {
    final DbCollection coll = getCollection(collection);
    return await coll.count(filter ?? {});
  }

  @override
  void dispose() {
    _database?.close();
    _database = null;
    _isConnected = false;
  }
}

