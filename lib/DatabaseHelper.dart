
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "face_rec_ess.db";
  static const _databaseVersion = 1;

  static const table = 'face_rec_ess_table';

  static const columnemp_id = 'emp_id';
  static const columnemp_name = 'emp_name';
  static const columndesignation = 'designation';
  static const columnemp_mac_userid = 'emp_mac_userid';
  static const columnmap_key_data = 'map_key_data';

  late Database _db;

  // this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    //final path = join(documentsDirectory.path, _databaseName);
   // final path = '${documentsDirectory.path} / ${_databaseName}';
    var databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnemp_id TEXT,
            $columnemp_name TEXT,
            $columndesignation TEXT,
            $columnemp_mac_userid TEXT,
            $columnmap_key_data TEXT
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    return await _db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await _db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }
  Future<String> getEmployeeName(String emp_id) async {
    String name = "";
    final results = await _db.rawQuery('SELECT emp_name FROM $table WHERE emp_id=?',[emp_id.toLowerCase()]);
    results.forEach((element) {
      //print(element[0].toString());
      name = element['emp_name'].toString();
    });
    print('db_name-->'+name);
    return name;
  }
  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    int id = row[columnemp_id];
    return await _db.update(
      table,
      row,
      where: '$columnemp_id = ?',
      whereArgs: [id],
    );
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    return await _db.delete(
      table,
      where: '$columnemp_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> DbClear_All_Data() async {
    try{
    //  final db = await database();
     await _db.execute("delete from "+ table);
    } catch(error){
      throw Exception('DbBase.cleanDatabase: ' + error.toString());
    }
  }
}