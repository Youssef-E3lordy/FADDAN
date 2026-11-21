import 'package:faddan/app/faddan_app.dart';
import 'package:faddan/features/missions/domain/mission.dart';
import 'package:faddan/features/missions/presentation/app_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'domain_cache_test.dart' show MemoryCache;

void main() {
  for (final width in [320.0, 390.0, 1280.0]) {
    testWidgets('all main routes and mission detail render at $width px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final c = AppCubit(MemoryCache());
      await tester.runAsync(() => c.initialize());
      await tester.pumpWidget(
        BlocProvider.value(value: c, child: const FaddanApp()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(tester.takeException(), isNull);
      c.login(UserRole.agronomist);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('A good view of your field.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      for (final label in ['Missions', 'Review', 'Reports', 'Settings']) {
        await tester.tap(find.text(label).last);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        expect(tester.takeException(), isNull, reason: label);
      }
      await tester.tap(find.text('Missions').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.tap(find.byType(MissionTile).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Three layers. One crop row.'), findsOneWidget);
      for (final label in [
        'Coverage',
        'Disease pressure',
        'As-applied / PHI',
      ]) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await c.close();
    });
  }
}
