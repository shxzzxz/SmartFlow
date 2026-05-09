import '../data/database/app_database.dart';
import '../data/database/default_data_seeder.dart';

Future<void> bootstrap() async {
  final database = AppDatabase();
  try {
    await seedDefaultData(database);
  } finally {
    await database.close();
  }
}
