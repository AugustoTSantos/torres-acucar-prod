import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class IngredienteService {
  static Database? _db;
  // define que somente uma instancia do db estára aberta
  static final IngredienteService instance = IngredienteService._constructor();

  final String _ingNomeTabela = "ing_ingrendiente";
  final String _ingId = "ing_id";
  final String _ingNome = "ing_nome";
  final String _ingQuantidade = "ing_quantidade";
  final String _ingPreco = "ing_preco";
  final String _ingValidade = "ing_validade";
  final String _ingFornecedor = "ing_fornecedor";
  final String _ingDataCompra = "ing_data_compra";

  // metodo construtor
  IngredienteService._constructor();

  Future<Database> getDatabase() async {
    final dbDirPath = await getDatabasesPath();

    final dbPath = join(dbDirPath, "torres_de_acucar.db");

    final database = await openDatabase(
      dbPath,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_ingNomeTabela (
            $_ingId INTEGER PRIMARY KEY,
            $_ingNome TEXT NOT NULL,
            $_ingQuantidade REAL,
            $_ingPreco REAL,
            $_ingValidade INTEGER,
            $_ingFornecedor TEXT,
            $_ingDataCompra INTEGER,
          )
        ''');
      },
    );
    return database;
  }

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await getDatabase();
    }
    return _db!;
  }

  // create
  Future<void> addIngrediente(
    String ingNome,
    double ingQuantidade,
    double ingPreco,
    DateTime ingValidade,
    String ingFornecedor,
    DateTime ingDataCompra,
  ) async {
    final db = await database;

    await db.insert(
      _ingNomeTabela,
      {
        _ingNome: ingNome,
        _ingQuantidade: ingQuantidade,
        _ingPreco: ingPreco,
        _ingValidade: ingValidade.millisecondsSinceEpoch, // Armazena data como INTEGER
        _ingFornecedor: ingFornecedor,
        _ingDataCompra: ingDataCompra.microsecondsSinceEpoch, // Armazena data como INTEGER
      },
    );
  }

  //update
  Future<void> updateIngrediente(int ingId, Map<String, dynamic> values) async {
    final db = await database;
    await db.update(
      _ingNomeTabela,
      values,
      where: "$_ingId = ?",
      whereArgs: [ingId],
    );
  }

  // read
  Future<List<Map<String, dynamic>>> getIngredientes() async {
    final db = await database;
    return await db.query(_ingNomeTabela);
  }

  // delete
  Future<void> deleteIngrediente(int ingId) async {
    final db = await database;
    await db.delete(
      _ingNomeTabela,
      where: "$_ingId = ?",
      whereArgs: [ingId],
    );
  }
}
