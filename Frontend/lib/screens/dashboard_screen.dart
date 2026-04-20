import 'package:flutter/material.dart';
import 'add_vehicle_screen.dart';
import 'log_screen.dart';
import 'settings_screen.dart';
import '../services/api_service.dart';
import 'vehicle_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _vehicles = [];
  Map<int, List<dynamic>> _vehicleStatuses = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vehicles = await ApiService.getVehicles();
      
      // Fetch status for all vehicles in parallel
      final statusResults = await Future.wait(
        vehicles.map((v) => ApiService.getMaintenanceStatus(v['id']))
      );

      final Map<int, List<dynamic>> newStatuses = {};
      for (int i = 0; i < vehicles.length; i++) {
        newStatuses[vehicles[i]['id']] = statusResults[i];
      }

      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _vehicleStatuses = newStatuses;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'LUBE APP',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              if (result == true) {
                _fetchVehicles();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ARAÇLAR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.grey[500],
                  ),
                ),
                TextButton.icon(
                  onPressed: _fetchVehicles,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('GÜNCELLE'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehicleScreen()),
          );
          _fetchVehicles();
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.redAccent.withOpacity(0.5),
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _fetchVehicles,
              child: const Text('TEKRAR DENE'),
            ),
          ],
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Colors.grey[800],
            ),
            const SizedBox(height: 16),
            Text(
              'GARAJINIZ BOŞ',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hemen ilk aracınızı ekleyin',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchVehicles,
      child: ListView.builder(
        itemCount: _vehicles.length,
        padding: const EdgeInsets.only(bottom: 80),
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          final vehicleId = vehicle['id'];
          final status = _vehicleStatuses[vehicleId] ?? [];

          final criticalItems = status.where((s) => s['urgency'] == 'critical').toList();
          final warningItems = status.where((s) => s['urgency'] == 'warning').toList();

          return _buildVehicleCard(
            context,
            vehicle: vehicle,
            brand: vehicle['brand'] ?? '',
            model: vehicle['model'] ?? '',
            plate: vehicle['plate'] ?? '',
            km: vehicle['current_km']?.toString() ?? '0',
            criticalItems: criticalItems,
            warningItems: warningItems,
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context, {
    required Map<String, dynamic> vehicle,
    required String brand,
    required String model,
    required String plate,
    required String km,
    required List<dynamic> criticalItems,
    required List<dynamic> warningItems,
  }) {
    final theme = Theme.of(context);
    
    Color statusColor = theme.colorScheme.primary;
    String statusText = 'SORUN YOK';
    
    if (criticalItems.isNotEmpty) {
      statusColor = Colors.redAccent;
      statusText = '${criticalItems.length} ACİL BAKIM';
    } else if (warningItems.isNotEmpty) {
      statusColor = Colors.orangeAccent;
      statusText = '${warningItems.length} BAKIM YAKLAŞIYOR';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VehicleDetailScreen(vehicle: vehicle),
              ),
            ).then((_) => _fetchVehicles());
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            brand.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            model,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: Text(
                        plate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MEVCUT KM',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '$km KM',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            criticalItems.isNotEmpty
                                ? Icons.warning_rounded
                                : (warningItems.isNotEmpty
                                      ? Icons.info_rounded
                                      : Icons.check_circle_rounded),
                            color: statusColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (criticalItems.isNotEmpty || warningItems.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  ...criticalItems.take(2).map((item) => _buildMaintenanceTinyItem(item, Colors.redAccent)),
                  ...warningItems.take(2).map((item) => _buildMaintenanceTinyItem(item, Colors.orangeAccent)),
                  if (criticalItems.length + warningItems.length > 4)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '+ ${criticalItems.length + warningItems.length - 4} bakım daha...',
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceTinyItem(dynamic item, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.arrow_right, color: color, size: 16),
          Expanded(
            child: Text(
              item['name']?.toUpperCase() ?? '',
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            item['remaining_km'] <= 0 ? 'KM DOLDU!' : '${item['remaining_km']} KM KALDI',
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
