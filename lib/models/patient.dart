// dummy page for the patient
// later on patient data will be filled with data from backend (firely) server

class Patient {
  final String id;
  final String name;
  final String gender;
  final String? birthDate;

  Patient({
    required this.id,
    required this.name,
    required this.gender,
    this.birthDate,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    final nameList = json['name'] as List<dynamic>?;

    return Patient(
      id: json['id'],
      name: nameList != null && nameList.isNotEmpty
          ? nameList[0]['text'] ?? 'Unbekannt'
          : 'Unbekannt',
      gender: json['gender'] ?? 'unbekannt',
      birthDate: json['birthDate'],
    );
  }
}
