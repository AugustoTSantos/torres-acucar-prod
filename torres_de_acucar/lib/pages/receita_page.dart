import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:torres_de_acucar/controller/receita_controller.dart';
import 'package:torres_de_acucar/services/receita_service.dart';
import 'package:torres_de_acucar/utils/calendario.dart';
import 'package:torres_de_acucar/utils/formata_texto_dinheiro.dart';

class ReceitaPage extends StatefulWidget {
  const ReceitaPage({super.key, required String title});

  @override
  State<ReceitaPage> createState() => _ReceitaPageState();
}

class _ReceitaPageState extends State<ReceitaPage> {
  ReceitaController receitaController = ReceitaController();

  @override
  void initState() {
    super.initState();
    receitaController.setOnUpdate(() {
      setState(() {}); // This will trigger UI updates
    });
    receitaController.buscarTudo(); // Initial fetch for data
  }

  @override
  void dispose() {
    receitaController.buscaController.dispose();
    receitaController.nomeController.dispose();
    receitaController.precoController.dispose();
    receitaController.quantidadeController.dispose();
    receitaController.dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(232, 255, 234, 234),
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
              controller: receitaController.buscaController,
              onChanged: receitaController.buscarItem, // Calls buscarItem on text change
              decoration: InputDecoration(
                labelText: 'Buscar',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 96.0),
              child: receitaController.buildListaReceita(),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: FloatingActionButton(
          onPressed: () => receitaController.mostrarAddReceitaDialog(context),
          backgroundColor: const Color.fromARGB(1000, 204, 153, 153),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
