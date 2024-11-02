import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ReceitaService {
  static Database? _db;
  // define que somente uma instancia do db estára aberta
  static final ReceitaService instance = ReceitaService._constructor();

  // nome da tabela e colunas
  final String _recNomeTabela = "rec_receita";
  final String _recId = "rec_id";
  final String _recNome = "rec_nome";
  final String _recPrecoUnitario = "rec_preco_unitario";
  final String _recQuantidadeRestante = "rec_quantidade_restante";
  final String _recValidade = "rec_validade";

  // metodo construtor
  ReceitaService._constructor();

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await getDatabase();
    }
    return _db!;
  }

  Future<Database> getDatabase() async {
    final dbDirPath = await getDatabasesPath();

    // usa join para atribuir o caminho do db com o db todo.db
    final dbPath = join(dbDirPath, "torres_de_acucar.db");

    final database = await openDatabase(
      dbPath,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_recNomeTabela (
          $_recId INTEGER PRIMARY KEY,
          $_recNome TEXT NOT NULL,
          $_recPrecoUnitario REAL NOT NULL,
          $_recQuantidadeRestante INTEGER NOT NULL,
          $_recValidade INTEGER NOT NULL,
        )
      ''');
      },
    );
    return database;
  }

  // Adiciona uma nova receita
  Future<void> addReceita(String nome, double precoUnitario, int quantidadeRestante, DateTime validade) async {
    final db = await database;

    await db.insert(
      _recNomeTabela,
      {
        _recNome: nome,
        _recPrecoUnitario: precoUnitario,
        _recQuantidadeRestante: quantidadeRestante,
        _recValidade: validade.millisecondsSinceEpoch, // Armazena data como INTEGER
      },
    );
  }

// Recupera todas as receitas
  Future<List<Map<String, dynamic>>> getReceitas() async {
    final db = await database;
    return await db.query(_recNomeTabela);
  }

// Atualiza uma receita
  Future<void> updateReceita(int id, Map<String, dynamic> values) async {
    final db = await database;
    await db.update(
      _recNomeTabela,
      values,
      where: "$_recId = ?",
      whereArgs: [id],
    );
  }

// Exclui uma receita
  Future<void> deleteReceita(int id) async {
    final db = await database;
    await db.delete(
      _recNomeTabela,
      where: "$_recId = ?",
      whereArgs: [id],
    );
  }
}
