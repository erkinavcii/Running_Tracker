import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/database.dart';
import '../../../data/run_repository.dart';
import '../profile_validation.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return SafeArea(
      child: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        // Keyed by id so the form keeps its own text state across rebuilds.
        data: (p) => _ProfileForm(key: const ValueKey('profile'), initial: p),
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  final Profile initial;

  const _ProfileForm({super.key, required this.initial});

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late final TextEditingController _birthYear;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    String fmt(num? v) => v == null
        ? ''
        : (v is double && v == v.roundToDouble() ? v.toInt().toString() : '$v');
    _weight = TextEditingController(text: fmt(p.weightKg));
    _height = TextEditingController(text: fmt(p.heightCm));
    _birthYear = TextEditingController(text: fmt(p.birthYear));
    for (final c in [_weight, _height, _birthYear]) {
      c.addListener(() {
        if (!_dirty) setState(() => _dirty = true);
      });
    }
  }

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    _birthYear.dispose();
    super.dispose();
  }

  RunRepository get _repo => ref.read(runRepositoryProvider);

  Future<void> _saveBody() async {
    if (!_formKey.currentState!.validate()) return;
    await _repo.updateProfile(ProfilesCompanion(
      weightKg: Value(parseDecimal(_weight.text)),
      heightCm: Value(int.tryParse(_height.text.trim())),
      birthYear: Value(int.tryParse(_birthYear.text.trim())),
    ));
    if (!mounted) return;
    setState(() => _dirty = false);
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // Toggles save immediately; read the live values from the stream.
    final p = ref.watch(profileProvider).valueOrNull ?? widget.initial;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        children: [
          const PageTitle(
            'Profile',
            subtitle: 'Used to estimate calories. Stays on this phone.',
          ),
          const SizedBox(height: 24),
          const SectionLabel('Body'),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Column(
              children: [
                _NumberField(
                  controller: _weight,
                  label: 'Weight',
                  suffix: 'kg',
                  decimal: true,
                  validator: (s) => validateWeight(s),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        controller: _height,
                        label: 'Height',
                        suffix: 'cm',
                        validator: validateHeight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumberField(
                        controller: _birthYear,
                        label: 'Birth year',
                        validator: validateBirthYear,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SegmentedButton<Sex?>(
                    showSelectedIcon: false,
                    emptySelectionAllowed: true,
                    segments: const [
                      ButtonSegment(value: Sex.female, label: Text('Female')),
                      ButtonSegment(value: Sex.male, label: Text('Male')),
                      ButtonSegment(value: Sex.other, label: Text('Other')),
                    ],
                    selected: {if (p.sex != null) p.sex},
                    onSelectionChanged: (s) => _repo.updateProfile(
                      ProfilesCompanion(sex: Value(s.isEmpty ? null : s.first)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _dirty ? _saveBody : null,
                  child: const Text('SAVE'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionLabel('Units'),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Distance',
                    style: TextStyle(fontSize: 15, color: c.ink),
                  ),
                ),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: false, label: Text('km')),
                    ButtonSegment(value: true, label: Text('mi')),
                  ],
                  selected: {p.useMiles},
                  onSelectionChanged: (s) => _repo
                      .updateProfile(ProfilesCompanion(useMiles: Value(s.first))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionLabel('Endurance runs'),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  value: p.audioCues,
                  onChanged: (v) => _repo
                      .updateProfile(ProfilesCompanion(audioCues: Value(v))),
                  title: const Text('Audio cues'),
                  subtitle: const Text('Time and pace every kilometre'),
                ),
                Divider(height: 1, color: c.line, indent: 16, endIndent: 16),
                SwitchListTile(
                  value: p.autoPause,
                  onChanged: (v) => _repo
                      .updateProfile(ProfilesCompanion(autoPause: Value(v))),
                  title: const Text('Auto-pause'),
                  subtitle: const Text('Pause when you stop moving'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final bool decimal;
  final String? Function(String?) validator;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.validator,
    this.suffix,
    this.decimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.,]' : r'[0-9]')),
      ],
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
