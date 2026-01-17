class DietDetail {
  String day;
  String meal;
  String content;

  DietDetail({
    required this.day,
    required this.meal,
    required this.content,
  });

  factory DietDetail.fromJson(Map<String, dynamic> json) {
    return DietDetail(
      day: json['day'] ?? '',
      meal: json['meal'] ?? '',
      content: json['content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'meal': meal,
      'content': content,
    };
  }
}

class DietModel {
  final int? id; // Web'de 'dietListId'
  final int clientId;
  final String? clientName; // Listeleme ekranında görünüyor
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final List<DietDetail> details; // Web'deki 'rows'

  DietModel({
    this.id,
    required this.clientId,
    this.clientName,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.details,
  });

  factory DietModel.fromJson(Map<String, dynamic> json) {
    var list = json['details'] as List? ?? [];
    List<DietDetail> detailsList =
        list.map((i) => DietDetail.fromJson(i)).toList();

    return DietModel(
      // Web'de bazen 'dietListId' bazen 'id' olarak gelebilir, ikisini de kontrol ediyoruz
      id: json['dietListId'] ?? json['id'],
      clientId: json['clientId'] ?? 0,
      clientName: json['clientName'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      details: detailsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }
}
