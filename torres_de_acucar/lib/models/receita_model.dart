class ReceitaModel {
  final int rec_id;
  final String rec_nome;
  final double rec_preco_unitario;
  final int rec_quantidade_restante;
  final DateTime rec_validade;

  ReceitaModel({
    required this.rec_id,
    required this.rec_nome,
    required this.rec_preco_unitario,
    required this.rec_quantidade_restante,
    required this.rec_validade,
  });
}
