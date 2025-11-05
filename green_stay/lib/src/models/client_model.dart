class ClientModel {
  final int id;
  final String nome;
  final int usuarioId;

  ClientModel({
    required this.id,
    required this.nome,
    required this.usuarioId,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return ClientModel(
      id: parseInt(json['ID'] ?? json['id']),
      nome: parseString(json['Nome'] ?? json['nome']),
      usuarioId: parseInt(json['Usuario'] ?? json['usuarioId']),
    );
  }
}
