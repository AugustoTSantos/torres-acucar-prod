class IngredienteModel {
  final int ing_id;
  final String ing_nome;
  final double ing_quantidade;
  final double ing_preco;
  final DateTime ing_validade;
  final String ing_fornecedor;
  final DateTime ing_data_compra;

  IngredienteModel({
    required this.ing_id,
    required this.ing_nome,
    required this.ing_quantidade,
    required this.ing_preco,
    required this.ing_validade,
    required this.ing_fornecedor,
    required this.ing_data_compra,
  });
}
