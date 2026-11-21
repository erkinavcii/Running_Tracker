import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/gpx.dart';
import '../../data/database.dart';
import '../../data/run_repository.dart';

/// Builds the GPX for [run] from its stored track.
Future<String?> runGpx(RunRepository repo, Run run, {String? name}) async {
  final track = await repo.getTrack(run.id);
  if (track.isEmpty) return null;
  return buildGpx(
    name: name ?? (run.type == RunType.sprint ? 'Sprint' : 'Run'),
    startedAt: run.startedAt,
    description: run.note,
    points: [
      for (final t in track)
        GpxPoint(
          time: run.startedAt.add(Duration(milliseconds: t.tMs)),
          lat: t.lat,
          lon: t.lon,
          ele: t.altM,
          segment: t.segment,
        ),
    ],
  );
}

/// Writes the GPX to the cache folder and opens the share sheet.
/// Returns false when the run has no GPS points to export.
Future<bool> shareRunGpx(
  BuildContext context,
  RunRepository repo,
  Run run, {
  String? name,
}) async {
  final box = context.findRenderObject() as RenderBox?;
  final gpx = await runGpx(repo, run, name: name);
  if (gpx == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File(p.join(dir.path, gpxFileName(run.startedAt)));
  await file.writeAsString(gpx, flush: true);
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'application/gpx+xml')],
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
  return true;
}
