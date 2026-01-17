import 'package:flutter/material.dart';
import '../models/client_model.dart';

class ClientCard extends StatelessWidget {
  final ClientModel client;
  final Color primaryColor;
  final VoidCallback? onTap;

  const ClientCard({
    super.key,
    required this.client,
    this.primaryColor = const Color(0xFF382aae),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String initials = "";
    if (client.fullName != null && client.fullName!.isNotEmpty) {
      List<String> names = client.fullName!.trim().split(" ");
      if (names.isNotEmpty) {
        initials += names[0][0].toUpperCase();
        if (names.length > 1) {
          initials += names.last[0].toUpperCase();
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.fullName ?? "İsimsiz Danışan",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    client.email ?? "E-posta yok",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
