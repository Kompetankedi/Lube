import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_maintenance_screen.dart';
import 'add_vehicle_screen.dart';
import 'package:intl/intl.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  List<dynamic> _maintenanceStatus = [];
  bool _isLoading = true;
  String? _errorMessage;
  late Map<String, dynamic> _currentVehicle;

  @override
  void initState() {
    super.initState();
    _currentVehicle = widget.vehicle;
    _fetchData();
  }

  Map<int, List<dynamic>> _groupedLogs = {};

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statusFuture = ApiService.getMaintenanceStatus(_currentVehicle['id']);
      final logsFuture = ApiService.getVehicleLogs(_currentVehicle['id']);
      
      final results = await Future.wait([statusFuture, logsFuture]);
      
      final status = results[0];
      final logs = results[1];
      
      // Group logs by definition_id once
      final Map<int, List<dynamic>> grouped = {};
      for (var log in logs) {
        final defId = log['definition_id'];
        if (!grouped.containsKey(defId)) {
          grouped[defId] = [];
        }
        grouped[defId]!.add(log);
      }

      if (mounted) {
        setState(() {
          _maintenanceStatus = status;
          _groupedLogs = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'HİÇ YAPILMADI';
    try {
      // Split "YYYY-MM-DD" to avoid timezone shifts
      final parts = dateStr.split('T')[0].split('-');
      if (parts.length == 3) {
        return "${parts[2]}.${parts[1]}.${parts[0]}";
      }
      // Fallback
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'critical': return Colors.redAccent;
      case 'warning': return Colors.orangeAccent;
      case 'ok': return const Color(0xFF00FFD4);
      default: return Colors.blueGrey;
    }
  }

  IconData _getUrgencyIcon(String urgency) {
    switch (urgency) {
      case 'critical': return Icons.report_problem_rounded;
      case 'warning': return Icons.access_time_filled_rounded;
      case 'ok': return Icons.check_circle_rounded;
      default: return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              '${_currentVehicle['brand']} ${_currentVehicle['model']}'.toUpperCase(), 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)
            ),
            Text(
              _currentVehicle['plate'] ?? '', 
              style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 2)
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddVehicleScreen(vehicle: _currentVehicle)),
              );
              if (!context.mounted) return;
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMaintenanceScreen(
                vehicleId: _currentVehicle['id'],
                currentKm: _currentVehicle['current_km'] ?? 0,
              ),
            ),
          );
          _fetchData();
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add_task_rounded, color: Colors.black),
      ),
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
            const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(
              _errorMessage!.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _fetchData,
              child: const Text('TEKRAR DENE'),
            )
          ],
        ),
      );
    }

    final sortedStatus = List.from(_maintenanceStatus)..sort((a, b) {
      const urgencyMap = {'critical': 0, 'warning': 1, 'ok': 2, 'none': 3};
      return (urgencyMap[a['urgency']] ?? 4).compareTo(urgencyMap[b['urgency']] ?? 4);
    });

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: sortedStatus.length,
        itemBuilder: (context, index) {
          final item = sortedStatus[index];
          final definitionId = item['id'];
          final urgency = item['urgency'] ?? 'none';
          final name = item['name'] ?? '';
          final statusNote = item['status_note'] ?? '';
          final kmInterval = item['km_interval'];
          
          // Get all logs for this specific definition from pre-grouped map
          final history = _groupedLogs[definitionId] ?? [];

          final urgencyColor = _getUrgencyColor(urgency);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: urgencyColor.withAlpha((0.2 * 255).toInt()), width: 1),
            ),
            child: ExpansionTile(
              leading: Icon(_getUrgencyIcon(urgency), color: urgencyColor, size: 28),
              title: Text(
                name.toUpperCase(), 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)
              ),
              subtitle: Text(
                statusNote.toUpperCase(),
                style: TextStyle(color: urgencyColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
              ),
              childrenPadding: const EdgeInsets.all(20).copyWith(top: 0),
              children: [
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('PERİYOT:', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    Text(kmInterval != null ? '$kmInterval KM' : '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'BAKIM GEÇMİŞİ',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('HİÇ KAYIT BULUNMUYOR', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  )
                else
                  ...history.map((log) => _buildHistoryItem(context, log)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, dynamic log) {
    String dateStr = _formatDate(log['service_date']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.2 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha((0.05 * 255).toInt())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              Text('${log['service_km']} KM', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          if (log['notes'] != null && log['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(log['notes'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (log['price'] != null)
                Text('${log['price']} ₺', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13))
              else
                const SizedBox(),
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMaintenanceScreen(
                        vehicleId: _currentVehicle['id'],
                        currentKm: _currentVehicle['current_km'] ?? 0,
                        log: log,
                      ),
                    ),
                  );
                  _fetchData();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
