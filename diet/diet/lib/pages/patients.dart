import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../services/client_service.dart';
import '../components/client_card.dart';
import 'add_client_page.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final ClientService _clientService = ClientService();
  late Future<List<ClientModel>> _clientsFuture;

  List<ClientModel> _allClients = [];
  List<ClientModel> _filteredClients = [];
  final TextEditingController _searchController = TextEditingController();

  final Color primaryColor = const Color(0xFF382aae);
  final Color scaffoldBackground = const Color(0xFFF9FAFB);

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  void _loadClients() {
    setState(() {
      _clientsFuture = _clientService.getClients().then((value) {
        _allClients = value;
        _filteredClients = value;
        return value;
      });
    });
  }

  void _filterClients(String query) {
    final filtered = _allClients.where((client) {
      final fullName = client.fullName?.toLowerCase() ?? '';
      final input = query.toLowerCase();
      return fullName.contains(input);
    }).toList();

    setState(() {
      _filteredClients = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClientPage()),
          );
          if (result == true) {
            _loadClients();
          }
        },
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: scaffoldBackground,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "Danışanlar",
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontWeight: FontWeight.w800,
              fontSize: 26,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterClients,
                decoration: InputDecoration(
                  hintText: 'Danışan ara...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: primaryColor.withOpacity(0.7)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Colors.grey, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            _filterClients('');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // --- LİSTE ---
          Expanded(
            child: FutureBuilder<List<ClientModel>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: primaryColor));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text("Bağlantı hatası oluştu",
                            style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }

                if (_filteredClients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined,
                            size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          _searchController.text.isEmpty
                              ? "Henüz danışan eklemediniz."
                              : "Aranan kriterde danışan bulunamadı.",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 100),
                  itemCount: _filteredClients.length,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return ClientCard(
                      client: _filteredClients[index],
                      primaryColor: primaryColor,
                      onTap: () {},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
