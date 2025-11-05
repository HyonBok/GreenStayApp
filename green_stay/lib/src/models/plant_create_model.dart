class PlantCreateModel {
  final String nome;
  final String especie;
  final int clienteId;
  final int umidade;
  final int luminosidade;
  final int temperatura;
  final String base64;

  PlantCreateModel({
    required this.nome,
    required this.especie,
    required this.clienteId,
    required this.umidade,
    required this.luminosidade,
    required this.temperatura,
    required this.base64,
  });

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'especie': especie,
        'clienteId': clienteId,
        'umidade': umidade,
        'luminosidade': luminosidade,
        'temperatura': temperatura,
        'base64': base64,
      };
}
