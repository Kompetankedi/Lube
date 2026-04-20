import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<dynamic> _logs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final logs = await ApiService.getUserLogs();
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'BİLİNMİYOR';
    try {
      // Split "YYYY-MM-DD" to avoid timezone shifts
      final parts = dateStr.split('T')[0].split('-');
      if (parts.length == 3) {
        return "${parts[2]}.${parts[1]}.${parts[0]}";
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('BAKIM GEÇMİŞİ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLogs,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _errorMessage!.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _fetchLogs,
              child: const Text('TEKRAR DENE'),
            )
          ],
        ),
      );
    }

    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[800]),
            const SizedBox(height: 16),
            const Text(
              'HİÇ BAKIM GEÇMİŞİNİZ BULUNMUYOR.',
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchLogs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          String formattedDate = _formatDate(log['service_date']);
          final vehicleName = '${log['brand'] ?? ''} ${log['model'] ?? ''}';
          final plate = log['plate'] ?? '';

          return _buildLogItem(
            context,
            vehicle: vehicleName,
            plate: plate,
            date: formattedDate,
            title: log['definition_name'] ?? 'Bilinmeyen Bakım',
            km: '${log['service_km'] ?? 0} KM',
            price: log['price'] != null ? '${log['price']} ₺' : null,
            notes: log['notes'] ?? '',
          );
        },
      ),
    );
  }

  Widget _buildLogItem(
    BuildContext context, {
    required String vehicle,
    required String plate,
    required String date,
    required String title,
    required String km,
    String? price,
    required String notes,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(km, style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.primary, fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.directions_car, size: 12, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  vehicle.toUpperCase(),
                  style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
                ),
                const SizedBox(width: 8),
                Text(
                  '| $plate',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                notes,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
            if (price != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  price,
                  style: TextStyle(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
