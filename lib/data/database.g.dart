// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<int> heightCm = GeneratedColumn<int>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Sex?, String> sex =
      GeneratedColumn<String>(
        'sex',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Sex?>($ProfilesTable.$convertersexn);
  static const VerificationMeta _useMilesMeta = const VerificationMeta(
    'useMiles',
  );
  @override
  late final GeneratedColumn<bool> useMiles = GeneratedColumn<bool>(
    'use_miles',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("use_miles" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _audioCuesMeta = const VerificationMeta(
    'audioCues',
  );
  @override
  late final GeneratedColumn<bool> audioCues = GeneratedColumn<bool>(
    'audio_cues',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("audio_cues" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _autoPauseMeta = const VerificationMeta(
    'autoPause',
  );
  @override
  late final GeneratedColumn<bool> autoPause = GeneratedColumn<bool>(
    'auto_pause',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_pause" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onboardedMeta = const VerificationMeta(
    'onboarded',
  );
  @override
  late final GeneratedColumn<bool> onboarded = GeneratedColumn<bool>(
    'onboarded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weightKg,
    heightCm,
    birthYear,
    sex,
    useMiles,
    audioCues,
    autoPause,
    onboarded,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    }
    if (data.containsKey('use_miles')) {
      context.handle(
        _useMilesMeta,
        useMiles.isAcceptableOrUnknown(data['use_miles']!, _useMilesMeta),
      );
    }
    if (data.containsKey('audio_cues')) {
      context.handle(
        _audioCuesMeta,
        audioCues.isAcceptableOrUnknown(data['audio_cues']!, _audioCuesMeta),
      );
    }
    if (data.containsKey('auto_pause')) {
      context.handle(
        _autoPauseMeta,
        autoPause.isAcceptableOrUnknown(data['auto_pause']!, _autoPauseMeta),
      );
    }
    if (data.containsKey('onboarded')) {
      context.handle(
        _onboardedMeta,
        onboarded.isAcceptableOrUnknown(data['onboarded']!, _onboardedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_cm'],
      ),
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      ),
      sex: $ProfilesTable.$convertersexn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sex'],
        ),
      ),
      useMiles:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}use_miles'],
          )!,
      audioCues:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}audio_cues'],
          )!,
      autoPause:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}auto_pause'],
          )!,
      onboarded:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}onboarded'],
          )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Sex, String, String> $convertersex =
      const EnumNameConverter<Sex>(Sex.values);
  static JsonTypeConverter2<Sex?, String?, String?> $convertersexn =
      JsonTypeConverter2.asNullable($convertersex);
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final double? weightKg;
  final int? heightCm;
  final int? birthYear;
  final Sex? sex;
  final bool useMiles;
  final bool audioCues;
  final bool autoPause;
  final bool onboarded;
  const Profile({
    required this.id,
    this.weightKg,
    this.heightCm,
    this.birthYear,
    this.sex,
    required this.useMiles,
    required this.audioCues,
    required this.autoPause,
    required this.onboarded,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<int>(heightCm);
    }
    if (!nullToAbsent || birthYear != null) {
      map['birth_year'] = Variable<int>(birthYear);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>($ProfilesTable.$convertersexn.toSql(sex));
    }
    map['use_miles'] = Variable<bool>(useMiles);
    map['audio_cues'] = Variable<bool>(audioCues);
    map['auto_pause'] = Variable<bool>(autoPause);
    map['onboarded'] = Variable<bool>(onboarded);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      weightKg:
          weightKg == null && nullToAbsent
              ? const Value.absent()
              : Value(weightKg),
      heightCm:
          heightCm == null && nullToAbsent
              ? const Value.absent()
              : Value(heightCm),
      birthYear:
          birthYear == null && nullToAbsent
              ? const Value.absent()
              : Value(birthYear),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      useMiles: Value(useMiles),
      audioCues: Value(audioCues),
      autoPause: Value(autoPause),
      onboarded: Value(onboarded),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      heightCm: serializer.fromJson<int?>(json['heightCm']),
      birthYear: serializer.fromJson<int?>(json['birthYear']),
      sex: $ProfilesTable.$convertersexn.fromJson(
        serializer.fromJson<String?>(json['sex']),
      ),
      useMiles: serializer.fromJson<bool>(json['useMiles']),
      audioCues: serializer.fromJson<bool>(json['audioCues']),
      autoPause: serializer.fromJson<bool>(json['autoPause']),
      onboarded: serializer.fromJson<bool>(json['onboarded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weightKg': serializer.toJson<double?>(weightKg),
      'heightCm': serializer.toJson<int?>(heightCm),
      'birthYear': serializer.toJson<int?>(birthYear),
      'sex': serializer.toJson<String?>(
        $ProfilesTable.$convertersexn.toJson(sex),
      ),
      'useMiles': serializer.toJson<bool>(useMiles),
      'audioCues': serializer.toJson<bool>(audioCues),
      'autoPause': serializer.toJson<bool>(autoPause),
      'onboarded': serializer.toJson<bool>(onboarded),
    };
  }

  Profile copyWith({
    int? id,
    Value<double?> weightKg = const Value.absent(),
    Value<int?> heightCm = const Value.absent(),
    Value<int?> birthYear = const Value.absent(),
    Value<Sex?> sex = const Value.absent(),
    bool? useMiles,
    bool? audioCues,
    bool? autoPause,
    bool? onboarded,
  }) => Profile(
    id: id ?? this.id,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    birthYear: birthYear.present ? birthYear.value : this.birthYear,
    sex: sex.present ? sex.value : this.sex,
    useMiles: useMiles ?? this.useMiles,
    audioCues: audioCues ?? this.audioCues,
    autoPause: autoPause ?? this.autoPause,
    onboarded: onboarded ?? this.onboarded,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      sex: data.sex.present ? data.sex.value : this.sex,
      useMiles: data.useMiles.present ? data.useMiles.value : this.useMiles,
      audioCues: data.audioCues.present ? data.audioCues.value : this.audioCues,
      autoPause: data.autoPause.present ? data.autoPause.value : this.autoPause,
      onboarded: data.onboarded.present ? data.onboarded.value : this.onboarded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('birthYear: $birthYear, ')
          ..write('sex: $sex, ')
          ..write('useMiles: $useMiles, ')
          ..write('audioCues: $audioCues, ')
          ..write('autoPause: $autoPause, ')
          ..write('onboarded: $onboarded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weightKg,
    heightCm,
    birthYear,
    sex,
    useMiles,
    audioCues,
    autoPause,
    onboarded,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.weightKg == this.weightKg &&
          other.heightCm == this.heightCm &&
          other.birthYear == this.birthYear &&
          other.sex == this.sex &&
          other.useMiles == this.useMiles &&
          other.audioCues == this.audioCues &&
          other.autoPause == this.autoPause &&
          other.onboarded == this.onboarded);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<double?> weightKg;
  final Value<int?> heightCm;
  final Value<int?> birthYear;
  final Value<Sex?> sex;
  final Value<bool> useMiles;
  final Value<bool> audioCues;
  final Value<bool> autoPause;
  final Value<bool> onboarded;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.sex = const Value.absent(),
    this.useMiles = const Value.absent(),
    this.audioCues = const Value.absent(),
    this.autoPause = const Value.absent(),
    this.onboarded = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.sex = const Value.absent(),
    this.useMiles = const Value.absent(),
    this.audioCues = const Value.absent(),
    this.autoPause = const Value.absent(),
    this.onboarded = const Value.absent(),
  });
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<double>? weightKg,
    Expression<int>? heightCm,
    Expression<int>? birthYear,
    Expression<String>? sex,
    Expression<bool>? useMiles,
    Expression<bool>? audioCues,
    Expression<bool>? autoPause,
    Expression<bool>? onboarded,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (birthYear != null) 'birth_year': birthYear,
      if (sex != null) 'sex': sex,
      if (useMiles != null) 'use_miles': useMiles,
      if (audioCues != null) 'audio_cues': audioCues,
      if (autoPause != null) 'auto_pause': autoPause,
      if (onboarded != null) 'onboarded': onboarded,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<double?>? weightKg,
    Value<int?>? heightCm,
    Value<int?>? birthYear,
    Value<Sex?>? sex,
    Value<bool>? useMiles,
    Value<bool>? audioCues,
    Value<bool>? autoPause,
    Value<bool>? onboarded,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      birthYear: birthYear ?? this.birthYear,
      sex: sex ?? this.sex,
      useMiles: useMiles ?? this.useMiles,
      audioCues: audioCues ?? this.audioCues,
      autoPause: autoPause ?? this.autoPause,
      onboarded: onboarded ?? this.onboarded,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<int>(heightCm.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(
        $ProfilesTable.$convertersexn.toSql(sex.value),
      );
    }
    if (useMiles.present) {
      map['use_miles'] = Variable<bool>(useMiles.value);
    }
    if (audioCues.present) {
      map['audio_cues'] = Variable<bool>(audioCues.value);
    }
    if (autoPause.present) {
      map['auto_pause'] = Variable<bool>(autoPause.value);
    }
    if (onboarded.present) {
      map['onboarded'] = Variable<bool>(onboarded.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('birthYear: $birthYear, ')
          ..write('sex: $sex, ')
          ..write('useMiles: $useMiles, ')
          ..write('audioCues: $audioCues, ')
          ..write('autoPause: $autoPause, ')
          ..write('onboarded: $onboarded')
          ..write(')'))
        .toString();
  }
}

