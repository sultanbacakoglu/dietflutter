import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diet_model.dart';
import '../services/diet_service.dart';
import 'add_diet_page.dart';

class DietListPage extends StatefulWidget {
  const DietListPage({super.key});

  @override
  State<DietListPage> createState() => _DietListPageState();
}

class _DietListPageState extends State<DietListPage> {
  final DietService _dietService = DietService();
  late Future<List<DietModel>> _dietListFuture;

  // Tasarım için canlı renk paleti
  final List<Color> _cardColors = [
    const Color(0xFF6366F1), // İndigo
    const Color(0xFFEC4899), // Pembe
    const Color(0xFF10B981), // Yeşil
    const Color(0xFFF59E0B), // Turuncu
    const Color(0xFF3B82F6), // Mavi
    const Color(0xFF8B5CF6), // Mor
    const Color(0xFFEF4444), // Kırmızı
  ];

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _dietListFuture = _dietService.getDietLists();
    });
  }

  void _showDetailDialog(int id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      DietModel fullDiet = await _dietService.getDietListById(id);
      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.restaurant_menu, color: Color(0xFF382aae)),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(fullDiet.title,
                      style: const TextStyle(fontSize: 18))),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Danışan: ${fullDiet.clientName ?? 'Bilinmiyor'}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (fullDiet.description.isNotEmpty) ...[
                    Text("Notlar:",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    Text(fullDiet.description),
                    const SizedBox(height: 15),
                  ],
                  const Divider(),
                  const Text("Diyet Programı",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  ...fullDiet.details
                      .map((d) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              dense: true,
                              title: Text("${d.day} - ${d.meal}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF382aae))),
                              subtitle: Text(d.content,
                                  style:
                                      const TextStyle(color: Colors.black87)),
                              leading: const Icon(Icons.circle,
                                  size: 10, color: Color(0xFF382aae)),
                            ),
                          ))
                      .toList()
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Kapat", style: TextStyle(color: Colors.grey)))
          ],
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Detaylar yüklenemedi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Diyet Listeleri",
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddDietPage()));
          if (res == true) _refreshList();
        },
        backgroundColor: const Color(0xFF382aae),
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<DietModel>>(
        future: _dietListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text("Henüz diyet listesi yok.",
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final diet = snapshot.data![index];

              final Color itemColor = _cardColors[index % _cardColors.length];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: itemColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant_menu_rounded,
                      color: itemColor,
                    ),
                  ),
                  title: Text(
                    diet.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            diet.clientName ?? 'İsimsiz',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade200)),
                          child: Text(
                            DateFormat('dd MMM', 'tr_TR')
                                .format(DateTime.parse(diet.startDate)),
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.grey),
                      onPressed: () => _showDetailDialog(diet.id!),
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
