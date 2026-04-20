import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'local_db_service.dart';

class ApiService {
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('backend_url') ?? 'http://10.0.2.2:5050'; 
  }

  static Future<bool> isLocalMode() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true (SQLite Mode) as requested by the user
    return prefs.getBool('is_local_mode') ?? true;
  }

  static Future<int?> getUserId() async {
    if (await isLocalMode()) return 0; // Default local user ID
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', data['user']['id']);
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setString('user_name', data['user']['name']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Giriş yapılamadı. ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: Sunucuya ulaşılamadı. Ayarları kontrol edin.\nDetay: $e');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final baseUrl = await getBaseUrl();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['error'] ?? 'Kayıt olunamadı. ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: Sunucuya ulaşılamadı. Ayarları kontrol edin.\nDetay: $e');
    }
  }

  static Future<List<dynamic>> getVehicles() async {
    if (await isLocalMode()) {
      return await LocalDbService.getVehicles();
    }

    final baseUrl = await getBaseUrl();
    final userId = await getUserId();
    
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı.');

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/vehicles?user_id=$userId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: Lütfen Ayarlardan Sunucu IP adresini kontrol edin.\nDetay: $e');
    }
  }

  static Future<void> createVehicle(Map<String, dynamic> vehicleData) async {
    if (await isLocalMode()) {
      await LocalDbService.createVehicle(vehicleData);
      return;
    }

    final baseUrl = await getBaseUrl();
    final userId = await getUserId();
    
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı.');
    
    vehicleData['user_id'] = userId;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/vehicles'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vehicleData),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Araç Eklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: Sunucuya ulaşılamadı.');
    }
  }

  static Future<void> updateVehicle(int vehicleId, Map<String, dynamic> vehicleData) async {
    if (await isLocalMode()) {
      await LocalDbService.updateVehicle(vehicleId, vehicleData);
      return;
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/vehicles/$vehicleId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vehicleData),
      );
      if (response.statusCode != 200) {
        throw Exception('Araç güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  static Future<void> deleteVehicle(int vehicleId) async {
    if (await isLocalMode()) {
      await LocalDbService.deleteVehicle(vehicleId);
      return;
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/vehicles/$vehicleId'));
      if (response.statusCode != 200) {
        throw Exception('Araç silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  static Future<void> updateVehicleKm(int vehicleId, int currentKm) async {
    if (await isLocalMode()) {
      await LocalDbService.updateVehicle(vehicleId, {'current_km': currentKm});
      return;
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/vehicles/$vehicleId/km'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'current_km': currentKm}),
      );
      if (response.statusCode != 200) {
        throw Exception('KM güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  static Future<List<dynamic>> getUserLogs() async {
    if (await isLocalMode()) {
      return await LocalDbService.getAllLogs();
    }

    final baseUrl = await getBaseUrl();
    final userId = await getUserId();
    
    if (userId == null) throw Exception('Kullanıcı oturumu bulunamadı.');

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/maintenance/user-logs/$userId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: Lütfen Ayarlardan Sunucu IP adresini kontrol edin.\nDetay: $e');
    }
  }

  static Future<List<dynamic>> getMaintenanceStatus(int vehicleId) async {
    if (await isLocalMode()) {
      return await LocalDbService.getMaintenanceStatus(vehicleId);
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/maintenance/status/$vehicleId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  static Future<List<dynamic>> getVehicleLogs(int vehicleId) async {
    if (await isLocalMode()) {
      return await LocalDbService.getVehicleLogs(vehicleId);
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/maintenance/logs/$vehicleId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  static Future<void> createMaintenanceLog(Map<String, dynamic> logData) async {
    if (await isLocalMode()) {
      await LocalDbService.createLog(logData);
      return;
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/maintenance/logs'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(logData),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Bakım kaydı oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  static Future<void> updateMaintenanceLog(int logId, Map<String, dynamic> logData) async {
    if (await isLocalMode()) {
      await LocalDbService.updateLog(logId, logData);
      return;
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/maintenance/logs/$logId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(logData),
      );
      if (response.statusCode != 200) {
        throw Exception('Bakım kaydı güncellenemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  static Future<void> deleteMaintenanceLog(int logId) async {
    if (await isLocalMode()) {
      await LocalDbService.deleteLog(logId);
      return;
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/maintenance/logs/$logId'));
      if (response.statusCode != 200) {
        throw Exception('Bakım kaydı silinemedi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  static Future<List<dynamic>> getMaintenanceDefinitions() async {
    if (await isLocalMode()) {
      return await LocalDbService.getDefinitions();
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/maintenance/definitions'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }

  static Future<int> createMaintenanceDefinition(Map<String, dynamic> defData) async {
    if (await isLocalMode()) {
      return await LocalDbService.createDefinition(defData);
    }

    final baseUrl = await getBaseUrl();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/maintenance/definitions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(defData),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['id'];
      } else {
        throw Exception('Tanım oluşturulamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Bağlantı Hatası: $e');
    }
  }
}
