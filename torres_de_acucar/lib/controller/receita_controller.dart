import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:torres_de_acucar/services/receita_service.dart';
import 'package:torres_de_acucar/utils/calendario.dart';
import 'package:torres_de_acucar/utils/formata_texto_dinheiro.dart';

class ReceitaController {
  final TextEditingController buscaController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController precoController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController dataController = TextEditingController();

  Calendario calendario = Calendario();
  List<Map<String, dynamic>> todasReceitas = [];
  List<Map<String, dynamic>> receitasFiltradas = [];

  // Callback for UI updates
  Function()? _onUpdate;

  // Assign the callback function from the page
  void setOnUpdate(Function()? callback) {
    _onUpdate = callback;
  }

  // Retrieve all data and trigger the callback
  Future<void> buscarTudo() async {
    try {
      todasReceitas = await ReceitaService.instance.getReceitas();
      receitasFiltradas = todasReceitas;
      _onUpdate?.call(); // Trigger the UI update
    } catch (e) {
      // Handle the error appropriately (e.g., log or show an alert)
    }
  }

  // Filter items based on the query and trigger the callback
  void buscarItem(String query) {
    receitasFiltradas = query.isEmpty
        ? todasReceitas
        : todasReceitas.where((item) {
            return item['rec_nome'].toLowerCase().contains(query.toLowerCase());
          }).toList();
    _onUpdate?.call(); // Trigger the UI update
  }

  // deixa campos em branco
  void limparCampos() {
    nomeController.clear();
    precoController.clear();
    quantidadeController.clear();
    dataController.clear();
    calendario.dataSelecionada = null;
  }

  // organiza depois chama função para salvar receita no banco
  Future<void> salvarReceita(BuildContext context) async {
    final String nome = nomeController.text;
    final String precoText = precoController.text.replaceAll(',', '.');
    final double preco = precoText.isEmpty ? 0.00 : double.parse(precoText);
    final String quantidadeTexto = quantidadeController.text;
    final int quantidade = quantidadeTexto.isEmpty ? 0 : int.parse(quantidadeTexto);
    final DateTime? validade = calendario.dataSelecionada;

    limparCampos(); // deixa campos em branco após salvar

    // Confere se o Nome esta vazio
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("A Receita Precisa de um Nome."),
          backgroundColor: Colors.red,
        ),
      );
      return; // sai da função sem salvar
    }

    // se o nome não está vazio chama função para salvar no banco
    await ReceitaService.instance.addReceita(
      nome,
      preco,
      quantidade,
      validade,
    );

    // atualizar pagina e fecha tela de adição
    await buscarTudo();
    Navigator.pop(context);
  }

  // faz com que não haja receitas duplicadas com mesmo nome na exibição
  Map<String, List<Map<String, dynamic>>> agruparPorNome() {
    Map<String, List<Map<String, dynamic>>> receitasAgrupadas = {};
    for (var receita in receitasFiltradas) {
      String nome = receita['rec_nome'];
      if (receitasAgrupadas.containsKey(nome)) {
        receitasAgrupadas[nome]!.add(receita);
      } else {
        receitasAgrupadas[nome] = [receita];
      }
    }
    return receitasAgrupadas;
  }

  // faz com que os cards não se dupliquem
  Widget buildListaReceita() {
    Map<String, List<Map<String, dynamic>>> receitasAgrupadas = agruparPorNome();
    return ListView(
      children: receitasAgrupadas.entries.map((entry) {
        return buildReceitaItem(entry.key, entry.value);
      }).toList(),
    );
  }

  // tela para alterar e adicionar novas receitas
  void mostrarAddReceitaDialog(BuildContext context, {bool editing = false, int? receitaId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editing ? 'Editar Receita' : 'Adicionar Receita'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: precoController,
                decoration: InputDecoration(labelText: 'Preço Unitário'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  FormataTextoDinheiro(),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: quantidadeController,
                decoration: InputDecoration(labelText: 'Quantidade Restante'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              TextField(
                controller: dataController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Validade'),
                onTap: () => calendario.mostrarCalendario(context),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(1000, 204, 153, 153),
            ),
            onPressed: () async {
              if (editing && receitaId != null) {
                await ReceitaService.instance.updateReceita(receitaId, {
                  'rec_nome': nomeController.text,
                  'rec_preco_unitario': double.tryParse(precoController.text) ?? 0.0,
                  'rec_quantidade_restante': int.tryParse(quantidadeController.text) ?? 0,
                  'rec_validade': calendario.dataSelecionada?.millisecondsSinceEpoch ?? 0,
                });
                // Refresh the list after updating
                await buscarTudo();
                Navigator.pop(context);
              } else {
                await salvarReceita(context); // Pass the context here
              }
            },
            child: Text(
              editing ? 'Atualizar' : 'Salvar',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // serve para organizar quais campos e seus valores serão alterados
  void editReceita(Map<String, dynamic> receita) {
    nomeController.text = receita['rec_nome'];
    precoController.text = receita['rec_preco_unitario'].toString();
    quantidadeController.text = receita['rec_quantidade_restante'].toString();
    calendario.dataSelecionada = DateTime.fromMillisecondsSinceEpoch(receita['rec_validade']);
    dataController.text = DateFormat('dd/MM/yyyy').format(calendario.dataSelecionada!);

    mostrarAddReceitaDialog(context as BuildContext, editing: true, receitaId: receita['rec_id']);
  }

  // organiza depois chama função para deletar receita por Id
  Future<void> deleteReceita(BuildContext context, int? recId) async {
    if (recId != null) {
      bool confirmarDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirmação"),
            content: Text("Deletar Item?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Cancel
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Confirm
                child: Text("Deletar"),
              ),
            ],
          );
        },
      );

      if (confirmarDelete == true) {
        // Confirm delete
        await ReceitaService.instance.deleteReceita(recId);
        buscarTudo(); // Update list after delete
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Item Deletado com Sucesso")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossivel Deletar, ID nulo")),
      );
    }
  }

  // cria os cards onde outros dados de receitas com mesmo nome são visualizadas.
  Widget buildReceitaItem(String nome, List<Map<String, dynamic>> receitas) {
    return Card(
      child: ExpansionTile(
        title: Text(nome),
        children: receitas.map((receita) {
          DateTime validade = DateTime.fromMillisecondsSinceEpoch(receita['rec_validade']);
          String dataFormatada = DateFormat('dd/MM/yyyy').format(validade);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Preço: ${receita['rec_preco_unitario']}')),
              Expanded(child: Text('Qtd: ${receita['rec_quantidade_restante']}')),
              Expanded(child: Text('Validade: $dataFormatada')),
              IconButton(icon: Icon(Icons.edit), onPressed: () => editReceita(receita)),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  if (receita['rec_id'] != null) {
                    deleteReceita(context as BuildContext, receita['rec_id']); // Pass 'context' as the first argument
                  } else {
                    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
                      SnackBar(content: Text("Impossível Deletar, ID não Encontrado")),
                    );
                  }
                },
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
