import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/cache.dart';
import 'features/missions/presentation/app_cubit.dart';
import 'app/faddan_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>('faddan_demo_v1');
    final cubit = AppCubit(HiveCache(box));
    await cubit.initialize();
    runApp(BlocProvider.value(value: cubit, child: const FaddanApp()));
  } catch (_) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'FADDAN could not open local storage. Allow site storage or restart the app. No data was sent.',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
