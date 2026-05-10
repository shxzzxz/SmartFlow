import 'package:flutter/foundation.dart';

import '../data/database/app_database.dart';
import '../data/database/demo_data_seeder.dart';
import '../data/database/default_data_seeder.dart';

Future<void> bootstrap({
  bool seedDemo =
      const bool.fromEnvironment('SMARTFLOW_DEMO_SEED', defaultValue: false),
}) async {
  final database = AppDatabase();
  try {
    await seedDefaultData(database);
    if (kDebugMode && seedDemo) {
      await seedDemoData(database);
    }
  } finally {
    await database.close();
  }
}
