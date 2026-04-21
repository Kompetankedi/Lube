import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../services/local_db_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _isLocalMode = true;
  String? _dbPath;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final docs = await getApplicationDocumentsDirectory();
    setState(() {
      _urlController.text = prefs.getString('backend_url') ?? 'http://10.0.2.2:5050';
      _isLocalMode = prefs.getBool('is_local_mode') ?? true;
      _dbPath = p.join(docs.path, 'lube_local.db');
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backend_url', _urlController.text);
    await prefs.setBool('is_local_mode', _isLocalMode);
    
    final userId = prefs.getInt('user_id');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ayarlar kaydedildi!'), backgroundColor: Colors.green),
      );

      // Mod kontrolü ve yönlendirme
      if (_isLocalMode) {
        // Yerel modda giriş gerekmez, doğrudan Dashboard'a git
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      } else if (userId == null) {
        // Sunucu modunda oturum yoksa Login ekranına git
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        // Sunucu modunda oturum varsa sadece geri dön (Dashboard yenilenir)
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _exportDatabase() async {
    if (_dbPath == null) return;
    final file = File(_dbPath!);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veritabanı dosyası bulunamadı!'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final shareFile = File(p.join(tempDir.path, 'lube_backup_${DateTime.now().millisecondsSinceEpoch}.sqlite'));
      await file.copy(shareFile.path);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(shareFile.path)],
          subject: 'Lube Uygulaması Veritabanı Yedeği',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paylaşım hatası: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveDatabaseAsFile() async {
    if (_dbPath == null) return;
    final file = File(_dbPath!);
    if (!await file.exists()) return;

    try {
      // Updated for file_picker 11.0.0+
      String? selectedDirectory = await FilePicker.getDirectoryPath();

      if (selectedDirectory != null) {
        final fileName = 'lube_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.sqlite';
        final targetPath = p.join(selectedDirectory, fileName);
        
        final bytes = await file.readAsBytes();
        final targetFile = File(targetPath);
        await targetFile.writeAsBytes(bytes, flush: true);

        if (await targetFile.exists()) {
          final size = await targetFile.length();
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('YEDEK BAŞARILI', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
                backgroundColor: const Color(0xFF151921),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dosya başarıyla kaydedildi:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(fileName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 16),
                    const Text('KONUM:', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    Text(selectedDirectory, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    const SizedBox(height: 8),
                    Text('BOYUT: ${(size / 1024).toStringAsFixed(2)} KB', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('TAMAM'))
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt hatası: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _importDatabase() async {
    try {
      // Updated for file_picker 11.0.0+ (Removed .platform)
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);
        
        if (mounted) {
          bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('VERİLERİ İÇE AKTAR?', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFF151921),
              content: const Text(
                'Seçilen veritabanı dosyası mevcut verilerinizin üzerine yazılacaktır. Bu işlem geri alınamaz.\n\nDevam etmek istiyor musunuz?',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İPTAL')),
                TextButton(
                  onPressed: () => Navigator.pop(context, true), 
                  child: const Text('EVET, İÇE AKTAR', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                ),
              ],
            ),
          ) ?? false;

          if (!confirm) return;

          await LocalDbService.closeDatabase();

          if (_dbPath != null) {
            final bytes = await pickedFile.readAsBytes();
            final dbFile = File(_dbPath!);
            await dbFile.writeAsBytes(bytes, flush: true);

            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('BAŞARILI', style: TextStyle(color: Color(0xFF00FFD4), fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFF151921),
                  content: const Text('Veriler başarıyla içe aktarıldı. Değişikliklerin yansıması için uygulamanın yeniden başlatılması önerilir.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, true); 
                      }, 
                      child: const Text('TAMAM')
                    )
                  ],
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İçe aktarma hatası: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('AYARLAR'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('ÇALIŞMA MODU'),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('YEREL MOD (SQLITE)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('Sunucu olmadan telefonu kullanın', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    value: _isLocalMode,
                    activeThumbColor: theme.colorScheme.primary,
                    onChanged: (val) => setState(() => _isLocalMode = val),
                  ),
                  if (_isLocalMode) ...[
                    const Divider(height: 1, color: Colors.white10),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('VERİTABANI YÖNETİMİ:', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          
                          _buildActionTile(
                            context,
                            icon: Icons.ios_share_rounded,
                            title: 'YEDEĞİ PAYLAŞ / GÖNDER',
                            onTap: _exportDatabase,
                          ),
                          const SizedBox(height: 8),
                          _buildActionTile(
                            context,
                            icon: Icons.folder_copy_rounded,
                            title: 'KLASÖRE KOPYALA (EXPORT)',
                            onTap: _saveDatabaseAsFile,
                          ),
                          const SizedBox(height: 8),
                          _buildActionTile(
                            context,
                            icon: Icons.upload_file_rounded,
                            title: 'VERİLERİ İÇE AKTAR (IMPORT)',
                            onTap: _importDatabase,
                            color: Colors.orangeAccent,
                          ),

                          const SizedBox(height: 16),
                          const Text(
                            'NOT: "İçe Aktar" işlemi mevcut verilerinizin üzerine yazar. Lütfen geçerli bir Lube yedek dosyası seçtiğinizden emin olun.',
                            style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            if (!_isLocalMode) ...[
              _buildSectionTitle('SUNUCU BAĞLANTISI'),
              TextFormField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'SUNUCU ADRESİ (API URL)',
                  hintText: 'http://192.168.1.100:5050',
                  prefixIcon: Icon(Icons.lan_outlined),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sunucunuzun yerel IP adresini veya alan adını girin.',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],

            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('AYARLARI KAYDET'),
            ),
            const SizedBox(height: 20),
            if (!_isLocalMode)
              OutlinedButton(
                onPressed: () async {
                  await ApiService.logout();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent, 
                  side: const BorderSide(color: Colors.redAccent)
                ),
                child: const Text('OTURUMU KAPAT'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
