import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalDbService {
  static Database? _database;
  static const String _dbName = 'lube_local.db';

  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  static Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Maintenance Definitions
    await db.execute('''
      CREATE TABLE maintenance_definitions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        km_interval INTEGER,
        month_interval INTEGER,
        warning_note TEXT
      )
    ''');

    // Vehicles
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER,
        plate TEXT,
        current_km INTEGER DEFAULT 0,
        fuel_type TEXT,
        chassis_number TEXT,
        transmission_type TEXT
      )
    ''');

    // Maintenance Logs
    await db.execute('''
      CREATE TABLE maintenance_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        definition_id INTEGER NOT NULL,
        service_date TEXT NOT NULL,
        service_km INTEGER NOT NULL,
        price REAL,
        notes TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id) ON DELETE CASCADE,
        FOREIGN KEY (definition_id) REFERENCES maintenance_definitions (id)
      )
    ''');

    // Initial Definitions (Standard ones)
    final initialDefs = [
      ['Motor Yağı', 10000, 12, 'Yağ ve yağ filtresi değişimi'],
      ['Hava Filtresi', 10000, 12, null],
      ['Polen Filtresi', 10000, 12, null],
      ['Mazot Filtresi', 20000, 24, 'Dizel araçlar için'],
      ['Buji', 30000, 36, 'Benzinli araçlar için'],
      ['Fren Balatası', 20000, null, 'Ön balatalar'],
      ['Triger Kayışı', 90000, 60, 'Kritik bakım!'],
      ['Antifriz', 40000, 24, null],
      ['Şanzıman Yağı', 60000, 48, null],
    ];

    for (var def in initialDefs) {
      await db.insert('maintenance_definitions', {
        'name': def[0],
        'km_interval': def[1],
        'month_interval': def[2],
        'warning_note': def[3],
      });
    }
  }

  // --- CRUD Operations ---

  static Future<List<Map<String, dynamic>>> getVehicles() async {
    final db = await database;
    return await db.query('vehicles');
  }

  static Future<int> createVehicle(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('vehicles', data);
  }

  static Future<int> updateVehicle(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('vehicles', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteVehicle(int id) async {
    final db = await database;
    await db.delete('maintenance_logs', where: 'vehicle_id = ?', whereArgs: [id]);
    return await db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getDefinitions() async {
    final db = await database;
    return await db.query('maintenance_definitions');
  }

  static Future<int> createDefinition(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('maintenance_definitions', data);
  }

  static Future<List<Map<String, dynamic>>> getMaintenanceStatus(int vehicleId) async {
    final db = await database;
    
    final vehicleResult = await db.query('vehicles', columns: ['current_km'], where: 'id = ?', whereArgs: [vehicleId]);
    if (vehicleResult.isEmpty) return [];
    final currentKm = vehicleResult.first['current_km'] as int;

    // Optimized single query to get all definitions and their latest logs
    final results = await db.rawQuery('''
      SELECT 
        md.*, 
        ml.service_km as last_service_km, 
        ml.service_date as last_service_date,
        (SELECT COUNT(*) FROM maintenance_logs WHERE vehicle_id = ? AND definition_id = md.id) as total_logs
      FROM maintenance_definitions md
      LEFT JOIN maintenance_logs ml ON ml.id = (
        SELECT id FROM maintenance_logs 
        WHERE vehicle_id = ? AND definition_id = md.id 
        ORDER BY service_date DESC, id DESC 
        LIMIT 1
      )
    ''', [vehicleId, vehicleId]);
    
    List<Map<String, dynamic>> statusList = [];

    for (var row in results) {
      final Map<String, dynamic> status = Map<String, dynamic>.from(row);
      
      int? remainingKm = status['km_interval'] as int?;
      int? remainingDays;
      String statusNote = "Henüz bakım yapılmadı";
      String urgency = 'none';

      if (status['last_service_date'] != null) {
        final lastServiceKm = status['last_service_km'] as int;
        final kmSinceLastService = currentKm - lastServiceKm;
        
        if (remainingKm != null) {
          remainingKm = (status['km_interval'] as int) - kmSinceLastService;
        }

        final monthInterval = status['month_interval'] as int?;
        if (monthInterval != null) {
          final lastDate = DateTime.parse(status['last_service_date'] as String);
          final nextDate = DateTime(lastDate.year, lastDate.month + monthInterval, lastDate.day);
          final now = DateTime.now();
          remainingDays = nextDate.difference(now).inDays;
        }

        if ((remainingKm != null && remainingKm <= 0) || (remainingDays != null && remainingDays <= 0)) {
          urgency = 'critical';
          statusNote = 'Bakım zamanı geldi!';
        } else if ((remainingKm != null && remainingKm <= 1000) || (remainingDays != null && remainingDays <= 30)) {
          urgency = 'warning';
          statusNote = 'Yaklaşıyor!';
          if (remainingKm != null) statusNote += ' Kalan: $remainingKm KM';
        } else {
          urgency = 'ok';
          statusNote = 'Durum İyi';
          if (remainingKm != null) statusNote = 'Kalan: $remainingKm KM';
        }
      }

      statusList.add({
        ...status,
        'remaining_km': remainingKm,
        'remaining_days': remainingDays,
        'urgency': urgency,
        'status_note': statusNote,
      });
    }

    return statusList;
  }

  static Future<List<Map<String, dynamic>>> getVehicleLogs(int vehicleId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ml.*, md.name as definition_name, md.km_interval, md.month_interval
      FROM maintenance_logs ml
      JOIN maintenance_definitions md ON ml.definition_id = md.id
      WHERE ml.vehicle_id = ?
      ORDER BY ml.service_date DESC
    ''', [vehicleId]);
  }

  static Future<int> createLog(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('maintenance_logs', data);
  }

  static Future<int> updateLog(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('maintenance_logs', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteLog(int id) async {
    final db = await database;
    return await db.delete('maintenance_logs', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getAllLogs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ml.*, v.brand, v.model, v.plate, md.name as definition_name
      FROM maintenance_logs ml
      JOIN vehicles v ON ml.vehicle_id = v.id
      JOIN maintenance_definitions md ON ml.definition_id = md.id
      ORDER BY ml.service_date DESC
    ''');
  }
}
