import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();
  Database? _database;

  static const modules = <String, String>{
    'students': 'زده‌کوونکي', 'teachers': 'ښوونکي', 'classes': 'ټولګي او شعبې',
    'subjects': 'مضامین', 'attendance': 'حاضري', 'exams': 'ازموینې',
    'results': 'نمرې او پایلې', 'finance': 'مالي مدیریت', 'library': 'کتابتون',
    'timetable': 'مهالوېش', 'staff': 'کارکوونکي', 'parents': 'والدین',
    'notifications': 'خبرتیاوې', 'documents': 'اسناد', 'certificates': 'شهادتنامې',
    'holidays': 'رخصتۍ', 'reports': 'راپورونه', 'users': 'کاروونکي او صلاحیتونه',
    'academic_years': 'تعلیمي کلونه', 'discipline': 'انضباطي ثبت',
    'awards': 'جایزې او ستاینلیکونه', 'assets': 'د مکتب شتمنۍ',
    'transport': 'ترانسپورټ',
  };

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dir = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dir, 'maktab_school.db'),
      version: 1,
      onCreate: (db, version) async {
        for (final table in modules.keys) {
          await db.execute('CREATE TABLE $table (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, details TEXT NOT NULL DEFAULT \'\', created_at TEXT NOT NULL)');
        }
      },
    );
    return _database!;
  }

  Future<List<Map<String, Object?>>> getRecords(String table) async {
    final db = await database;
    return db.query(table, orderBy: 'id DESC');
  }

  Future<int> count(String table) async {
    final db = await database;
    final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM $table');
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<int> addRecord(String table, String title, String details) async {
    final db = await database;
    return db.insert(table, {
      'title': title.trim(),
      'details': details.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> deleteRecord(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