class $RunsTable extends Runs with TableInfo<$RunsTable, Run> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RunType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RunType>($RunsTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<RunStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RunStatus>($RunsTable.$converterstatus);
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _movingMsMeta = const VerificationMeta(
    'movingMs',
  );
  @override
  late final GeneratedColumn<int> movingMs = GeneratedColumn<int>(
    'moving_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgSpeedMpsMeta = const VerificationMeta(
    'avgSpeedMps',
  );
  @override
  late final GeneratedColumn<double> avgSpeedMps = GeneratedColumn<double>(
    'avg_speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxSpeedMpsMeta = const VerificationMeta(
    'maxSpeedMps',
  );
  @override
  late final GeneratedColumn<double> maxSpeedMps = GeneratedColumn<double>(
    'max_speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elevGainMMeta = const VerificationMeta(
    'elevGainM',
  );
  @override
  late final GeneratedColumn<double> elevGainM = GeneratedColumn<double>(
    'elev_gain_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sprintTimeMsMeta = const VerificationMeta(
    'sprintTimeMs',
  );
  @override
  late final GeneratedColumn<int> sprintTimeMs = GeneratedColumn<int>(
    'sprint_time_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDistanceMMeta = const VerificationMeta(
    'targetDistanceM',
  );
  @override
  late final GeneratedColumn<double> targetDistanceM = GeneratedColumn<double>(
    'target_distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GpsQuality, String> gpsQuality =
      GeneratedColumn<String>(
        'gps_quality',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GpsQuality>($RunsTable.$convertergpsQuality);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    status,
    startedAt,
    endedAt,
    elapsedMs,
    movingMs,
    distanceM,
    avgSpeedMps,
    maxSpeedMps,
    kcal,
    elevGainM,
    sprintTimeMs,
    targetDistanceM,
    gpsQuality,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Run> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    }
    if (data.containsKey('moving_ms')) {
      context.handle(
        _movingMsMeta,
        movingMs.isAcceptableOrUnknown(data['moving_ms']!, _movingMsMeta),
      );
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('avg_speed_mps')) {
      context.handle(
        _avgSpeedMpsMeta,
        avgSpeedMps.isAcceptableOrUnknown(
          data['avg_speed_mps']!,
          _avgSpeedMpsMeta,
        ),
      );
    }
    if (data.containsKey('max_speed_mps')) {
      context.handle(
        _maxSpeedMpsMeta,
        maxSpeedMps.isAcceptableOrUnknown(
          data['max_speed_mps']!,
          _maxSpeedMpsMeta,
        ),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('elev_gain_m')) {
      context.handle(
        _elevGainMMeta,
        elevGainM.isAcceptableOrUnknown(data['elev_gain_m']!, _elevGainMMeta),
      );
    }
    if (data.containsKey('sprint_time_ms')) {
      context.handle(
        _sprintTimeMsMeta,
        sprintTimeMs.isAcceptableOrUnknown(
          data['sprint_time_ms']!,
          _sprintTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('target_distance_m')) {
      context.handle(
        _targetDistanceMMeta,
        targetDistanceM.isAcceptableOrUnknown(
          data['target_distance_m']!,
          _targetDistanceMMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Run map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Run(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      type: $RunsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      status: $RunsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      startedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}started_at'],
          )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      elapsedMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}elapsed_ms'],
          )!,
      movingMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}moving_ms'],
          )!,
      distanceM:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}distance_m'],
          )!,
      avgSpeedMps:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}avg_speed_mps'],
          )!,
      maxSpeedMps:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}max_speed_mps'],
          )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      ),
      elevGainM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elev_gain_m'],
      ),
      sprintTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sprint_time_ms'],
      ),
      targetDistanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_distance_m'],
      ),
      gpsQuality: $RunsTable.$convertergpsQuality.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}gps_quality'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $RunsTable createAlias(String alias) {
    return $RunsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RunType, String, String> $convertertype =
      const EnumNameConverter<RunType>(RunType.values);
  static JsonTypeConverter2<RunStatus, String, String> $converterstatus =
      const EnumNameConverter<RunStatus>(RunStatus.values);
  static JsonTypeConverter2<GpsQuality, String, String> $convertergpsQuality =
      const EnumNameConverter<GpsQuality>(GpsQuality.values);
}

