import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/client_model.dart';
import '../models/diet_model.dart';
import '../services/client_service.dart';
import '../services/diet_service.dart';

class AddDietPage extends StatefulWidget {
  const AddDietPage({super.key});

  @override
  State<AddDietPage> createState() => _AddDietPageState();
}

class _AddDietPageState extends State<AddDietPage> {
  final _formKey = GlobalKey<FormState>();
  final ClientService _clientService = ClientService();
  final DietService _dietService = DietService();

  List<ClientModel> _clients = [];
  int? _selectedClientId;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  List<DietDetail> _rows = [
    DietDetail(day: 'Pazartesi', meal: 'Kahvaltı', content: '')
  ];

  final List<String> _mealTypes = [
    "Kahvaltı",
    "Kuşluk",
    "Öğle",
    "İkindi",
    "Akşam",
    "Gece Ara Öğünü"
  ];

  bool _isLoading = false;
  final Color primaryColor = const Color(0xFF382aae);
  final Color accentColor = const Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  void _loadClients() async {
    try {
      var clients = await _clientService.getClients();
      setState(() => _clients = clients);
    } catch (e) {
      print("Hata: $e");
    }
  }

  void _addRow() {
    setState(() {
      String lastDay = _rows.isNotEmpty ? _rows.last.day : 'Pazartesi';
      _rows.add(DietDetail(day: lastDay, meal: 'Öğle', content: ''));
    });
  }

  void _removeRow(int index) {
    setState(() => _rows.removeAt(index));
  }

  Future<void> _saveDiet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lütfen danışan seçiniz")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      DietModel newDiet = DietModel(
        clientId: _selectedClientId!,
        title: _titleController.text,
        description: _descController.text,
        startDate: _startDate.toIso8601String(),
        endDate: _endDate.toIso8601String(),
        details: _rows,
      );

      await _dietService.createDietList(newDiet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Diyet listesi başarıyla kaydedildi!"),
            backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Yeni Diyet Listesi",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Genel Bilgiler", Icons.assignment_outlined),

              // Danışan Seçimi
              _buildInputLabel("Danışan"),
              DropdownButtonFormField<int>(
                value: _selectedClientId,
                items: _clients
                    .map((c) => DropdownMenuItem(
                        value: c.clientId,
                        child: Text(c.fullName ?? 'İsimsiz')))
                    .toList(),
                onChanged: (val) => setState(() => _selectedClientId = val),
                decoration:
                    _inputDecoration("Danışan seçiniz", Icons.person_outline),
              ),
              const SizedBox(height: 16),

              // Başlık
              _buildInputLabel("Liste Başlığı"),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(
                    "Örn: 1. Hafta Detoks Listesi", Icons.title_outlined),
                validator: (v) => v!.isEmpty ? "Başlık gerekli" : null,
              ),
              const SizedBox(height: 16),

              // Tarihler
              Row(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("Başlangıç"),
                      _datePicker(
                          _startDate, (d) => setState(() => _startDate = d)),
                    ],
                  )),
                  const SizedBox(width: 15),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("Bitiş"),
                      _datePicker(
                          _endDate, (d) => setState(() => _endDate = d)),
                    ],
                  )),
                ],
              ),
              const SizedBox(height: 30),

              // ÖĞÜN PLANI BÖLÜMÜ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader("Öğün Planı", Icons.restaurant_menu),
                  TextButton.icon(
                    onPressed: _addRow,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text("Satır Ekle",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                  )
                ],
              ),
              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  return _buildMealRow(index);
                },
              ),

              const SizedBox(height: 30),

              // KAYDET BUTONU
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDiet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Listeyi Kaydet",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: primaryColor),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(label,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: primaryColor.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1.5)),
    );
  }

  Widget _datePicker(DateTime date, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                  data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(primary: primaryColor)),
                  child: child!);
            });
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd/MM/yyyy').format(date),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Icon(Icons.calendar_today_outlined,
                size: 16, color: primaryColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _rows[index].day,
                  decoration: const InputDecoration(
                      labelText: "Gün", border: UnderlineInputBorder()),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  onChanged: (val) => _rows[index].day = val,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _mealTypes.contains(_rows[index].meal)
                      ? _rows[index].meal
                      : _mealTypes[0],
                  items: _mealTypes
                      .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) => setState(() => _rows[index].meal = val!),
                  decoration: const InputDecoration(
                      labelText: "Öğün", border: UnderlineInputBorder()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.redAccent, size: 22),
                onPressed: () => _removeRow(index),
              )
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: _rows[index].content,
            decoration: InputDecoration(
              hintText: "Örn: 2 adet yumurta, 1 dilim tam buğday ekmeği...",
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.notes, size: 18),
            ),
            onChanged: (val) => _rows[index].content = val,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
