import 'package:flutter/material.dart';

import '../../../core/widgets/common.dart';
import '../../../core/widgets/pictogram.dart';

/// Placeholder until phase B (records are already being stored).
class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        children: const [
          PageTitle('Records'),
          SizedBox(height: 20),
          EmptyState(
            picto: Picto.finish,
            title: 'Personal records are coming',
            body: 'Your best 100 m times and top speeds are already being '
                'saved and will show up here in the next update.',
          ),
        ],
      ),
    );
  }
}
