class ClientModel {
  final int clientId;
  final int userId;
  final String? fullName;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? lastAppointmentDate;

  ClientModel({
    required this.clientId,
    required this.userId,
    this.fullName,
    this.username,
    this.email,
    this.phoneNumber,
    this.lastAppointmentDate,
  });

  // JSON'dan Dart nesnesine çeviren metod
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      clientId: json['clientId'],
      userId: json['userId'],
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      lastAppointmentDate: json['lastAppointmentDate'],
    );
  }
}
