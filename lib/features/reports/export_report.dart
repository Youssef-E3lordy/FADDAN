import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../missions/domain/mission.dart';

Future<Uint8List> buildMissionReport(Mission m) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (_) => [
        pw.Header(level: 0, child: pw.Text('FADDAN | Demonstration report')),
        pw.Text(
          'SIMULATED DATA - WATER TRIAL ONLY',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.orange800,
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Text('${m.farmName} / Greenhouse ${m.greenhouseId} / Row ${m.row}'),
        pw.Text('Mission: ${m.id}'),
        pw.Text('Fixture capture: ${m.started.toIso8601String()}'),
        pw.SizedBox(height: 12),
        pw.Text(
          'Coverage: ${m.covered.toStringAsFixed(0)} / ${m.length.toStringAsFixed(0)} cm',
        ),
        pw.Text('Simulated applied liquid: ${m.actualMl} mL'),
        pw.Text('Illustrative reference: ${m.baselineMl} mL'),
        pw.Text(
          'Illustrative liquid reduction: ${m.savings?.toStringAsFixed(1) ?? "N/A"}%',
        ),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          headers: [
            'Distance cm',
            'Observation',
            'Severity %',
            'Water mL',
            'Executed',
          ],
          data: m.points
              .map(
                (d) => [
                  d.distance.toStringAsFixed(0),
                  d.disease.replaceAll('_', ' '),
                  d.infection.toStringAsFixed(1),
                  d.dosage.toStringAsFixed(1),
                  d.sprayed ? 'Simulated yes' : 'No',
                ],
              )
              .toList(),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'No pesticide was prescribed or applied by this demonstration. Harvest dates are not available. This is not a GlobalG.A.P. certificate, an agronomic recommendation, a measured savings claim or an authorization to operate a robot. Local review drafts have not been sent to a server.',
        ),
      ],
    ),
  );
  return pdf.save();
}

Future<void> exportMission(Mission m) async {
  await Printing.layoutPdf(
    onLayout: (_) => buildMissionReport(m),
    name: 'FADDAN-${m.id}-DEMO.pdf',
  );
}
