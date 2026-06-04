import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dholera_local.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE leads(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT,
        name TEXT,
        phone TEXT,
        source TEXT,
        status TEXT,
        createdAt TEXT,
        synced INTEGER DEFAULT 1
      )
    ''');
    
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        data TEXT,
        receivedAt TEXT
      )
    ''');
  }

  // --- Lead Operations ---

  Future<int> insertLead(Map<String, dynamic> lead) async {
    final db = await database;
    // Check if lead already exists by server_id or phone
    final List<Map<String, dynamic>> existing = await db.query(
      'leads',
      where: 'phone = ?',
      whereArgs: [lead['phone']],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'leads',
        lead,
        where: 'phone = ?',
        whereArgs: [lead['phone']],
      );
    }
    
    return await db.insert('leads', lead, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getLeads() async {
    final db = await database;
    return await db.query('leads', orderBy: 'createdAt DESC');
  }

  // --- Notification Operations ---

  Future<int> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;
    return await db.insert('notifications', notification);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query('notifications', orderBy: 'receivedAt DESC');
  }
}
