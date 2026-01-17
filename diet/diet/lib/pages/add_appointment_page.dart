import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/appointment_service.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final AppointmentService _apptService = AppointmentService();
  bool _isLoading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedType = 1;

  final Color primaryColor = const Color(0xFF382aae);
  final Color scaffoldBackground = const Color(0xFFF9FAFB);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveAppointment() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Lütfen danışan adı giriniz"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Tarih ve saati birleştirip UTC'ye çevir
    final startDateTime = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedTime.minute);

    try {
      await _apptService.createAppointment({
        "title": _titleController.text,
        "startDate": startDateTime.toUtc().toIso8601String(),
        "endDate": startDateTime
            .add(const Duration(hours: 1))
            .toUtc()
            .toIso8601String(),
        "notes": _notesController.text,
        "clientId": 6,
        "appointmentStatusId": 1,
        "appointmentTypeId": _selectedType
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Randevu başarıyla oluşturuldu!"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Hata: ${e.toString().replaceAll("Exception: ", "")}"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackground,
      appBar: AppBar(
        title: Text("Randevu Oluştur",
            style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontWeight: FontWeight.bold)),
        backgroundColor: scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Randevu Bilgileri",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Danışan Adı
            _buildInputLabel("Danışan Adı"),
            _buildTextField(
                _titleController, Icons.person_outline, "Örn: Ahmet Yılmaz"),

            const SizedBox(height: 20),

            // Randevu Tipi Dropdown
            _buildInputLabel("Randevu Tipi"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedType,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("Online Diyet")),
                    DropdownMenuItem(value: 2, child: Text("Yüz Yüze")),
                    DropdownMenuItem(value: 3, child: Text("Kontrol")),
                  ],
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tarih ve Saat Seçimi (Yan Yana)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("Tarih"),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: _buildSelectionContainer(
                          Icons.calendar_today_outlined,
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputLabel("Saat"),
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: _buildSelectionContainer(
                          Icons.access_time_outlined,
                          _selectedTime.format(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Notlar
            _buildInputLabel("Notlar"),
            _buildTextField(
                _notesController, Icons.note_alt_outlined, "Opsiyonel...",
                maxLines: 3),

            const SizedBox(height: 40),

            // Kaydet Butonu
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Randevuyu Kaydet",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(label,
          style: TextStyle(
              color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, IconData icon, String hint,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSelectionContainer(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor.withOpacity(0.7), size: 20),
          const SizedBox(width: 8),
          Text(text,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
