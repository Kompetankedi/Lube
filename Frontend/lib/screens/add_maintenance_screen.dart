import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddMaintenanceScreen extends StatefulWidget {
  final int vehicleId;
  final int currentKm;
  final Map<String, dynamic>? log;

  const AddMaintenanceScreen({
    super.key,
    required this.vehicleId,
    required this.currentKm,
    this.log,
  });

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();

  List<dynamic> _definitions = [];
  bool _isLoading = true;
  bool _isSaving = false;

  int? _selectedDefinitionId;
  String? _serviceKm;
  String? _price;
  String? _notes;
  DateTime _selectedDate = DateTime.now();

  // For custom definition
  bool _isCustomDefinition = false;
  String? _customDefName;
  String? _customDefKmInterval;
  String? _customDefMonthInterval;
  String? _customDefWarning;

  bool get _isEditing => widget.log != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _selectedDefinitionId = widget.log!['definition_id'];
      _serviceKm = widget.log!['service_km']?.toString();
      _price = widget.log!['price']?.toString();
      _notes = widget.log!['notes'];
      if (widget.log!['service_date'] != null) {
        try {
          _selectedDate = DateTime.parse(widget.log!['service_date']);
        } catch (e) {}
      }
    } else {
      _serviceKm = widget.currentKm.toString();
    }
    _fetchDefinitions();
  }

  Future<void> _fetchDefinitions() async {
    try {
      final defs = await ApiService.getMaintenanceDefinitions();
      setState(() {
        _definitions = defs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.black,
              surface: const Color(0xFF151921),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _deleteLog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151921),
        title: const Text('Bakım Kaydını Sil', style: TextStyle(color: Colors.white)),
        content: const Text('Bu bakım kaydını silmek istediğinize emin misiniz?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İPTAL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('SİL'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        await ApiService.deleteMaintenanceLog(widget.log!['id']);
        if (mounted) {
          Navigator.pop(context);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (!_isCustomDefinition && _selectedDefinitionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir bakım türü seçin veya yeni oluşturun.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      int defId;

      if (_isCustomDefinition) {
        defId = await ApiService.createMaintenanceDefinition({
          'name': _customDefName,
          'km_interval': _customDefKmInterval?.isNotEmpty == true ? int.tryParse(_customDefKmInterval!) : null,
          'month_interval': _customDefMonthInterval?.isNotEmpty == true ? int.tryParse(_customDefMonthInterval!) : null,
          'warning_note': _customDefWarning,
        });
      } else {
        defId = _selectedDefinitionId!;
      }

      final data = {
        'vehicle_id': widget.vehicleId,
        'definition_id': defId,
        'service_date': "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
        'service_km': int.tryParse(_serviceKm ?? '0') ?? 0,
        'price': _price != null && _price!.isNotEmpty ? double.tryParse(_price!) : null,
        'notes': _notes,
      };

      if (_isEditing) {
        await ApiService.updateMaintenanceLog(widget.log!['id'], data);
      } else {
        await ApiService.createMaintenanceLog(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Bakım güncellendi!' : 'Bakım başarıyla kaydedildi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'BAKIMI DÜZENLE' : 'YENİ BAKIM KAYDI'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _isSaving ? null : _deleteLog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isEditing) ...[
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                  ),
                  child: SwitchListTile(
                    title: const Text('ÖZEL BAKIM TÜRÜ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                    subtitle: const Text('Listede olmayan bir kalem ekleyin', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    value: _isCustomDefinition,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) => setState(() => _isCustomDefinition = val),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (!_isCustomDefinition)
                DropdownButtonFormField<int>(
                  dropdownColor: const Color(0xFF151921),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'BAKIM TÜRÜ SEÇİN',
                    prefixIcon: Icon(Icons.list_alt),
                  ),
                  value: _selectedDefinitionId,
                  items: _definitions.map<DropdownMenuItem<int>>((def) {
                    return DropdownMenuItem<int>(
                      value: def['id'],
                      child: Text(def['name']?.toUpperCase() ?? ''),
                    );
                  }).toList(),
                  onChanged: _isEditing ? null : (val) => setState(() => _selectedDefinitionId = val),
                  validator: (val) => !_isCustomDefinition && val == null ? 'Bakım türü seçin' : null,
                )
              else ...[
                _buildTextField(
                  label: 'BAKIM ADI',
                  icon: Icons.edit_note,
                  onSaved: (val) => _customDefName = val,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'PERİYOT (KM)',
                        icon: Icons.speed,
                        keyboardType: TextInputType.number,
                        onSaved: (val) => _customDefKmInterval = val,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: 'PERİYOT (AY)',
                        icon: Icons.calendar_month,
                        keyboardType: TextInputType.number,
                        onSaved: (val) => _customDefMonthInterval = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'ÖZEL NOT / UYARI',
                  icon: Icons.warning_amber_outlined,
                  onSaved: (val) => _customDefWarning = val,
                  isRequired: false,
                ),
              ],

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Divider(color: Colors.white10),
              ),

              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildTextField(
                      label: 'BAKIM KM',
                      icon: Icons.add_road,
                      initialValue: _serviceKm,
                      keyboardType: TextInputType.number,
                      onSaved: (val) => _serviceKm = val,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'TARİH',
                          prefixIcon: Icon(Icons.event),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        child: Text(
                          "${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}",
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'FİYAT (₺) (OPSİYONEL)',
                icon: Icons.payments_outlined,
                initialValue: _price,
                keyboardType: TextInputType.number,
                isRequired: false,
                onSaved: (val) => _price = val,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'NOTLARINIZ (OPSİYONEL)',
                icon: Icons.notes,
                initialValue: _notes,
                maxLines: 3,
                isRequired: false,
                onSaved: (val) => _notes = val,
              ),
              const SizedBox(height: 40),

              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _save,
                      child: Text(
                        _isEditing ? 'DEĞİŞİKLİKLERİ KAYDET' : 'BAKIMI KAYDET',
                      ),
                    ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required FormFieldSetter<String> onSaved,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11),
          prefixIcon: Icon(icon, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (val) {
          if (isRequired && (val == null || val.isEmpty)) {
            return 'Gerekli';
          }
          if (val != null && val.isNotEmpty) {
            if (label.contains('KM')) {
              final km = int.tryParse(val);
              if (km == null) return 'Geçersiz KM';
              if (km < 0) return 'KM negatif olamaz';
            }
            if (label.contains('FİYAT')) {
              final price = double.tryParse(val);
              if (price == null) return 'Geçersiz fiyat';
              if (price < 0) return 'Fiyat negatif olamaz';
            }
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }
}