class Run extends DataClass implements Insertable<Run> {
  final int id;
  final RunType type;
  final RunStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int elapsedMs;
  final int movingMs;
  final double distanceM;
  final double avgSpeedMps;
  final double maxSpeedMps;
  final double? kcal;
  final double? elevGainM;
  final int? sprintTimeMs;
  final double? targetDistanceM;
  final GpsQuality gpsQuality;
  final String? note;
  const Run({
    required this.id,
    required this.type,
    required this.status,
    required this.startedAt,
    this.endedAt,
    required this.elapsedMs,
    required this.movingMs,
    required this.distanceM,
    required this.avgSpeedMps,
    required this.maxSpeedMps,
    this.kcal,
    this.elevGainM,
    this.sprintTimeMs,
    this.targetDistanceM,
    required this.gpsQuality,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<String>($RunsTable.$convertertype.toSql(type));
    }
    {
      map['status'] = Variable<String>(
        $RunsTable.$converterstatus.toSql(status),
      );
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    map['moving_ms'] = Variable<int>(movingMs);
    map['distance_m'] = Variable<double>(distanceM);
    map['avg_speed_mps'] = Variable<double>(avgSpeedMps);
    map['max_speed_mps'] = Variable<double>(maxSpeedMps);
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<double>(kcal);
    }
    if (!nullToAbsent || elevGainM != null) {
      map['elev_gain_m'] = Variable<double>(elevGainM);
    }
    if (!nullToAbsent || sprintTimeMs != null) {
      map['sprint_time_ms'] = Variable<int>(sprintTimeMs);
    }
    if (!nullToAbsent || targetDistanceM != null) {
      map['target_distance_m'] = Variable<double>(targetDistanceM);
    }
    {
      map['gps_quality'] = Variable<String>(
        $RunsTable.$convertergpsQuality.toSql(gpsQuality),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  RunsCompanion toCompanion(bool nullToAbsent) {
    return RunsCompanion(
      id: Value(id),
      type: Value(type),
      status: Value(status),
      startedAt: Value(startedAt),
      endedAt:
          endedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(endedAt),
      elapsedMs: Value(elapsedMs),
      movingMs: Value(movingMs),
      distanceM: Value(distanceM),
      avgSpeedMps: Value(avgSpeedMps),
      maxSpeedMps: Value(maxSpeedMps),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      elevGainM:
          elevGainM == null && nullToAbsent
              ? const Value.absent()
              : Value(elevGainM),
      sprintTimeMs:
          sprintTimeMs == null && nullToAbsent
              ? const Value.absent()
              : Value(sprintTimeMs),
      targetDistanceM:
          targetDistanceM == null && nullToAbsent
              ? const Value.absent()
              : Value(targetDistanceM),
      gpsQuality: Value(gpsQuality),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Run.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Run(
      id: serializer.fromJson<int>(json['id']),
      type: $RunsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      status: $RunsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      movingMs: serializer.fromJson<int>(json['movingMs']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      avgSpeedMps: serializer.fromJson<double>(json['avgSpeedMps']),
      maxSpeedMps: serializer.fromJson<double>(json['maxSpeedMps']),
      kcal: serializer.fromJson<double?>(json['kcal']),
      elevGainM: serializer.fromJson<double?>(json['elevGainM']),
      sprintTimeMs: serializer.fromJson<int?>(json['sprintTimeMs']),
      targetDistanceM: serializer.fromJson<double?>(json['targetDistanceM']),
      gpsQuality: $RunsTable.$convertergpsQuality.fromJson(
        serializer.fromJson<String>(json['gpsQuality']),
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>($RunsTable.$convertertype.toJson(type)),
      'status': serializer.toJson<String>(
        $RunsTable.$converterstatus.toJson(status),
      ),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'movingMs': serializer.toJson<int>(movingMs),
      'distanceM': serializer.toJson<double>(distanceM),
      'avgSpeedMps': serializer.toJson<double>(avgSpeedMps),
      'maxSpeedMps': serializer.toJson<double>(maxSpeedMps),
      'kcal': serializer.toJson<double?>(kcal),
      'elevGainM': serializer.toJson<double?>(elevGainM),
      'sprintTimeMs': serializer.toJson<int?>(sprintTimeMs),
      'targetDistanceM': serializer.toJson<double?>(targetDistanceM),
      'gpsQuality': serializer.toJson<String>(
        $RunsTable.$convertergpsQuality.toJson(gpsQuality),
      ),
      'note': serializer.toJson<String?>(note),
    };
  }

  Run copyWith({
    int? id,
    RunType? type,
    RunStatus? status,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? elapsedMs,
    int? movingMs,
    double? distanceM,
    double? avgSpeedMps,
    double? maxSpeedMps,
    Value<double?> kcal = const Value.absent(),
    Value<double?> elevGainM = const Value.absent(),
    Value<int?> sprintTimeMs = const Value.absent(),
    Value<double?> targetDistanceM = const Value.absent(),
    GpsQuality? gpsQuality,
    Value<String?> note = const Value.absent(),
  }) => Run(
    id: id ?? this.id,
    type: type ?? this.type,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    movingMs: movingMs ?? this.movingMs,
    distanceM: distanceM ?? this.distanceM,
    avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
    maxSpeedMps: maxSpeedMps ?? this.maxSpeedMps,
    kcal: kcal.present ? kcal.value : this.kcal,
    elevGainM: elevGainM.present ? elevGainM.value : this.elevGainM,
    sprintTimeMs: sprintTimeMs.present ? sprintTimeMs.value : this.sprintTimeMs,
    targetDistanceM:
        targetDistanceM.present ? targetDistanceM.value : this.targetDistanceM,
    gpsQuality: gpsQuality ?? this.gpsQuality,
    note: note.present ? note.value : this.note,
  );
  Run copyWithCompanion(RunsCompanion data) {
    return Run(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      movingMs: data.movingMs.present ? data.movingMs.value : this.movingMs,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      avgSpeedMps:
          data.avgSpeedMps.present ? data.avgSpeedMps.value : this.avgSpeedMps,
      maxSpeedMps:
          data.maxSpeedMps.present ? data.maxSpeedMps.value : this.maxSpeedMps,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      elevGainM: data.elevGainM.present ? data.elevGainM.value : this.elevGainM,
      sprintTimeMs:
          data.sprintTimeMs.present
              ? data.sprintTimeMs.value
              : this.sprintTimeMs,
      targetDistanceM:
          data.targetDistanceM.present
              ? data.targetDistanceM.value
              : this.targetDistanceM,
      gpsQuality:
          data.gpsQuality.present ? data.gpsQuality.value : this.gpsQuality,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Run(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('movingMs: $movingMs, ')
          ..write('distanceM: $distanceM, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('maxSpeedMps: $maxSpeedMps, ')
          ..write('kcal: $kcal, ')
          ..write('elevGainM: $elevGainM, ')
          ..write('sprintTimeMs: $sprintTimeMs, ')
          ..write('targetDistanceM: $targetDistanceM, ')
          ..write('gpsQuality: $gpsQuality, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    status,
    startedAt,
    endedAt,
    elapsedMs,
    movingMs,
    distanceM,
    avgSpeedMps,
    maxSpeedMps,
    kcal,
    elevGainM,
    sprintTimeMs,
    targetDistanceM,
    gpsQuality,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Run &&
          other.id == this.id &&
          other.type == this.type &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.elapsedMs == this.elapsedMs &&
          other.movingMs == this.movingMs &&
          other.distanceM == this.distanceM &&
          other.avgSpeedMps == this.avgSpeedMps &&
          other.maxSpeedMps == this.maxSpeedMps &&
          other.kcal == this.kcal &&
          other.elevGainM == this.elevGainM &&
          other.sprintTimeMs == this.sprintTimeMs &&
          other.targetDistanceM == this.targetDistanceM &&
          other.gpsQuality == this.gpsQuality &&
          other.note == this.note);
}

class RunsCompanion extends UpdateCompanion<Run> {
  final Value<int> id;
  final Value<RunType> type;
  final Value<RunStatus> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> elapsedMs;
  final Value<int> movingMs;
  final Value<double> distanceM;
  final Value<double> avgSpeedMps;
  final Value<double> maxSpeedMps;
  final Value<double?> kcal;
  final Value<double?> elevGainM;
  final Value<int?> sprintTimeMs;
  final Value<double?> targetDistanceM;
  final Value<GpsQuality> gpsQuality;
  final Value<String?> note;
  const RunsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.movingMs = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.avgSpeedMps = const Value.absent(),
    this.maxSpeedMps = const Value.absent(),
    this.kcal = const Value.absent(),
    this.elevGainM = const Value.absent(),
    this.sprintTimeMs = const Value.absent(),
    this.targetDistanceM = const Value.absent(),
    this.gpsQuality = const Value.absent(),
    this.note = const Value.absent(),
  });
  RunsCompanion.insert({
    this.id = const Value.absent(),
    required RunType type,
    required RunStatus status,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.movingMs = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.avgSpeedMps = const Value.absent(),
    this.maxSpeedMps = const Value.absent(),
    this.kcal = const Value.absent(),
    this.elevGainM = const Value.absent(),
    this.sprintTimeMs = const Value.absent(),
    this.targetDistanceM = const Value.absent(),
    required GpsQuality gpsQuality,
    this.note = const Value.absent(),
  }) : type = Value(type),
       status = Value(status),
       startedAt = Value(startedAt),
       gpsQuality = Value(gpsQuality);
  static Insertable<Run> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? elapsedMs,
    Expression<int>? movingMs,
    Expression<double>? distanceM,
    Expression<double>? avgSpeedMps,
    Expression<double>? maxSpeedMps,
    Expression<double>? kcal,
    Expression<double>? elevGainM,
    Expression<int>? sprintTimeMs,
    Expression<double>? targetDistanceM,
    Expression<String>? gpsQuality,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (movingMs != null) 'moving_ms': movingMs,
      if (distanceM != null) 'distance_m': distanceM,
      if (avgSpeedMps != null) 'avg_speed_mps': avgSpeedMps,
      if (maxSpeedMps != null) 'max_speed_mps': maxSpeedMps,
      if (kcal != null) 'kcal': kcal,
      if (elevGainM != null) 'elev_gain_m': elevGainM,
      if (sprintTimeMs != null) 'sprint_time_ms': sprintTimeMs,
      if (targetDistanceM != null) 'target_distance_m': targetDistanceM,
      if (gpsQuality != null) 'gps_quality': gpsQuality,
      if (note != null) 'note': note,
    });
  }

  RunsCompanion copyWith({
    Value<int>? id,
    Value<RunType>? type,
    Value<RunStatus>? status,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? elapsedMs,
    Value<int>? movingMs,
    Value<double>? distanceM,
    Value<double>? avgSpeedMps,
    Value<double>? maxSpeedMps,
    Value<double?>? kcal,
    Value<double?>? elevGainM,
    Value<int?>? sprintTimeMs,
    Value<double?>? targetDistanceM,
    Value<GpsQuality>? gpsQuality,
    Value<String?>? note,
  }) {
    return RunsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      movingMs: movingMs ?? this.movingMs,
      distanceM: distanceM ?? this.distanceM,
      avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
      maxSpeedMps: maxSpeedMps ?? this.maxSpeedMps,
      kcal: kcal ?? this.kcal,
      elevGainM: elevGainM ?? this.elevGainM,
      sprintTimeMs: sprintTimeMs ?? this.sprintTimeMs,
      targetDistanceM: targetDistanceM ?? this.targetDistanceM,
      gpsQuality: gpsQuality ?? this.gpsQuality,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $RunsTable.$convertertype.toSql(type.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $RunsTable.$converterstatus.toSql(status.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (movingMs.present) {
      map['moving_ms'] = Variable<int>(movingMs.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (avgSpeedMps.present) {
      map['avg_speed_mps'] = Variable<double>(avgSpeedMps.value);
    }
    if (maxSpeedMps.present) {
      map['max_speed_mps'] = Variable<double>(maxSpeedMps.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (elevGainM.present) {
      map['elev_gain_m'] = Variable<double>(elevGainM.value);
    }
    if (sprintTimeMs.present) {
      map['sprint_time_ms'] = Variable<int>(sprintTimeMs.value);
    }
    if (targetDistanceM.present) {
      map['target_distance_m'] = Variable<double>(targetDistanceM.value);
    }
    if (gpsQuality.present) {
      map['gps_quality'] = Variable<String>(
        $RunsTable.$convertergpsQuality.toSql(gpsQuality.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('movingMs: $movingMs, ')
          ..write('distanceM: $distanceM, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('maxSpeedMps: $maxSpeedMps, ')
          ..write('kcal: $kcal, ')
          ..write('elevGainM: $elevGainM, ')
          ..write('sprintTimeMs: $sprintTimeMs, ')
          ..write('targetDistanceM: $targetDistanceM, ')
          ..write('gpsQuality: $gpsQuality, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $TrackPointsTable extends TrackPoints
    with TableInfo<$TrackPointsTable, TrackPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES runs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tMsMeta = const VerificationMeta('tMs');
  @override
  late final GeneratedColumn<int> tMs = GeneratedColumn<int>(
    't_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedMpsMeta = const VerificationMeta(
    'speedMps',
  );
  @override
  late final GeneratedColumn<double> speedMps = GeneratedColumn<double>(
    'speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedAccMpsMeta = const VerificationMeta(
    'speedAccMps',
  );
  @override
  late final GeneratedColumn<double> speedAccMps = GeneratedColumn<double>(
    'speed_acc_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accMMeta = const VerificationMeta('accM');
  @override
  late final GeneratedColumn<double> accM = GeneratedColumn<double>(
    'acc_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altMMeta = const VerificationMeta('altM');
  @override
  late final GeneratedColumn<double> altM = GeneratedColumn<double>(
    'alt_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _segmentMeta = const VerificationMeta(
    'segment',
  );
  @override
  late final GeneratedColumn<int> segment = GeneratedColumn<int>(
    'segment',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    seq,
    tMs,
    lat,
    lon,
    speedMps,
    speedAccMps,
    accM,
    altM,
    segment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('t_ms')) {
      context.handle(
        _tMsMeta,
        tMs.isAcceptableOrUnknown(data['t_ms']!, _tMsMeta),
      );
    } else if (isInserting) {
      context.missing(_tMsMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('speed_mps')) {
      context.handle(
        _speedMpsMeta,
        speedMps.isAcceptableOrUnknown(data['speed_mps']!, _speedMpsMeta),
      );
    } else if (isInserting) {
      context.missing(_speedMpsMeta);
    }
    if (data.containsKey('speed_acc_mps')) {
      context.handle(
        _speedAccMpsMeta,
        speedAccMps.isAcceptableOrUnknown(
          data['speed_acc_mps']!,
          _speedAccMpsMeta,
        ),
      );
    }
    if (data.containsKey('acc_m')) {
      context.handle(
        _accMMeta,
        accM.isAcceptableOrUnknown(data['acc_m']!, _accMMeta),
      );
    } else if (isInserting) {
      context.missing(_accMMeta);
    }
    if (data.containsKey('alt_m')) {
      context.handle(
        _altMMeta,
        altM.isAcceptableOrUnknown(data['alt_m']!, _altMMeta),
      );
    }
    if (data.containsKey('segment')) {
      context.handle(
        _segmentMeta,
        segment.isAcceptableOrUnknown(data['segment']!, _segmentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackPoint(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      runId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}run_id'],
          )!,
      seq:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}seq'],
          )!,
      tMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}t_ms'],
          )!,
      lat:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}lat'],
          )!,
      lon:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}lon'],
          )!,
      speedMps:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}speed_mps'],
          )!,
      speedAccMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_acc_mps'],
      ),
      accM:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}acc_m'],
          )!,
      altM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}alt_m'],
      ),
      segment:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}segment'],
          )!,
    );
  }

  @override
  $TrackPointsTable createAlias(String alias) {
    return $TrackPointsTable(attachedDatabase, alias);
  }
}

class TrackPoint extends DataClass implements Insertable<TrackPoint> {
  final int id;
  final int runId;
  final int seq;
  final int tMs;
  final double lat;
  final double lon;
  final double speedMps;
  final double? speedAccMps;
  final double accM;
  final double? altM;
  final int segment;
  const TrackPoint({
    required this.id,
    required this.runId,
    required this.seq,
    required this.tMs,
    required this.lat,
    required this.lon,
    required this.speedMps,
    this.speedAccMps,
    required this.accM,
    this.altM,
    required this.segment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['run_id'] = Variable<int>(runId);
    map['seq'] = Variable<int>(seq);
    map['t_ms'] = Variable<int>(tMs);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['speed_mps'] = Variable<double>(speedMps);
    if (!nullToAbsent || speedAccMps != null) {
      map['speed_acc_mps'] = Variable<double>(speedAccMps);
    }
    map['acc_m'] = Variable<double>(accM);
    if (!nullToAbsent || altM != null) {
      map['alt_m'] = Variable<double>(altM);
    }
    map['segment'] = Variable<int>(segment);
    return map;
  }

  TrackPointsCompanion toCompanion(bool nullToAbsent) {
    return TrackPointsCompanion(
      id: Value(id),
      runId: Value(runId),
      seq: Value(seq),
      tMs: Value(tMs),
      lat: Value(lat),
      lon: Value(lon),
      speedMps: Value(speedMps),
      speedAccMps:
          speedAccMps == null && nullToAbsent
              ? const Value.absent()
              : Value(speedAccMps),
      accM: Value(accM),
      altM: altM == null && nullToAbsent ? const Value.absent() : Value(altM),
      segment: Value(segment),
    );
  }

  factory TrackPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackPoint(
      id: serializer.fromJson<int>(json['id']),
      runId: serializer.fromJson<int>(json['runId']),
      seq: serializer.fromJson<int>(json['seq']),
      tMs: serializer.fromJson<int>(json['tMs']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      speedMps: serializer.fromJson<double>(json['speedMps']),
      speedAccMps: serializer.fromJson<double?>(json['speedAccMps']),
      accM: serializer.fromJson<double>(json['accM']),
      altM: serializer.fromJson<double?>(json['altM']),
      segment: serializer.fromJson<int>(json['segment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runId': serializer.toJson<int>(runId),
      'seq': serializer.toJson<int>(seq),
      'tMs': serializer.toJson<int>(tMs),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'speedMps': serializer.toJson<double>(speedMps),
      'speedAccMps': serializer.toJson<double?>(speedAccMps),
      'accM': serializer.toJson<double>(accM),
      'altM': serializer.toJson<double?>(altM),
      'segment': serializer.toJson<int>(segment),
    };
  }

  TrackPoint copyWith({
    int? id,
    int? runId,
    int? seq,
    int? tMs,
    double? lat,
    double? lon,
    double? speedMps,
    Value<double?> speedAccMps = const Value.absent(),
    double? accM,
    Value<double?> altM = const Value.absent(),
    int? segment,
  }) => TrackPoint(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    seq: seq ?? this.seq,
    tMs: tMs ?? this.tMs,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    speedMps: speedMps ?? this.speedMps,
    speedAccMps: speedAccMps.present ? speedAccMps.value : this.speedAccMps,
    accM: accM ?? this.accM,
    altM: altM.present ? altM.value : this.altM,
    segment: segment ?? this.segment,
  );
  TrackPoint copyWithCompanion(TrackPointsCompanion data) {
    return TrackPoint(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      seq: data.seq.present ? data.seq.value : this.seq,
      tMs: data.tMs.present ? data.tMs.value : this.tMs,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      speedMps: data.speedMps.present ? data.speedMps.value : this.speedMps,
      speedAccMps:
          data.speedAccMps.present ? data.speedAccMps.value : this.speedAccMps,
      accM: data.accM.present ? data.accM.value : this.accM,
      altM: data.altM.present ? data.altM.value : this.altM,
      segment: data.segment.present ? data.segment.value : this.segment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackPoint(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('seq: $seq, ')
          ..write('tMs: $tMs, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('speedMps: $speedMps, ')
          ..write('speedAccMps: $speedAccMps, ')
          ..write('accM: $accM, ')
          ..write('altM: $altM, ')
          ..write('segment: $segment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    runId,
    seq,
    tMs,
    lat,
    lon,
    speedMps,
    speedAccMps,
    accM,
    altM,
    segment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackPoint &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.seq == this.seq &&
          other.tMs == this.tMs &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.speedMps == this.speedMps &&
          other.speedAccMps == this.speedAccMps &&
          other.accM == this.accM &&
          other.altM == this.altM &&
          other.segment == this.segment);
}

class TrackPointsCompanion extends UpdateCompanion<TrackPoint> {
  final Value<int> id;
  final Value<int> runId;
  final Value<int> seq;
  final Value<int> tMs;
  final Value<double> lat;
  final Value<double> lon;
  final Value<double> speedMps;
  final Value<double?> speedAccMps;
  final Value<double> accM;
  final Value<double?> altM;
  final Value<int> segment;
  const TrackPointsCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.seq = const Value.absent(),
    this.tMs = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.speedMps = const Value.absent(),
    this.speedAccMps = const Value.absent(),
    this.accM = const Value.absent(),
    this.altM = const Value.absent(),
    this.segment = const Value.absent(),
  });
  TrackPointsCompanion.insert({
    this.id = const Value.absent(),
    required int runId,
    required int seq,
    required int tMs,
    required double lat,
    required double lon,
    required double speedMps,
    this.speedAccMps = const Value.absent(),
    required double accM,
    this.altM = const Value.absent(),
    this.segment = const Value.absent(),
  }) : runId = Value(runId),
       seq = Value(seq),
       tMs = Value(tMs),
       lat = Value(lat),
       lon = Value(lon),
       speedMps = Value(speedMps),
       accM = Value(accM);
  static Insertable<TrackPoint> custom({
    Expression<int>? id,
    Expression<int>? runId,
    Expression<int>? seq,
    Expression<int>? tMs,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<double>? speedMps,
    Expression<double>? speedAccMps,
    Expression<double>? accM,
    Expression<double>? altM,
    Expression<int>? segment,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (seq != null) 'seq': seq,
      if (tMs != null) 't_ms': tMs,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (speedMps != null) 'speed_mps': speedMps,
      if (speedAccMps != null) 'speed_acc_mps': speedAccMps,
      if (accM != null) 'acc_m': accM,
      if (altM != null) 'alt_m': altM,
      if (segment != null) 'segment': segment,
    });
  }

  TrackPointsCompanion copyWith({
    Value<int>? id,
    Value<int>? runId,
    Value<int>? seq,
    Value<int>? tMs,
    Value<double>? lat,
    Value<double>? lon,
    Value<double>? speedMps,
    Value<double?>? speedAccMps,
    Value<double>? accM,
    Value<double?>? altM,
    Value<int>? segment,
  }) {
    return TrackPointsCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      seq: seq ?? this.seq,
      tMs: tMs ?? this.tMs,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      speedMps: speedMps ?? this.speedMps,
      speedAccMps: speedAccMps ?? this.speedAccMps,
      accM: accM ?? this.accM,
      altM: altM ?? this.altM,
      segment: segment ?? this.segment,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (tMs.present) {
      map['t_ms'] = Variable<int>(tMs.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (speedMps.present) {
      map['speed_mps'] = Variable<double>(speedMps.value);
    }
    if (speedAccMps.present) {
      map['speed_acc_mps'] = Variable<double>(speedAccMps.value);
    }
    if (accM.present) {
      map['acc_m'] = Variable<double>(accM.value);
    }
    if (altM.present) {
      map['alt_m'] = Variable<double>(altM.value);
    }
    if (segment.present) {
      map['segment'] = Variable<int>(segment.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackPointsCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('seq: $seq, ')
          ..write('tMs: $tMs, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('speedMps: $speedMps, ')
          ..write('speedAccMps: $speedAccMps, ')
          ..write('accM: $accM, ')
          ..write('altM: $altM, ')
          ..write('segment: $segment')
          ..write(')'))
        .toString();
  }
}

class $SplitsTable extends Splits with TableInfo<$SplitsTable, Split> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SplitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES runs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgSpeedMpsMeta = const VerificationMeta(
    'avgSpeedMps',
  );
  @override
  late final GeneratedColumn<double> avgSpeedMps = GeneratedColumn<double>(
    'avg_speed_mps',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elevDeltaMMeta = const VerificationMeta(
    'elevDeltaM',
  );
  @override
  late final GeneratedColumn<double> elevDeltaM = GeneratedColumn<double>(
    'elev_delta_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    runId,
    idx,
    distanceM,
    durationMs,
    avgSpeedMps,
    elevDeltaM,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'splits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Split> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    } else if (isInserting) {
      context.missing(_idxMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceMMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('avg_speed_mps')) {
      context.handle(
        _avgSpeedMpsMeta,
        avgSpeedMps.isAcceptableOrUnknown(
          data['avg_speed_mps']!,
          _avgSpeedMpsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgSpeedMpsMeta);
    }
    if (data.containsKey('elev_delta_m')) {
      context.handle(
        _elevDeltaMMeta,
        elevDeltaM.isAcceptableOrUnknown(
          data['elev_delta_m']!,
          _elevDeltaMMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId, idx};
  @override
  Split map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Split(
      runId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}run_id'],
          )!,
      idx:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}idx'],
          )!,
      distanceM:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}distance_m'],
          )!,
      durationMs:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}duration_ms'],
          )!,
      avgSpeedMps:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}avg_speed_mps'],
          )!,
      elevDeltaM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elev_delta_m'],
      ),
    );
  }

  @override
  $SplitsTable createAlias(String alias) {
    return $SplitsTable(attachedDatabase, alias);
  }
}

class Split extends DataClass implements Insertable<Split> {
  final int runId;
  final int idx;
  final double distanceM;
  final int durationMs;
  final double avgSpeedMps;
  final double? elevDeltaM;
  const Split({
    required this.runId,
    required this.idx,
    required this.distanceM,
    required this.durationMs,
    required this.avgSpeedMps,
    this.elevDeltaM,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<int>(runId);
    map['idx'] = Variable<int>(idx);
    map['distance_m'] = Variable<double>(distanceM);
    map['duration_ms'] = Variable<int>(durationMs);
    map['avg_speed_mps'] = Variable<double>(avgSpeedMps);
    if (!nullToAbsent || elevDeltaM != null) {
      map['elev_delta_m'] = Variable<double>(elevDeltaM);
    }
    return map;
  }

  SplitsCompanion toCompanion(bool nullToAbsent) {
    return SplitsCompanion(
      runId: Value(runId),
      idx: Value(idx),
      distanceM: Value(distanceM),
      durationMs: Value(durationMs),
      avgSpeedMps: Value(avgSpeedMps),
      elevDeltaM:
          elevDeltaM == null && nullToAbsent
              ? const Value.absent()
              : Value(elevDeltaM),
    );
  }

  factory Split.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Split(
      runId: serializer.fromJson<int>(json['runId']),
      idx: serializer.fromJson<int>(json['idx']),
      distanceM: serializer.fromJson<double>(json['distanceM']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      avgSpeedMps: serializer.fromJson<double>(json['avgSpeedMps']),
      elevDeltaM: serializer.fromJson<double?>(json['elevDeltaM']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<int>(runId),
      'idx': serializer.toJson<int>(idx),
      'distanceM': serializer.toJson<double>(distanceM),
      'durationMs': serializer.toJson<int>(durationMs),
      'avgSpeedMps': serializer.toJson<double>(avgSpeedMps),
      'elevDeltaM': serializer.toJson<double?>(elevDeltaM),
    };
  }

  Split copyWith({
    int? runId,
    int? idx,
    double? distanceM,
    int? durationMs,
    double? avgSpeedMps,
    Value<double?> elevDeltaM = const Value.absent(),
  }) => Split(
    runId: runId ?? this.runId,
    idx: idx ?? this.idx,
    distanceM: distanceM ?? this.distanceM,
    durationMs: durationMs ?? this.durationMs,
    avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
    elevDeltaM: elevDeltaM.present ? elevDeltaM.value : this.elevDeltaM,
  );
  Split copyWithCompanion(SplitsCompanion data) {
    return Split(
      runId: data.runId.present ? data.runId.value : this.runId,
      idx: data.idx.present ? data.idx.value : this.idx,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      avgSpeedMps:
          data.avgSpeedMps.present ? data.avgSpeedMps.value : this.avgSpeedMps,
      elevDeltaM:
          data.elevDeltaM.present ? data.elevDeltaM.value : this.elevDeltaM,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Split(')
          ..write('runId: $runId, ')
          ..write('idx: $idx, ')
          ..write('distanceM: $distanceM, ')
          ..write('durationMs: $durationMs, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('elevDeltaM: $elevDeltaM')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(runId, idx, distanceM, durationMs, avgSpeedMps, elevDeltaM);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Split &&
          other.runId == this.runId &&
          other.idx == this.idx &&
          other.distanceM == this.distanceM &&
          other.durationMs == this.durationMs &&
          other.avgSpeedMps == this.avgSpeedMps &&
          other.elevDeltaM == this.elevDeltaM);
}

class SplitsCompanion extends UpdateCompanion<Split> {
  final Value<int> runId;
  final Value<int> idx;
  final Value<double> distanceM;
  final Value<int> durationMs;
  final Value<double> avgSpeedMps;
  final Value<double?> elevDeltaM;
  final Value<int> rowid;
  const SplitsCompanion({
    this.runId = const Value.absent(),
    this.idx = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.avgSpeedMps = const Value.absent(),
    this.elevDeltaM = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SplitsCompanion.insert({
    required int runId,
    required int idx,
    required double distanceM,
    required int durationMs,
    required double avgSpeedMps,
    this.elevDeltaM = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : runId = Value(runId),
       idx = Value(idx),
       distanceM = Value(distanceM),
       durationMs = Value(durationMs),
       avgSpeedMps = Value(avgSpeedMps);
  static Insertable<Split> custom({
    Expression<int>? runId,
    Expression<int>? idx,
    Expression<double>? distanceM,
    Expression<int>? durationMs,
    Expression<double>? avgSpeedMps,
    Expression<double>? elevDeltaM,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (idx != null) 'idx': idx,
      if (distanceM != null) 'distance_m': distanceM,
      if (durationMs != null) 'duration_ms': durationMs,
      if (avgSpeedMps != null) 'avg_speed_mps': avgSpeedMps,
      if (elevDeltaM != null) 'elev_delta_m': elevDeltaM,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SplitsCompanion copyWith({
    Value<int>? runId,
    Value<int>? idx,
    Value<double>? distanceM,
    Value<int>? durationMs,
    Value<double>? avgSpeedMps,
    Value<double?>? elevDeltaM,
    Value<int>? rowid,
  }) {
    return SplitsCompanion(
      runId: runId ?? this.runId,
      idx: idx ?? this.idx,
      distanceM: distanceM ?? this.distanceM,
      durationMs: durationMs ?? this.durationMs,
      avgSpeedMps: avgSpeedMps ?? this.avgSpeedMps,
      elevDeltaM: elevDeltaM ?? this.elevDeltaM,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (avgSpeedMps.present) {
      map['avg_speed_mps'] = Variable<double>(avgSpeedMps.value);
    }
    if (elevDeltaM.present) {
      map['elev_delta_m'] = Variable<double>(elevDeltaM.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SplitsCompanion(')
          ..write('runId: $runId, ')
          ..write('idx: $idx, ')
          ..write('distanceM: $distanceM, ')
          ..write('durationMs: $durationMs, ')
          ..write('avgSpeedMps: $avgSpeedMps, ')
          ..write('elevDeltaM: $elevDeltaM, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BestEffortsTable extends BestEfforts
    with TableInfo<$BestEffortsTable, BestEffort> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BestEffortsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<int> runId = GeneratedColumn<int>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES runs (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<EffortKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EffortKind>($BestEffortsTable.$converterkind);
  static const VerificationMeta _valueMsMeta = const VerificationMeta(
    'valueMs',
  );
  @override
  late final GeneratedColumn<int> valueMs = GeneratedColumn<int>(
    'value_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMpsMeta = const VerificationMeta(
    'valueMps',
  );
  @override
  late final GeneratedColumn<double> valueMps = GeneratedColumn<double>(
    'value_mps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueMMeta = const VerificationMeta('valueM');
  @override
  late final GeneratedColumn<double> valueM = GeneratedColumn<double>(
    'value_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startSeqMeta = const VerificationMeta(
    'startSeq',
  );
  @override
  late final GeneratedColumn<int> startSeq = GeneratedColumn<int>(
    'start_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endSeqMeta = const VerificationMeta('endSeq');
  @override
  late final GeneratedColumn<int> endSeq = GeneratedColumn<int>(
    'end_seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    runId,
    kind,
    valueMs,
    valueMps,
    valueM,
    startSeq,
    endSeq,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'best_efforts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BestEffort> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('value_ms')) {
      context.handle(
        _valueMsMeta,
        valueMs.isAcceptableOrUnknown(data['value_ms']!, _valueMsMeta),
      );
    }
    if (data.containsKey('value_mps')) {
      context.handle(
        _valueMpsMeta,
        valueMps.isAcceptableOrUnknown(data['value_mps']!, _valueMpsMeta),
      );
    }
    if (data.containsKey('value_m')) {
      context.handle(
        _valueMMeta,
        valueM.isAcceptableOrUnknown(data['value_m']!, _valueMMeta),
      );
    }
    if (data.containsKey('start_seq')) {
      context.handle(
        _startSeqMeta,
        startSeq.isAcceptableOrUnknown(data['start_seq']!, _startSeqMeta),
      );
    }
    if (data.containsKey('end_seq')) {
      context.handle(
        _endSeqMeta,
        endSeq.isAcceptableOrUnknown(data['end_seq']!, _endSeqMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BestEffort map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BestEffort(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      runId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}run_id'],
          )!,
      kind: $BestEffortsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      valueMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_ms'],
      ),
      valueMps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_mps'],
      ),
      valueM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value_m'],
      ),
      startSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_seq'],
      ),
      endSeq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_seq'],
      ),
    );
  }

  @override
  $BestEffortsTable createAlias(String alias) {
    return $BestEffortsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EffortKind, String, String> $converterkind =
      const EnumNameConverter<EffortKind>(EffortKind.values);
}

class BestEffort extends DataClass implements Insertable<BestEffort> {
  final int id;
  final int runId;
  final EffortKind kind;
  final int? valueMs;
  final double? valueMps;
  final double? valueM;
  final int? startSeq;
  final int? endSeq;
  const BestEffort({
    required this.id,
    required this.runId,
    required this.kind,
    this.valueMs,
    this.valueMps,
    this.valueM,
    this.startSeq,
    this.endSeq,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['run_id'] = Variable<int>(runId);
    {
      map['kind'] = Variable<String>(
        $BestEffortsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || valueMs != null) {
      map['value_ms'] = Variable<int>(valueMs);
    }
    if (!nullToAbsent || valueMps != null) {
      map['value_mps'] = Variable<double>(valueMps);
    }
    if (!nullToAbsent || valueM != null) {
      map['value_m'] = Variable<double>(valueM);
    }
    if (!nullToAbsent || startSeq != null) {
      map['start_seq'] = Variable<int>(startSeq);
    }
    if (!nullToAbsent || endSeq != null) {
      map['end_seq'] = Variable<int>(endSeq);
    }
    return map;
  }

  BestEffortsCompanion toCompanion(bool nullToAbsent) {
    return BestEffortsCompanion(
      id: Value(id),
      runId: Value(runId),
      kind: Value(kind),
      valueMs:
          valueMs == null && nullToAbsent
              ? const Value.absent()
              : Value(valueMs),
      valueMps:
          valueMps == null && nullToAbsent
              ? const Value.absent()
              : Value(valueMps),
      valueM:
          valueM == null && nullToAbsent ? const Value.absent() : Value(valueM),
      startSeq:
          startSeq == null && nullToAbsent
              ? const Value.absent()
              : Value(startSeq),
      endSeq:
          endSeq == null && nullToAbsent ? const Value.absent() : Value(endSeq),
    );
  }

  factory BestEffort.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BestEffort(
      id: serializer.fromJson<int>(json['id']),
      runId: serializer.fromJson<int>(json['runId']),
      kind: $BestEffortsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      valueMs: serializer.fromJson<int?>(json['valueMs']),
      valueMps: serializer.fromJson<double?>(json['valueMps']),
      valueM: serializer.fromJson<double?>(json['valueM']),
      startSeq: serializer.fromJson<int?>(json['startSeq']),
      endSeq: serializer.fromJson<int?>(json['endSeq']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'runId': serializer.toJson<int>(runId),
      'kind': serializer.toJson<String>(
        $BestEffortsTable.$converterkind.toJson(kind),
      ),
      'valueMs': serializer.toJson<int?>(valueMs),
      'valueMps': serializer.toJson<double?>(valueMps),
      'valueM': serializer.toJson<double?>(valueM),
      'startSeq': serializer.toJson<int?>(startSeq),
      'endSeq': serializer.toJson<int?>(endSeq),
    };
  }

  BestEffort copyWith({
    int? id,
    int? runId,
    EffortKind? kind,
    Value<int?> valueMs = const Value.absent(),
    Value<double?> valueMps = const Value.absent(),
    Value<double?> valueM = const Value.absent(),
    Value<int?> startSeq = const Value.absent(),
    Value<int?> endSeq = const Value.absent(),
  }) => BestEffort(
    id: id ?? this.id,
    runId: runId ?? this.runId,
    kind: kind ?? this.kind,
    valueMs: valueMs.present ? valueMs.value : this.valueMs,
    valueMps: valueMps.present ? valueMps.value : this.valueMps,
    valueM: valueM.present ? valueM.value : this.valueM,
    startSeq: startSeq.present ? startSeq.value : this.startSeq,
    endSeq: endSeq.present ? endSeq.value : this.endSeq,
  );
  BestEffort copyWithCompanion(BestEffortsCompanion data) {
    return BestEffort(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      kind: data.kind.present ? data.kind.value : this.kind,
      valueMs: data.valueMs.present ? data.valueMs.value : this.valueMs,
      valueMps: data.valueMps.present ? data.valueMps.value : this.valueMps,
      valueM: data.valueM.present ? data.valueM.value : this.valueM,
      startSeq: data.startSeq.present ? data.startSeq.value : this.startSeq,
      endSeq: data.endSeq.present ? data.endSeq.value : this.endSeq,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BestEffort(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('kind: $kind, ')
          ..write('valueMs: $valueMs, ')
          ..write('valueMps: $valueMps, ')
          ..write('valueM: $valueM, ')
          ..write('startSeq: $startSeq, ')
          ..write('endSeq: $endSeq')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, runId, kind, valueMs, valueMps, valueM, startSeq, endSeq);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BestEffort &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.kind == this.kind &&
          other.valueMs == this.valueMs &&
          other.valueMps == this.valueMps &&
          other.valueM == this.valueM &&
          other.startSeq == this.startSeq &&
          other.endSeq == this.endSeq);
}

class BestEffortsCompanion extends UpdateCompanion<BestEffort> {
  final Value<int> id;
  final Value<int> runId;
  final Value<EffortKind> kind;
  final Value<int?> valueMs;
  final Value<double?> valueMps;
  final Value<double?> valueM;
  final Value<int?> startSeq;
  final Value<int?> endSeq;
  const BestEffortsCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.kind = const Value.absent(),
    this.valueMs = const Value.absent(),
    this.valueMps = const Value.absent(),
    this.valueM = const Value.absent(),
    this.startSeq = const Value.absent(),
    this.endSeq = const Value.absent(),
  });
  BestEffortsCompanion.insert({
    this.id = const Value.absent(),
    required int runId,
    required EffortKind kind,
    this.valueMs = const Value.absent(),
    this.valueMps = const Value.absent(),
    this.valueM = const Value.absent(),
    this.startSeq = const Value.absent(),
    this.endSeq = const Value.absent(),
  }) : runId = Value(runId),
       kind = Value(kind);
  static Insertable<BestEffort> custom({
    Expression<int>? id,
    Expression<int>? runId,
    Expression<String>? kind,
    Expression<int>? valueMs,
    Expression<double>? valueMps,
    Expression<double>? valueM,
    Expression<int>? startSeq,
    Expression<int>? endSeq,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (kind != null) 'kind': kind,
      if (valueMs != null) 'value_ms': valueMs,
      if (valueMps != null) 'value_mps': valueMps,
      if (valueM != null) 'value_m': valueM,
      if (startSeq != null) 'start_seq': startSeq,
      if (endSeq != null) 'end_seq': endSeq,
    });
  }

  BestEffortsCompanion copyWith({
    Value<int>? id,
    Value<int>? runId,
    Value<EffortKind>? kind,
    Value<int?>? valueMs,
    Value<double?>? valueMps,
    Value<double?>? valueM,
    Value<int?>? startSeq,
    Value<int?>? endSeq,
  }) {
    return BestEffortsCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      kind: kind ?? this.kind,
      valueMs: valueMs ?? this.valueMs,
      valueMps: valueMps ?? this.valueMps,
      valueM: valueM ?? this.valueM,
      startSeq: startSeq ?? this.startSeq,
      endSeq: endSeq ?? this.endSeq,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<int>(runId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $BestEffortsTable.$converterkind.toSql(kind.value),
      );
    }
    if (valueMs.present) {
      map['value_ms'] = Variable<int>(valueMs.value);
    }
    if (valueMps.present) {
      map['value_mps'] = Variable<double>(valueMps.value);
    }
    if (valueM.present) {
      map['value_m'] = Variable<double>(valueM.value);
    }
    if (startSeq.present) {
      map['start_seq'] = Variable<int>(startSeq.value);
    }
    if (endSeq.present) {
      map['end_seq'] = Variable<int>(endSeq.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BestEffortsCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('kind: $kind, ')
          ..write('valueMs: $valueMs, ')
          ..write('valueMps: $valueMps, ')
          ..write('valueM: $valueM, ')
          ..write('startSeq: $startSeq, ')
          ..write('endSeq: $endSeq')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $RunsTable runs = $RunsTable(this);
  late final $TrackPointsTable trackPoints = $TrackPointsTable(this);
  late final $SplitsTable splits = $SplitsTable(this);
  late final $BestEffortsTable bestEfforts = $BestEffortsTable(this);
  late final Index trackPointsRun = Index(
    'track_points_run',
    'CREATE INDEX track_points_run ON track_points (run_id, seq)',
  );
  late final Index bestEffortsKind = Index(
    'best_efforts_kind',
    'CREATE INDEX best_efforts_kind ON best_efforts (kind)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    runs,
    trackPoints,
    splits,
    bestEfforts,
    trackPointsRun,
    bestEffortsKind,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('track_points', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('splits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'runs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('best_efforts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<double?> weightKg,
      Value<int?> heightCm,
      Value<int?> birthYear,
      Value<Sex?> sex,
      Value<bool> useMiles,
      Value<bool> audioCues,
      Value<bool> autoPause,
      Value<bool> onboarded,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<double?> weightKg,
      Value<int?> heightCm,
      Value<int?> birthYear,
      Value<Sex?> sex,
      Value<bool> useMiles,
      Value<bool> audioCues,
      Value<bool> autoPause,
      Value<bool> onboarded,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Sex?, Sex, String> get sex =>
      $composableBuilder(
        column: $table.sex,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get useMiles => $composableBuilder(
    column: $table.useMiles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get audioCues => $composableBuilder(
    column: $table.audioCues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoPause => $composableBuilder(
    column: $table.autoPause,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get useMiles => $composableBuilder(
    column: $table.useMiles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get audioCues => $composableBuilder(
    column: $table.audioCues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoPause => $composableBuilder(
    column: $table.autoPause,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboarded => $composableBuilder(
    column: $table.onboarded,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Sex?, String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<bool> get useMiles =>
      $composableBuilder(column: $table.useMiles, builder: (column) => column);

  GeneratedColumn<bool> get audioCues =>
      $composableBuilder(column: $table.audioCues, builder: (column) => column);

  GeneratedColumn<bool> get autoPause =>
      $composableBuilder(column: $table.autoPause, builder: (column) => column);

  GeneratedColumn<bool> get onboarded =>
      $composableBuilder(column: $table.onboarded, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> heightCm = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<Sex?> sex = const Value.absent(),
                Value<bool> useMiles = const Value.absent(),
                Value<bool> audioCues = const Value.absent(),
                Value<bool> autoPause = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                weightKg: weightKg,
                heightCm: heightCm,
                birthYear: birthYear,
                sex: sex,
                useMiles: useMiles,
                audioCues: audioCues,
                autoPause: autoPause,
                onboarded: onboarded,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> heightCm = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<Sex?> sex = const Value.absent(),
                Value<bool> useMiles = const Value.absent(),
                Value<bool> audioCues = const Value.absent(),
                Value<bool> autoPause = const Value.absent(),
                Value<bool> onboarded = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                weightKg: weightKg,
                heightCm: heightCm,
                birthYear: birthYear,
                sex: sex,
                useMiles: useMiles,
                audioCues: audioCues,
                autoPause: autoPause,
                onboarded: onboarded,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable<$ProfilesTable, Profile>(table),
                          BaseReferences<
                            _$AppDatabase,
                            $ProfilesTable,
                            Profile
                          >(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$RunsTableCreateCompanionBuilder =
    RunsCompanion Function({
      Value<int> id,
      required RunType type,
      required RunStatus status,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> elapsedMs,
      Value<int> movingMs,
      Value<double> distanceM,
      Value<double> avgSpeedMps,
      Value<double> maxSpeedMps,
      Value<double?> kcal,
      Value<double?> elevGainM,
      Value<int?> sprintTimeMs,
      Value<double?> targetDistanceM,
      required GpsQuality gpsQuality,
      Value<String?> note,
    });
typedef $$RunsTableUpdateCompanionBuilder =
    RunsCompanion Function({
      Value<int> id,
      Value<RunType> type,
      Value<RunStatus> status,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> elapsedMs,
      Value<int> movingMs,
      Value<double> distanceM,
      Value<double> avgSpeedMps,
      Value<double> maxSpeedMps,
      Value<double?> kcal,
      Value<double?> elevGainM,
      Value<int?> sprintTimeMs,
      Value<double?> targetDistanceM,
      Value<GpsQuality> gpsQuality,
      Value<String?> note,
    });

final class $$RunsTableReferences
    extends BaseReferences<_$AppDatabase, $RunsTable, Run> {
  $$RunsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrackPointsTable, List<TrackPoint>>
  _trackPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trackPoints,
    aliasName: 'runs__id__track_points__run_id',
  );

  $$TrackPointsTableProcessedTableManager get trackPointsRefs {
    final manager = $$TrackPointsTableTableManager(
      $_db,
      $_db.trackPoints,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_trackPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SplitsTable, List<Split>> _splitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.splits,
    aliasName: 'runs__id__splits__run_id',
  );

  $$SplitsTableProcessedTableManager get splitsRefs {
    final manager = $$SplitsTableTableManager(
      $_db,
      $_db.splits,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_splitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BestEffortsTable, List<BestEffort>>
  _bestEffortsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bestEfforts,
    aliasName: 'runs__id__best_efforts__run_id',
  );

  $$BestEffortsTableProcessedTableManager get bestEffortsRefs {
    final manager = $$BestEffortsTableTableManager(
      $_db,
      $_db.bestEfforts,
    ).filter((f) => f.runId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bestEffortsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RunsTableFilterComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RunType, RunType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RunStatus, RunStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movingMs => $composableBuilder(
    column: $table.movingMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxSpeedMps => $composableBuilder(
    column: $table.maxSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevGainM => $composableBuilder(
    column: $table.elevGainM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sprintTimeMs => $composableBuilder(
    column: $table.sprintTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GpsQuality, GpsQuality, String>
  get gpsQuality => $composableBuilder(
    column: $table.gpsQuality,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trackPointsRefs(
    Expression<bool> Function($$TrackPointsTableFilterComposer f) f,
  ) {
    final $$TrackPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableFilterComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> splitsRefs(
    Expression<bool> Function($$SplitsTableFilterComposer f) f,
  ) {
    final $$SplitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splits,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitsTableFilterComposer(
            $db: $db,
            $table: $db.splits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bestEffortsRefs(
    Expression<bool> Function($$BestEffortsTableFilterComposer f) f,
  ) {
    final $$BestEffortsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bestEfforts,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BestEffortsTableFilterComposer(
            $db: $db,
            $table: $db.bestEfforts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunsTableOrderingComposer extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movingMs => $composableBuilder(
    column: $table.movingMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxSpeedMps => $composableBuilder(
    column: $table.maxSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevGainM => $composableBuilder(
    column: $table.elevGainM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sprintTimeMs => $composableBuilder(
    column: $table.sprintTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gpsQuality => $composableBuilder(
    column: $table.gpsQuality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunsTable> {
  $$RunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RunType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RunStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<int> get movingMs =>
      $composableBuilder(column: $table.movingMs, builder: (column) => column);

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxSpeedMps => $composableBuilder(
    column: $table.maxSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get elevGainM =>
      $composableBuilder(column: $table.elevGainM, builder: (column) => column);

  GeneratedColumn<int> get sprintTimeMs => $composableBuilder(
    column: $table.sprintTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetDistanceM => $composableBuilder(
    column: $table.targetDistanceM,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GpsQuality, String> get gpsQuality =>
      $composableBuilder(
        column: $table.gpsQuality,
        builder: (column) => column,
      );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  Expression<T> trackPointsRefs<T extends Object>(
    Expression<T> Function($$TrackPointsTableAnnotationComposer a) f,
  ) {
    final $$TrackPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackPoints,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> splitsRefs<T extends Object>(
    Expression<T> Function($$SplitsTableAnnotationComposer a) f,
  ) {
    final $$SplitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.splits,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SplitsTableAnnotationComposer(
            $db: $db,
            $table: $db.splits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bestEffortsRefs<T extends Object>(
    Expression<T> Function($$BestEffortsTableAnnotationComposer a) f,
  ) {
    final $$BestEffortsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bestEfforts,
      getReferencedColumn: (t) => t.runId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BestEffortsTableAnnotationComposer(
            $db: $db,
            $table: $db.bestEfforts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RunsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunsTable,
          Run,
          $$RunsTableFilterComposer,
          $$RunsTableOrderingComposer,
          $$RunsTableAnnotationComposer,
          $$RunsTableCreateCompanionBuilder,
          $$RunsTableUpdateCompanionBuilder,
          (Run, $$RunsTableReferences),
          Run,
          PrefetchHooks Function({
            bool trackPointsRefs,
            bool splitsRefs,
            bool bestEffortsRefs,
          })
        > {
  $$RunsTableTableManager(_$AppDatabase db, $RunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<RunType> type = const Value.absent(),
                Value<RunStatus> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int> movingMs = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<double> avgSpeedMps = const Value.absent(),
                Value<double> maxSpeedMps = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> elevGainM = const Value.absent(),
                Value<int?> sprintTimeMs = const Value.absent(),
                Value<double?> targetDistanceM = const Value.absent(),
                Value<GpsQuality> gpsQuality = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => RunsCompanion(
                id: id,
                type: type,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                elapsedMs: elapsedMs,
                movingMs: movingMs,
                distanceM: distanceM,
                avgSpeedMps: avgSpeedMps,
                maxSpeedMps: maxSpeedMps,
                kcal: kcal,
                elevGainM: elevGainM,
                sprintTimeMs: sprintTimeMs,
                targetDistanceM: targetDistanceM,
                gpsQuality: gpsQuality,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required RunType type,
                required RunStatus status,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int> movingMs = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<double> avgSpeedMps = const Value.absent(),
                Value<double> maxSpeedMps = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> elevGainM = const Value.absent(),
                Value<int?> sprintTimeMs = const Value.absent(),
                Value<double?> targetDistanceM = const Value.absent(),
                required GpsQuality gpsQuality,
                Value<String?> note = const Value.absent(),
              }) => RunsCompanion.insert(
                id: id,
                type: type,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                elapsedMs: elapsedMs,
                movingMs: movingMs,
                distanceM: distanceM,
                avgSpeedMps: avgSpeedMps,
                maxSpeedMps: maxSpeedMps,
                kcal: kcal,
                elevGainM: elevGainM,
                sprintTimeMs: sprintTimeMs,
                targetDistanceM: targetDistanceM,
                gpsQuality: gpsQuality,
                note: note,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable<$RunsTable, Run>(table),
                          $$RunsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({
            trackPointsRefs = false,
            splitsRefs = false,
            bestEffortsRefs = false,
          }) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (trackPointsRefs) db.trackPoints,
                if (splitsRefs) db.splits,
                if (bestEffortsRefs) db.bestEfforts,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trackPointsRefs)
                    await $_getPrefetchedDataByColumns<
                      Run,
                      $RunsTable,
                      TrackPoint,
                      $TrackPointsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RunsTableReferences
                          ._trackPointsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$RunsTableReferences(
                                db,
                                table,
                                p0,
                              ).trackPointsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'run_id',
                      typedResults: items,
                    ),
                  if (splitsRefs)
                    await $_getPrefetchedDataByColumns<
                      Run,
                      $RunsTable,
                      Split,
                      $SplitsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RunsTableReferences._splitsRefsTable(
                        db,
                      ),
                      managerFromTypedResult:
                          (p0) =>
                              $$RunsTableReferences(db, table, p0).splitsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'run_id',
                      typedResults: items,
                    ),
                  if (bestEffortsRefs)
                    await $_getPrefetchedDataByColumns<
                      Run,
                      $RunsTable,
                      BestEffort,
                      $BestEffortsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RunsTableReferences
                          ._bestEffortsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$RunsTableReferences(
                                db,
                                table,
                                p0,
                              ).bestEffortsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'run_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RunsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunsTable,
      Run,
      $$RunsTableFilterComposer,
      $$RunsTableOrderingComposer,
      $$RunsTableAnnotationComposer,
      $$RunsTableCreateCompanionBuilder,
      $$RunsTableUpdateCompanionBuilder,
      (Run, $$RunsTableReferences),
      Run,
      PrefetchHooks Function({
        bool trackPointsRefs,
        bool splitsRefs,
        bool bestEffortsRefs,
      })
    >;
typedef $$TrackPointsTableCreateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      required int runId,
      required int seq,
      required int tMs,
      required double lat,
      required double lon,
      required double speedMps,
      Value<double?> speedAccMps,
      required double accM,
      Value<double?> altM,
      Value<int> segment,
    });
typedef $$TrackPointsTableUpdateCompanionBuilder =
    TrackPointsCompanion Function({
      Value<int> id,
      Value<int> runId,
      Value<int> seq,
      Value<int> tMs,
      Value<double> lat,
      Value<double> lon,
      Value<double> speedMps,
      Value<double?> speedAccMps,
      Value<double> accM,
      Value<double?> altM,
      Value<int> segment,
    });

final class $$TrackPointsTableReferences
    extends BaseReferences<_$AppDatabase, $TrackPointsTable, TrackPoint> {
  $$TrackPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RunsTable _runIdTable(_$AppDatabase db) =>
      db.runs.createAlias('track_points__run_id__runs__id');

  $$RunsTableProcessedTableManager get runId {
    final $_column = $_itemColumn<int>('run_id')!;

    final manager = $$RunsTableTableManager(
      $_db,
      $_db.runs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackPointsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tMs => $composableBuilder(
    column: $table.tMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedAccMps => $composableBuilder(
    column: $table.speedAccMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accM => $composableBuilder(
    column: $table.accM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altM => $composableBuilder(
    column: $table.altM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segment => $composableBuilder(
    column: $table.segment,
    builder: (column) => ColumnFilters(column),
  );

  $$RunsTableFilterComposer get runId {
    final $$RunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableFilterComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tMs => $composableBuilder(
    column: $table.tMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMps => $composableBuilder(
    column: $table.speedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedAccMps => $composableBuilder(
    column: $table.speedAccMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accM => $composableBuilder(
    column: $table.accM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altM => $composableBuilder(
    column: $table.altM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segment => $composableBuilder(
    column: $table.segment,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunsTableOrderingComposer get runId {
    final $$RunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableOrderingComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackPointsTable> {
  $$TrackPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<int> get tMs =>
      $composableBuilder(column: $table.tMs, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<double> get speedMps =>
      $composableBuilder(column: $table.speedMps, builder: (column) => column);

  GeneratedColumn<double> get speedAccMps => $composableBuilder(
    column: $table.speedAccMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accM =>
      $composableBuilder(column: $table.accM, builder: (column) => column);

  GeneratedColumn<double> get altM =>
      $composableBuilder(column: $table.altM, builder: (column) => column);

  GeneratedColumn<int> get segment =>
      $composableBuilder(column: $table.segment, builder: (column) => column);

  $$RunsTableAnnotationComposer get runId {
    final $$RunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableAnnotationComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackPointsTable,
          TrackPoint,
          $$TrackPointsTableFilterComposer,
          $$TrackPointsTableOrderingComposer,
          $$TrackPointsTableAnnotationComposer,
          $$TrackPointsTableCreateCompanionBuilder,
          $$TrackPointsTableUpdateCompanionBuilder,
          (TrackPoint, $$TrackPointsTableReferences),
          TrackPoint,
          PrefetchHooks Function({bool runId})
        > {
  $$TrackPointsTableTableManager(_$AppDatabase db, $TrackPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TrackPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TrackPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$TrackPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<int> tMs = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<double> speedMps = const Value.absent(),
                Value<double?> speedAccMps = const Value.absent(),
                Value<double> accM = const Value.absent(),
                Value<double?> altM = const Value.absent(),
                Value<int> segment = const Value.absent(),
              }) => TrackPointsCompanion(
                id: id,
                runId: runId,
                seq: seq,
                tMs: tMs,
                lat: lat,
                lon: lon,
                speedMps: speedMps,
                speedAccMps: speedAccMps,
                accM: accM,
                altM: altM,
                segment: segment,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int runId,
                required int seq,
                required int tMs,
                required double lat,
                required double lon,
                required double speedMps,
                Value<double?> speedAccMps = const Value.absent(),
                required double accM,
                Value<double?> altM = const Value.absent(),
                Value<int> segment = const Value.absent(),
              }) => TrackPointsCompanion.insert(
                id: id,
                runId: runId,
                seq: seq,
                tMs: tMs,
                lat: lat,
                lon: lon,
                speedMps: speedMps,
                speedAccMps: speedAccMps,
                accM: accM,
                altM: altM,
                segment: segment,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable<$TrackPointsTable, TrackPoint>(table),
                          $$TrackPointsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({runId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (runId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.runId,
                            referencedTable: $$TrackPointsTableReferences
                                ._runIdTable(db),
                            referencedColumn:
                                $$TrackPointsTableReferences._runIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TrackPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackPointsTable,
      TrackPoint,
      $$TrackPointsTableFilterComposer,
      $$TrackPointsTableOrderingComposer,
      $$TrackPointsTableAnnotationComposer,
      $$TrackPointsTableCreateCompanionBuilder,
      $$TrackPointsTableUpdateCompanionBuilder,
      (TrackPoint, $$TrackPointsTableReferences),
      TrackPoint,
      PrefetchHooks Function({bool runId})
    >;
typedef $$SplitsTableCreateCompanionBuilder =
    SplitsCompanion Function({
      required int runId,
      required int idx,
      required double distanceM,
      required int durationMs,
      required double avgSpeedMps,
      Value<double?> elevDeltaM,
      Value<int> rowid,
    });
typedef $$SplitsTableUpdateCompanionBuilder =
    SplitsCompanion Function({
      Value<int> runId,
      Value<int> idx,
      Value<double> distanceM,
      Value<int> durationMs,
      Value<double> avgSpeedMps,
      Value<double?> elevDeltaM,
      Value<int> rowid,
    });

final class $$SplitsTableReferences
    extends BaseReferences<_$AppDatabase, $SplitsTable, Split> {
  $$SplitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RunsTable _runIdTable(_$AppDatabase db) =>
      db.runs.createAlias('splits__run_id__runs__id');

  $$RunsTableProcessedTableManager get runId {
    final $_column = $_itemColumn<int>('run_id')!;

    final manager = $$RunsTableTableManager(
      $_db,
      $_db.runs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SplitsTableFilterComposer
    extends Composer<_$AppDatabase, $SplitsTable> {
  $$SplitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevDeltaM => $composableBuilder(
    column: $table.elevDeltaM,
    builder: (column) => ColumnFilters(column),
  );

  $$RunsTableFilterComposer get runId {
    final $$RunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableFilterComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitsTableOrderingComposer
    extends Composer<_$AppDatabase, $SplitsTable> {
  $$SplitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevDeltaM => $composableBuilder(
    column: $table.elevDeltaM,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunsTableOrderingComposer get runId {
    final $$RunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableOrderingComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SplitsTable> {
  $$SplitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgSpeedMps => $composableBuilder(
    column: $table.avgSpeedMps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevDeltaM => $composableBuilder(
    column: $table.elevDeltaM,
    builder: (column) => column,
  );

  $$RunsTableAnnotationComposer get runId {
    final $$RunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableAnnotationComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SplitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SplitsTable,
          Split,
          $$SplitsTableFilterComposer,
          $$SplitsTableOrderingComposer,
          $$SplitsTableAnnotationComposer,
          $$SplitsTableCreateCompanionBuilder,
          $$SplitsTableUpdateCompanionBuilder,
          (Split, $$SplitsTableReferences),
          Split,
          PrefetchHooks Function({bool runId})
        > {
  $$SplitsTableTableManager(_$AppDatabase db, $SplitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SplitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SplitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SplitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> runId = const Value.absent(),
                Value<int> idx = const Value.absent(),
                Value<double> distanceM = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<double> avgSpeedMps = const Value.absent(),
                Value<double?> elevDeltaM = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SplitsCompanion(
                runId: runId,
                idx: idx,
                distanceM: distanceM,
                durationMs: durationMs,
                avgSpeedMps: avgSpeedMps,
                elevDeltaM: elevDeltaM,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int runId,
                required int idx,
                required double distanceM,
                required int durationMs,
                required double avgSpeedMps,
                Value<double?> elevDeltaM = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SplitsCompanion.insert(
                runId: runId,
                idx: idx,
                distanceM: distanceM,
                durationMs: durationMs,
                avgSpeedMps: avgSpeedMps,
                elevDeltaM: elevDeltaM,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable<$SplitsTable, Split>(table),
                          $$SplitsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({runId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (runId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.runId,
                            referencedTable: $$SplitsTableReferences
                                ._runIdTable(db),
                            referencedColumn:
                                $$SplitsTableReferences._runIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SplitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SplitsTable,
      Split,
      $$SplitsTableFilterComposer,
      $$SplitsTableOrderingComposer,
      $$SplitsTableAnnotationComposer,
      $$SplitsTableCreateCompanionBuilder,
      $$SplitsTableUpdateCompanionBuilder,
      (Split, $$SplitsTableReferences),
      Split,
      PrefetchHooks Function({bool runId})
    >;
typedef $$BestEffortsTableCreateCompanionBuilder =
    BestEffortsCompanion Function({
      Value<int> id,
      required int runId,
      required EffortKind kind,
      Value<int?> valueMs,
      Value<double?> valueMps,
      Value<double?> valueM,
      Value<int?> startSeq,
      Value<int?> endSeq,
    });
typedef $$BestEffortsTableUpdateCompanionBuilder =
    BestEffortsCompanion Function({
      Value<int> id,
      Value<int> runId,
      Value<EffortKind> kind,
      Value<int?> valueMs,
      Value<double?> valueMps,
      Value<double?> valueM,
      Value<int?> startSeq,
      Value<int?> endSeq,
    });

final class $$BestEffortsTableReferences
    extends BaseReferences<_$AppDatabase, $BestEffortsTable, BestEffort> {
  $$BestEffortsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RunsTable _runIdTable(_$AppDatabase db) =>
      db.runs.createAlias('best_efforts__run_id__runs__id');

  $$RunsTableProcessedTableManager get runId {
    final $_column = $_itemColumn<int>('run_id')!;

    final manager = $$RunsTableTableManager(
      $_db,
      $_db.runs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_runIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BestEffortsTableFilterComposer
    extends Composer<_$AppDatabase, $BestEffortsTable> {
  $$BestEffortsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EffortKind, EffortKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get valueMs => $composableBuilder(
    column: $table.valueMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueMps => $composableBuilder(
    column: $table.valueMps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valueM => $composableBuilder(
    column: $table.valueM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startSeq => $composableBuilder(
    column: $table.startSeq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endSeq => $composableBuilder(
    column: $table.endSeq,
    builder: (column) => ColumnFilters(column),
  );

  $$RunsTableFilterComposer get runId {
    final $$RunsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableFilterComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BestEffortsTableOrderingComposer
    extends Composer<_$AppDatabase, $BestEffortsTable> {
  $$BestEffortsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueMs => $composableBuilder(
    column: $table.valueMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueMps => $composableBuilder(
    column: $table.valueMps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valueM => $composableBuilder(
    column: $table.valueM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startSeq => $composableBuilder(
    column: $table.startSeq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endSeq => $composableBuilder(
    column: $table.endSeq,
    builder: (column) => ColumnOrderings(column),
  );

  $$RunsTableOrderingComposer get runId {
    final $$RunsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableOrderingComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BestEffortsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BestEffortsTable> {
  $$BestEffortsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EffortKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get valueMs =>
      $composableBuilder(column: $table.valueMs, builder: (column) => column);

  GeneratedColumn<double> get valueMps =>
      $composableBuilder(column: $table.valueMps, builder: (column) => column);

  GeneratedColumn<double> get valueM =>
      $composableBuilder(column: $table.valueM, builder: (column) => column);

  GeneratedColumn<int> get startSeq =>
      $composableBuilder(column: $table.startSeq, builder: (column) => column);

  GeneratedColumn<int> get endSeq =>
      $composableBuilder(column: $table.endSeq, builder: (column) => column);

  $$RunsTableAnnotationComposer get runId {
    final $$RunsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.runId,
      referencedTable: $db.runs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunsTableAnnotationComposer(
            $db: $db,
            $table: $db.runs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BestEffortsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BestEffortsTable,
          BestEffort,
          $$BestEffortsTableFilterComposer,
          $$BestEffortsTableOrderingComposer,
          $$BestEffortsTableAnnotationComposer,
          $$BestEffortsTableCreateCompanionBuilder,
          $$BestEffortsTableUpdateCompanionBuilder,
          (BestEffort, $$BestEffortsTableReferences),
          BestEffort,
          PrefetchHooks Function({bool runId})
        > {
  $$BestEffortsTableTableManager(_$AppDatabase db, $BestEffortsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$BestEffortsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$BestEffortsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$BestEffortsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> runId = const Value.absent(),
                Value<EffortKind> kind = const Value.absent(),
                Value<int?> valueMs = const Value.absent(),
                Value<double?> valueMps = const Value.absent(),
                Value<double?> valueM = const Value.absent(),
                Value<int?> startSeq = const Value.absent(),
                Value<int?> endSeq = const Value.absent(),
              }) => BestEffortsCompanion(
                id: id,
                runId: runId,
                kind: kind,
                valueMs: valueMs,
                valueMps: valueMps,
                valueM: valueM,
                startSeq: startSeq,
                endSeq: endSeq,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int runId,
                required EffortKind kind,
                Value<int?> valueMs = const Value.absent(),
                Value<double?> valueMps = const Value.absent(),
                Value<double?> valueM = const Value.absent(),
                Value<int?> startSeq = const Value.absent(),
                Value<int?> endSeq = const Value.absent(),
              }) => BestEffortsCompanion.insert(
                id: id,
                runId: runId,
                kind: kind,
                valueMs: valueMs,
                valueMps: valueMps,
                valueM: valueM,
                startSeq: startSeq,
                endSeq: endSeq,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable<$BestEffortsTable, BestEffort>(table),
                          $$BestEffortsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({runId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (runId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.runId,
                            referencedTable: $$BestEffortsTableReferences
                                ._runIdTable(db),
                            referencedColumn:
                                $$BestEffortsTableReferences._runIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BestEffortsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BestEffortsTable,
      BestEffort,
      $$BestEffortsTableFilterComposer,
      $$BestEffortsTableOrderingComposer,
      $$BestEffortsTableAnnotationComposer,
      $$BestEffortsTableCreateCompanionBuilder,
      $$BestEffortsTableUpdateCompanionBuilder,
      (BestEffort, $$BestEffortsTableReferences),
      BestEffort,
      PrefetchHooks Function({bool runId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$RunsTableTableManager get runs => $$RunsTableTableManager(_db, _db.runs);
  $$TrackPointsTableTableManager get trackPoints =>
      $$TrackPointsTableTableManager(_db, _db.trackPoints);
  $$SplitsTableTableManager get splits =>
      $$SplitsTableTableManager(_db, _db.splits);
  $$BestEffortsTableTableManager get bestEfforts =>
      $$BestEffortsTableTableManager(_db, _db.bestEfforts);
}
