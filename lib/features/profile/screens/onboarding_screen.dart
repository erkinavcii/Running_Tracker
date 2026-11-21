import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pictogram.dart';
import '../../../data/database.dart';
import '../../../data/run_repository.dart';
import '../profile_validation.dart';
import '../../../core/l10n.dart';

/// One-time first-launch step: ask for weight (for calories), skippable.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weight = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    super.dispose();
  }

  Future<void> _finish({required bool withWeight}) async {
    if (withWeight && !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(runRepositoryProvider).updateProfile(ProfilesCompanion(
          weightKg: withWeight ? Value(parseDecimal(_weight.text)) : const Value.absent(),
          onboarded: const Value(true),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            children: [
              // ListView stretches children; Align keeps the logo square.
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Pictogram(Picto.sprint, size: 52, color: c.onAccent),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                context.l10n.welcome,
                style: TextStyle(
                  fontSize: 32,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: c.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.onboardingBody,
                style: TextStyle(fontSize: 15, height: 1.45, color: c.muted),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _weight,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (s) =>
                    validateWeight(s, required: true, l: context.l10n),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  fontFeatures: tabularFigures,
                ),
                decoration: InputDecoration(
                  labelText: context.l10n.weight,
                  suffixText: 'kg',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (_) => _finish(withWeight: true),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : () => _finish(withWeight: true),
                child: Text(context.l10n.continueCaps),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving ? null : () => _finish(withWeight: false),
                style: TextButton.styleFrom(foregroundColor: c.muted),
                child: Text(context.l10n.skipForNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
