import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/party.dart';
import '../models/transaction_model.dart';

class DBHelper {
  static const _dbName = 'khatabook.db';
  static const _dbVersion = 1;

  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE parties (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            partyId INTEGER NOT NULL,
            amount REAL NOT NULL,
            type TEXT NOT NULL CHECK(type IN ('gave','got')),
            date TEXT NOT NULL,
            note TEXT NOT NULL,
            FOREIGN KEY(partyId) REFERENCES parties(id) ON DELETE CASCADE
          );
        ''');
      },
    );
  }

  static Future<int> insertParty(Party party) async {
    final db = await database;
    return await db.insert('parties', party.toMap());
  }

  static Future<List<Party>> getAllParties() async {
    final db = await database;
    // Get all parties with their latest transaction date
    final res = await db.rawQuery('''
      SELECT p.*, MAX(t.date) as lastTransactionDate
      FROM parties p
      LEFT JOIN transactions t ON p.id = t.partyId
      GROUP BY p.id
      ORDER BY lastTransactionDate DESC NULLS LAST, p.name COLLATE NOCASE
    ''');
    return res.map((e) => Party.fromMap(e)).toList();
  }

  static Future<int> updateParty(Party party) async {
    final db = await database;
    if (party.id == null) return 0;
    return await db.update(
      'parties',
      party.toMap(),
      where: 'id = ?',
      whereArgs: [party.id],
    );
  }

  static Future<int> insertTransaction(TransactionModel txn) async {
    final db = await database;
    return await db.insert('transactions', txn.toMap());
  }

  static Future<int> updateTransaction(TransactionModel txn) async {
    final db = await database;
    if (txn.id == null) return 0;
    return await db.update(
      'transactions',
      txn.toMap(),
      where: 'id = ?',
      whereArgs: [txn.id],
    );
  }

  static Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<TransactionModel>> getTransactionsByPartyId(
      int partyId) async {
    final db = await database;
    final res = await db.query(
      'transactions',
      where: 'partyId = ?',
      whereArgs: [partyId],
      orderBy: 'date DESC',
    );
    return res.map((e) => TransactionModel.fromMap(e)).toList();
  }

  static Future<double> getPartyBalance(int partyId) async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'got' THEN amount ELSE 0 END) -
        SUM(CASE WHEN type = 'gave' THEN amount ELSE 0 END) as balance
      FROM transactions
      WHERE partyId = ?
    ''', [partyId]);
    final value = res.first['balance'] as num?;
    return (value ?? 0).toDouble();
  }

  static Future<int> deleteParty(int partyId) async {
    final db = await database;
    // ON DELETE CASCADE on transactions table will remove related rows
    return await db.delete('parties', where: 'id = ?', whereArgs: [partyId]);
  }
}
