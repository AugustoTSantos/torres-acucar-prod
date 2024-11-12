import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendario {
  final TextEditingController dataController = TextEditingController();

  DateTime? dataSelecionada;

  // cria calendario para escolher datas
  Future<void> mostrarCalendario(BuildContext context) async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
    );

    if (dataEscolhida != null) {
      dataSelecionada = dataEscolhida;
      dataController.text = DateFormat('dd/MM/yyyy').format(dataSelecionada!);
    }
  }
}
