import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddVehicleScreen extends StatefulWidget {
  final Map<String, dynamic>? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _brand;
  String? _model;
  String? _year;
  String? _plate;
  String? _chassisNumber;
  String? _fuelType;
  String? _transmissionType;
  String? _currentKm;
  bool _isSaving = false;

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _brand = widget.vehicle!['brand'];
      _model = widget.vehicle!['model'];
      _year = widget.vehicle!['year']?.toString();
      _plate = widget.vehicle!['plate'];
      _chassisNumber = widget.vehicle!['chassis_number'];
      _fuelType = widget.vehicle!['fuel_type'];
      _transmissionType = widget.vehicle!['transmission_type'];
      _currentKm = widget.vehicle!['current_km']?.toString();
    } else {
      _fuelType = 'Benzin';
      _transmissionType = 'Manuel';
    }
  }

  Future<void> _checkMaintenanceAlerts(int vehicleId) async {
    try {
      final status = await ApiService.getMaintenanceStatus(vehicleId);
      final criticalItems = status.where((s) => s['urgency'] == 'critical').toList();
      
      if (criticalItems.isNotEmpty && mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF151921),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                const SizedBox(width: 10),
                const Text('BAKIM UYARISI', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Girdiğiniz yeni kilometre bilgisine göre aşağıdaki bakımların süresi geçmiştir:', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ...criticalItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right, color: Color(0xFF00E5FF), size: 20),
                      Text(item['name']?.toUpperCase() ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('TAMAM', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold)),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking alerts: $e');
    }
  }

  Future<void> _deleteVehicle() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aracı Sil'),
        content: const Text('Bu aracı ve tüm bakım geçmişini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        await ApiService.deleteVehicle(widget.vehicle!['id']);
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_isEditing ? 'ARACI DÜZENLE' : 'YENİ ARAÇ EKLE'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _isSaving ? null : _deleteVehicle,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('TEMEL BİLGİLER'),
              _buildTextField(
                label: 'MARKA',
                initialValue: _brand,
                onSaved: (v) => _brand = v,
                icon: Icons.branding_watermark_outlined,
              ),
              _buildTextField(
                label: 'MODEL',
                initialValue: _model,
                onSaved: (v) => _model = v,
                icon: Icons.directions_car_outlined,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'YIL',
                      initialValue: _year,
                      keyboardType: TextInputType.number,
                      onSaved: (v) => _year = v,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      label: 'PLAKA',
                      initialValue: _plate,
                      onSaved: (v) => _plate = v?.toUpperCase(),
                      icon: Icons.featured_play_list_outlined,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                label: 'GÜNCEL KİLOMETRE',
                initialValue: _currentKm,
                keyboardType: TextInputType.number,
                onSaved: (v) => _currentKm = v,
                icon: Icons.speed_outlined,
              ),
              
              const SizedBox(height: 12),
              _buildSectionTitle('TEKNİK DETAYLAR'),
              _buildTextField(
                label: 'ŞASE NUMARASI (OPSİYONEL)',
                initialValue: _chassisNumber,
                onSaved: (v) => _chassisNumber = v,
                isRequired: false,
                icon: Icons.fingerprint_outlined,
              ),
              
              const SizedBox(height: 4),
              _buildDropdown(
                label: 'MOTOR TİPİ',
                value: _fuelType,
                items: ['Benzin', 'Dizel', 'LPG', 'Elektrik', 'Hibrit'],
                onChanged: (v) => setState(() => _fuelType = v),
                icon: Icons.local_gas_station_outlined,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'ŞANZIMAN TİPİ',
                value: _transmissionType,
                items: ['Manuel', 'Otomatik', 'Yarı Otomatik', 'DSG', 'CVT'],
                onChanged: (v) => setState(() => _transmissionType = v),
                icon: Icons.settings_input_component_outlined,
              ),

              const SizedBox(height: 40),
              _isSaving 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        
                        setState(() => _isSaving = true);
                        try {
                          final data = {
                            'brand': _brand,
                            'model': _model,
                            'year': int.tryParse(_year ?? '0'),
                            'plate': _plate,
                            'current_km': int.tryParse(_currentKm ?? '0'),
                            'fuel_type': _fuelType,
                            'chassis_number': _chassisNumber,
                            'transmission_type': _transmissionType,
                          };

                          int? vehicleId;
                          if (_isEditing) {
                            vehicleId = widget.vehicle!['id'];
                            await ApiService.updateVehicle(vehicleId!, data);
                          } else {
                            await ApiService.createVehicle(data);
                          }
                          
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isEditing ? 'Araç güncellendi!' : 'Araç başarıyla eklendi!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          
                          if (_isEditing) {
                            await _checkMaintenanceAlerts(vehicleId!);
                          }
                          
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        } catch (e) {
                          setState(() => _isSaving = false);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    child: Text(
                      _isEditing ? 'DEĞİŞİKLİKLERİ KAYDET' : 'ARACI KAYDET',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    bool isRequired = true,
    required IconData icon,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Bu alan zorunludur';
          }
          if (value != null && value.isNotEmpty) {
            if (label == 'YIL') {
              final year = int.tryParse(value);
              if (year == null) return 'Geçerli bir yıl girin';
              if (year < 1900 || year > DateTime.now().year + 1) return 'Geçersiz yıl';
            }
            if (label == 'GÜNCEL KİLOMETRE') {
              final km = int.tryParse(value);
              if (km == null) return 'Geçerli bir rakam girin';
              if (km < 0) return 'KM negatif olamaz';
              
              if (_isEditing && widget.vehicle!['current_km'] != null) {
                final oldKm = widget.vehicle!['current_km'] as int;
                if (km < oldKm) {
                  return 'KM düşürülemez (Mevcut: $oldKm)';
                }
              }
            }
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      dropdownColor: const Color(0xFF151921),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}
