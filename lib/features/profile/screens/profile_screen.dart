import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../data/database.dart';
import '../../../data/run_repository.dart';
import '../profile_validation.dart';
import '../../../core/l10n.dart';

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
        .showSnackBar(SnackBar(content: Text(context.l10n.profileSaved)));
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
          PageTitle(
            context.l10n.profile,
            subtitle: context.l10n.profileSubtitle,
          ),
          const SizedBox(height: 24),
          SectionLabel(context.l10n.body),
          const SizedBox(height: 10),
          SurfaceCard(
            child: Column(
              children: [
                _NumberField(
                  controller: _weight,
                  label: context.l10n.weight,
                  suffix: 'kg',
                  decimal: true,
                  validator: (s) => validateWeight(s, l: context.l10n),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        controller: _height,
                        label: context.l10n.height,
                        suffix: 'cm',
                        validator: (s) => validateHeight(s, l: context.l10n),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumberField(
                        controller: _birthYear,
                        label: context.l10n.birthYear,
                        validator: (s) => validateBirthYear(s, l: context.l10n),
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
                    segments: [
                      ButtonSegment(value: Sex.female, label: Text(context.l10n.female)),
                      ButtonSegment(value: Sex.male, label: Text(context.l10n.male)),
                      ButtonSegment(value: Sex.other, label: Text(context.l10n.other)),
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
                  child: Text(context.l10n.saveCaps),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionLabel(context.l10n.units),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.distance,
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
          SectionLabel(context.l10n.language),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 'system',
                    label: Text(context.l10n.languageSystem),
                  ),
                  const ButtonSegment(value: 'en', label: Text('English')),
                  const ButtonSegment(value: 'tr', label: Text('Türkçe')),
                ],
                selected: {p.language ?? 'system'},
                onSelectionChanged: (s) => _repo.updateProfile(
                  ProfilesCompanion(
                    language: Value(s.first == 'system' ? null : s.first),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionLabel(context.l10n.enduranceRuns),
          const SizedBox(height: 10),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  value: p.audioCues,
                  onChanged: (v) => _repo
                      .updateProfile(ProfilesCompanion(audioCues: Value(v))),
                  title: Text(context.l10n.audioCues),
                  subtitle: Text(context.l10n.audioCuesSubtitle),
                ),
                Divider(height: 1, color: c.line, indent: 16, endIndent: 16),
                SwitchListTile(
                  value: p.autoPause,
                  onChanged: (v) => _repo
                      .updateProfile(ProfilesCompanion(autoPause: Value(v))),
                  title: Text(context.l10n.autoPause),
                  subtitle: Text(context.l10n.autoPauseSubtitle),
                ),
                Divider(height: 1, color: c.line, indent: 16, endIndent: 16),
                SwitchListTile(
                  value: p.keepScreenOn,
                  onChanged: (v) => _repo
                      .updateProfile(ProfilesCompanion(keepScreenOn: Value(v))),
                  title: Text(context.l10n.keepScreenOn),
                  subtitle: Text(context.l10n.keepScreenOnSubtitle),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.appliesNextRun,
            style: TextStyle(fontSize: 12.5, color: c.muted),
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
