import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ReceitaService {
  // nome da tabela e colunas
  final String _recNomeTabela = "rec_receita";
  final String _recId = "rec_id";
  final String _recNome = "rec_nome";
  final String _recPrecoUnitario = "rec_preco_unitario";
  final String _recQuantidadeRestante = "rec_quantidade_restante";
  final String _recValidade = "rec_validade";

  // metodo construtor
  ReceitaService._constructor();

  // define que somente uma instancia do db estára aberta
  static final ReceitaService instance = ReceitaService._constructor();

  Future<Database> getDatabase() async {
    final dbDirPath = await getDatabasesPath();

    // usa join para atribuir o caminho do db com o db torres_de_acucar.db
    final dbPath = join(dbDirPath, "torres_de_acucar.db");

    final database = await openDatabase(
      dbPath,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_recNomeTabela (
          $_recId INTEGER PRIMARY KEY,
          $_recNome TEXT NOT NULL,
          $_recPrecoUnitario REAL,
          $_recQuantidadeRestante INTEGER,
          $_recValidade INTEGER,
        )
      ''');
      },
    );
    return database;
  }

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await getDatabase();
    }
    return _db!;
  }

  // Adiciona uma nova receita
  Future<void> addReceita(
    String recNome,
    double recPrecoUnitario,
    int recQuantidadeRestante,
    DateTime recValidade,
  ) async {
    final db = await database;

    await db.insert(
      _recNomeTabela,
      {
        _recNome: recNome,
        _recPrecoUnitario: recPrecoUnitario,
        _recQuantidadeRestante: recQuantidadeRestante,
        _recValidade: recValidade.millisecondsSinceEpoch, // Armazena data como INTEGER
      },
    );
  }

  // Atualiza uma receita
  Future<void> updateReceita(int recId, Map<String, dynamic> values) async {
    final db = await database;
    await db.update(
      _recNomeTabela,
      values,
      where: "$_recId = ?",
      whereArgs: [recId],
    );
  }

  // Recupera todas as receitas
  Future<List<Map<String, dynamic>>> getReceitas() async {
    final db = await database;
    return await db.query(_recNomeTabela);
  }

// Exclui uma receita
  Future<void> deleteReceita(int recId) async {
    final db = await database;
    await db.delete(
      _recNomeTabela,
      where: "$_recId = ?",
      whereArgs: [recId],
    );
  }
}
