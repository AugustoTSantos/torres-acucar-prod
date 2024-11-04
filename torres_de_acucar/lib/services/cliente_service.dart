import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ClienteService {
  final String _cliNomeTabela = "cli_cliente";
  final String _cliId = "cli_id";
  final String _cliNome = "cli_nome";
  final String _cliTelefone1 = "cli_telefone_1";
  final String _cliTelefone2 = "cli_telefone_2";

  ClienteService._constructor();

  static final ClienteService instance = ClienteService._constructor();

  Future<Database> getDatabase() async {
    final dbDirPath = await getDatabasesPath();

    final dbPath = join(dbDirPath, "torres_de_acucar.db");

    final database = await openDatabase(
      dbPath,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE $_cliNomeTabela (
          $_cliId INTEGER PRIMARY KEY,
          $_cliNome TEXT NOT NULL,
          $_cliTelefone1 TEXT,
          $_cliTelefone2 TEXT,
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

  // create
  Future<void> addCliente(
    String cliNome,
    String cliTelefone1,
    String cliTelefone2,
  ) async {
    final db = await database;

    await db.insert(
      _cliNomeTabela,
      {
        _cliNome: cliNome,
        _cliTelefone1: cliTelefone1,
        _cliTelefone2: cliTelefone2,
      },
    );
  }

  // update
  Future<void> updateCliente(int cliId, Map<String, dynamic> values) async {
    final db = await database;
    await db.update(
      _cliNomeTabela,
      values,
      where: "$_cliId = ?",
      whereArgs: [cliId],
    );
  }

  // read
  Future<List<Map<String, dynamic>>> getClientes() async {
    final db = await database;
    return await db.query(_cliNomeTabela);
  }

  // delete
  Future<void> deleteCliente(int cliId) async {
    final db = await database;
    await db.delete(
      _cliNomeTabela,
      where: "$_cliId = ?",
      whereArgs: [cliId],
    );
  }
}
