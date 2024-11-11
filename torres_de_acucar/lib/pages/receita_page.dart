import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:torres_de_acucar/services/receita_service.dart';
import 'package:torres_de_acucar/utils/formata_texto_dinheiro.dart';

class ReceitasPage extends StatefulWidget {
  const ReceitasPage({super.key, required String title});

  @override
  State<ReceitasPage> createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
  final TextEditingController _buscaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  List<Map<String, dynamic>> _tudo = [];
  List<Map<String, dynamic>> _filtrado = [];

  DateTime? _dataSelecionada;

  @override
  void initState() {
    super.initState();
    _buscarTudo();
  }

  Future<void> _buscarTudo() async {
    try {
      List<Map<String, dynamic>> tudo = await ReceitaService.instance.getReceitas();
      setState(() {
        _tudo = tudo;
        _filtrado = tudo;
      });
    } catch (e) {}
  }

  void _buscarItem(String query) {
    setState(() {
      _filtrado = query.isEmpty
          ? _tudo
          : _tudo.where((item) {
              return item['rec_nome'].toLowerCase().contains(query.toLowerCase());
            }).toList();
    });
  }

  Future<void> _calendario(BuildContext context) async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );

    if (dataEscolhida != null) {
      setState(() {
        _dataSelecionada = dataEscolhida;
        _dataController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada!);
      });
    }
  }

  Future<void> _salvarReceita() async {
    final String nome = _nomeController.text;
    final String precoText = _precoController.text.replaceAll(',', '.');
    final double preco = precoText.isEmpty ? 0.00 : double.parse(precoText);
    final String quantidadeTexto = _quantidadeController.text;
    final int quantidade = quantidadeTexto.isEmpty ? 0 : int.parse(quantidadeTexto);
    final DateTime? validade = _dataSelecionada;

    _limparCampos();

    // Confere se o Nome esta vazio
    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("A Receita Precisa de um Nome."),
          backgroundColor: Colors.red,
        ),
      );
      return; // Exit the function without saving
    }

    // If the nome is not empty, proceed with saving
    await ReceitaService.instance.addReceita(
      nome,
      preco,
      quantidade,
      validade,
    );

    // Refresh data and close the dialog
    await _buscarTudo();
    Navigator.pop(context); // Only call pop here
  }

  void _limparCampos() {
    _nomeController.clear();
    _precoController.clear();
    _quantidadeController.clear();
    _dataController.clear();
    _dataSelecionada = null;
  }

  Map<String, List<Map<String, dynamic>>> _agruparPorNome() {
    Map<String, List<Map<String, dynamic>>> receitasAgrupadas = {};
    for (var receita in _filtrado) {
      String nome = receita['rec_nome'];
      if (receitasAgrupadas.containsKey(nome)) {
        receitasAgrupadas[nome]!.add(receita);
      } else {
        receitasAgrupadas[nome] = [receita];
      }
    }
    return receitasAgrupadas;
  }

  void _editReceita(Map<String, dynamic> receita) {
    _nomeController.text = receita['rec_nome'];
    _precoController.text = receita['rec_preco_unitario'].toString();
    _quantidadeController.text = receita['rec_quantidade_restante'].toString();
    _dataSelecionada = DateTime.fromMillisecondsSinceEpoch(receita['rec_validade']);
    _dataController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada!);

    _mostrarAddReceitaDialog(context, editing: true, receitaId: receita['rec_id']);
  }

  Future<void> _deleteReceita(int? id) async {
    if (id != null) {
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

      // If the user confirmed deletion, proceed to delete
      if (confirmarDelete == true) {
        await ReceitaService.instance.deleteReceita(id);
        _buscarTudo(); // Refresh the list after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Item Deletado com Sucesso")),
        );
      }
    } else {
      // Handle cases where id is null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Impossivel Deletar, ID nulo")),
      );
    }
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _nomeController.dispose();
    _precoController.dispose();
    _quantidadeController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Widget _buildReceitaItem(String nome, List<Map<String, dynamic>> receitas) {
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
              IconButton(icon: Icon(Icons.edit), onPressed: () => _editReceita(receita)),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  if (receita['rec_id'] != null) {
                    _deleteReceita(receita['rec_id']);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Impossivel Deletar, Id não Encontrado")),
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

  Widget _buildListaReceita() {
    Map<String, List<Map<String, dynamic>>> receitasAgrupadas = _agruparPorNome();
    return ListView(
      children: receitasAgrupadas.entries.map((entry) {
        return _buildReceitaItem(entry.key, entry.value);
      }).toList(),
    );
  }

  void _mostrarAddReceitaDialog(BuildContext context, {bool editing = false, int? receitaId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(editing ? 'Editar Receita' : 'Adicionar Receita'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nomeController, decoration: InputDecoration(labelText: 'Nome')),
              SizedBox(height: 8),
              TextField(
                controller: _precoController,
                decoration: InputDecoration(labelText: 'Preço Unitário'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  FormataTextoDinheiro(),
                ],
              ),
              SizedBox(height: 8),
              TextField(
                controller: _quantidadeController,
                decoration: InputDecoration(labelText: 'Quantidade Restante'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              TextField(
                controller: _dataController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Validade'),
                onTap: () => _calendario(context),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (editing && receitaId != null) {
                await ReceitaService.instance.updateReceita(receitaId, {
                  'rec_nome': _nomeController.text,
                  'rec_preco_unitario': double.tryParse(_precoController.text) ?? 0.0,
                  'rec_quantidade_restante': int.tryParse(_quantidadeController.text) ?? 0,
                  'rec_validade': _dataSelecionada?.millisecondsSinceEpoch ?? 0,
                });
                // Refresh the list after updating
                await _buscarTudo();
                Navigator.pop(context); // Close the dialog after update
              } else {
                await _salvarReceita(); // Save and fetch data in _salvarReceita
              }
            },
            child: Text(editing ? 'Atualizar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(232, 255, 234, 234),
      appBar: AppBar(
        title: Text(
          'Receitas',
          style: TextStyle(
            fontFamily: 'AboutLove',
            fontSize: 32,
            color: const Color.fromARGB(1000, 81, 48, 37),
          ),
        ),
        backgroundColor: const Color.fromARGB(1000, 204, 153, 153),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.menu),
            onSelected: (value) {
              Navigator.pushNamed(context, value.toString());
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: '/cliente', child: Text('Clientes')),
              PopupMenuItem(value: '/ingrediente', child: Text('Ingredientes')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _buscaController,
              onChanged: _buscarItem,
              decoration: InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 96.0), // Adds space at the bottom
              child: _buildListaReceita(),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0), // Adjust the padding as needed
        child: FloatingActionButton(
          onPressed: () => _mostrarAddReceitaDialog(context),
          backgroundColor: const Color.fromARGB(1000, 204, 153, 153),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
