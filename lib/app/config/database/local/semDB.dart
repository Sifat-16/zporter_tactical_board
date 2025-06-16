import 'package:flutter/foundation.dart'
    show kIsWeb; // To check if running on web
// Import path packages needed only for IO platforms
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:sembast/sembast.dart';
// Import platform-specific factories
import 'package:sembast/sembast_io.dart' show databaseFactoryIo;
import 'package:sembast_web/sembast_web.dart' show databaseFactoryWeb;

/// Utility class for accessing the Sembast database using static members.
class SemDB {
  // Make constructor private to prevent instantiation
  SemDB._();

  // Static variable to hold the single database instance.
  static Database? _database;

  // Static constant for the database name.
  static const String _dbName = 'app_database.db';

  /// Returns the initialized Sembast database instance via a static getter.
  ///
  /// It initializes the database on the first call based on the platform.
  static Future<Database> get database async {
    // Use the static _database variable
    if (_database == null) {
      await _initDb();
    }
    // The _initDb method ensures _database is non-null upon successful completion.
    return _database!;
  }

  /// Static internal method to initialize the database based on the platform.
  static Future<void> _initDb() async {
    // Avoid re-initialization - check static variable
    if (_database != null) return;

    DatabaseFactory dbFactory;
    String dbPath;

    if (kIsWeb) {
      // --- WEB ---
      print("Platform: Web - Using Sembast Web Factory (IndexedDB)");
      dbFactory = databaseFactoryWeb;
      // Use the static _dbName
      dbPath = _dbName;
    } else {
      // --- MOBILE / DESKTOP (IO) ---
      print("Platform: IO - Using Sembast IO Factory (File System)");
      dbFactory = databaseFactoryIo;
      final appDocumentDir = await getApplicationDocumentsDirectory();
      // Use the static _dbName
      dbPath = join(appDocumentDir.path, _dbName);
    }

    print('Sembast: Initializing database at "$dbPath"');

    try {
      // Open the database and assign to the static _database variable
      _database = await dbFactory.openDatabase(dbPath);
      print('Sembast: Database initialized successfully.');
    } catch (e) {
      print('Sembast: Error opening database: $e');
      _database = null; // Ensure database isn't partially initialized on error
      rethrow; // Rethrow or handle as needed
    }
  }

  /// Static method to close the database connection if it's open.
  static Future<void> closeDb() async {
    // Access the static _database variable
    await _database?.close();
    _database = null; // Reset the static variable
    print('Sembast: Database closed.');
  }
}
