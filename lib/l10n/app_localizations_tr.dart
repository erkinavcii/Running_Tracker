// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Sprint Tracker';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get sprint => 'Sprint';

  @override
  String get run => 'Koşu';

  @override
  String get distance => 'Mesafe';

  @override
  String get time => 'Süre';

  @override
  String get pace => 'Tempo';

  @override
  String get avgPace => 'Ort. tempo';

  @override
  String get speed => 'Hız';

  @override
  String get avgSpeed => 'Ort. hız';

  @override
  String get averageSpeed => 'Ortalama hız';

  @override
  String get topSpeed => 'En yüksek hız';

  @override
  String get calories => 'Kalori';

  @override
  String get elevation => 'Yükselti';

  @override
  String get movingTime => 'Hareket süresi';

  @override
  String get elapsed => 'Geçen süre';

  @override
  String kcalApprox(int kcal) {
    return '≈ $kcal kcal';
  }

  @override
  String get gpsLost => 'GPS yok';

  @override
  String get gpsSearching => 'Aranıyor';

  @override
  String get gpsNoFix => 'Konum yok';

  @override
  String get openSettings => 'Ayarları aç';

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String dbError(String error) {
    return 'Veritabanı açılamadı.\n$error';
  }

  @override
  String get unfinishedTitle => 'Yarım kalan koşu bulundu';

  @override
  String get unfinishedBody =>
      'Takip beklenmedik şekilde durdu. Devam etmek, olduğu gibi kaydetmek ya da silmek ister misin?';

  @override
  String get discard => 'Sil';

  @override
  String get continueRun => 'Devam et';

  @override
  String get tabRun => 'Koşu';

  @override
  String get tabHistory => 'Geçmiş';

  @override
  String get tabRecords => 'Rekorlar';

  @override
  String get tabProfile => 'Profil';

  @override
  String get chooseMode => 'Mod seç';

  @override
  String get homeSubtitle => 'Ham GNSS Doppler hızı, ivmeölçerle filtrelenir.';

  @override
  String get sprintSubtitle => '100 m · otomatik başlangıç ve bitiş';

  @override
  String get endurance => 'Dayanıklılık';

  @override
  String get enduranceSubtitle => 'Cepte çalışır · kontroller bildirimde';

  @override
  String get tipSky => 'Gökyüzünü açıkça gören bir yerde dur.';

  @override
  String get tipHold => 'Telefonu sıkı tut ya da kol bandı kullan.';

  @override
  String get runPaused => 'Koşu duraklatıldı';

  @override
  String get runInProgress => 'Koşu devam ediyor';

  @override
  String get runDeleted => 'Koşu silindi';

  @override
  String get sprintDeleted => 'Sprint silindi';

  @override
  String get undo => 'GERİ AL';

  @override
  String get noRunsTitle => 'Henüz koşu yok';

  @override
  String get noRunsBody => 'Biten koşular buraya otomatik kaydedilir.';

  @override
  String get last8Weeks => 'Son 8 hafta';

  @override
  String get swipeToDelete => 'Silmek için sola kaydır.';

  @override
  String runsCount(int count) {
    return '$count koşu';
  }

  @override
  String get thisWeek => 'Bu hafta';

  @override
  String get lastWeek => 'Geçen hafta';

  @override
  String topSpeedShort(String speed) {
    return 'maks. $speed';
  }

  @override
  String get prBadge => 'PR';

  @override
  String get noRecordsTitle => 'Henüz rekor yok';

  @override
  String get noRecordsBody =>
      'İlk 100 m süreni ve en yüksek hızını belirlemek için GPS ile bir sprint bitir.';

  @override
  String get notSetYet => 'Henüz yok';

  @override
  String improvedTimes(int count) {
    return '$count kez gelişti';
  }

  @override
  String get effortSprint100 => '100 m sprint';

  @override
  String get effortHalf => 'Yarı maraton';

  @override
  String get effortLongest => 'En uzun koşu';

  @override
  String get enterWeight => 'Kilonu gir';

  @override
  String get enterNumber => 'Bir sayı gir';

  @override
  String get weightRange => '30 ile 250 kg arası';

  @override
  String get wholeCm => 'Tam santimetre';

  @override
  String get heightRange => '100 ile 250 cm arası';

  @override
  String get enterYear => 'Bir yıl gir';

  @override
  String yearRange(int max) {
    return '1920 ile $max arası';
  }

  @override
  String get welcome => 'Sprint Tracker\'a\nhoş geldin';

  @override
  String get onboardingBody =>
      'Kilon kaç? Yalnızca kalori tahmini için kullanılır ve bu telefondan çıkmaz. Daha sonra Profil\'den değiştirebilirsin.';

  @override
  String get weight => 'Kilo';

  @override
  String get height => 'Boy';

  @override
  String get birthYear => 'Doğum yılı';

  @override
  String get continueCaps => 'DEVAM';

  @override
  String get skipForNow => 'Şimdilik geç';

  @override
  String get profileSaved => 'Profil kaydedildi';

  @override
  String get profile => 'Profil';

  @override
  String get profileSubtitle =>
      'Kalori tahmini için kullanılır. Bu telefonda kalır.';

  @override
  String get body => 'Vücut';

  @override
  String get female => 'Kadın';

  @override
  String get male => 'Erkek';

  @override
  String get other => 'Diğer';

  @override
  String get saveCaps => 'KAYDET';

  @override
  String get units => 'Birimler';

  @override
  String get enduranceRuns => 'Dayanıklılık koşuları';

  @override
  String get audioCues => 'Sesli bildirimler';

  @override
  String get audioCuesSubtitle => 'Her kilometrede süre ve tempo';

  @override
  String get autoPause => 'Otomatik duraklatma';

  @override
  String get autoPauseSubtitle => 'Durduğunda koşuyu duraklat';

  @override
  String get keepScreenOn => 'Ekranı açık tut';

  @override
  String get keepScreenOnSubtitle => 'Canlı koşu ekranı açıkken';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get appliesNextRun =>
      'Koşu ayarları bir sonraki koşudan itibaren geçerli olur.';

  @override
  String get runWasDeleted => 'Bu koşu silindi.';

  @override
  String get exportGpx => 'GPX olarak dışa aktar';

  @override
  String get noGpsToExport => 'Bu koşuda dışa aktarılacak GPS noktası yok.';

  @override
  String get editNote => 'Notu düzenle';

  @override
  String get note => 'Not';

  @override
  String get noteHint => 'Pist, rüzgâr, ayakkabı, nasıl hissettirdi…';

  @override
  String get addNote => 'Not ekle';

  @override
  String targetTime(int meters) {
    return '$meters m süresi';
  }

  @override
  String get noGpsNote =>
      'GPS olmadan kaydedildi. Hız ve mesafe ölçülmedi, bu yüzden rekorlara sayılmaz.';

  @override
  String get weakGpsNote =>
      'Zayıf GPS sinyaliyle kaydedildi. Değerler sapabilir.';

  @override
  String get speedEvery10m => 'Her 10 m\'de hız';

  @override
  String get splits => 'Ara süreler';

  @override
  String get route => 'Rota';

  @override
  String get slow => 'yavaş';

  @override
  String get fast => 'hızlı';

  @override
  String get locationNeeded => 'Koşuyu takip etmek için konum izni gerekli.';

  @override
  String get noNotificationTitle => 'Bildirim yok';

  @override
  String get noNotificationBody =>
      'Bildirim izni olmadan koşuyu kilit ekranından göremez ve yönetemezsin. Yine de başlatılsın mı?';

  @override
  String get startAnyway => 'YİNE DE BAŞLAT';

  @override
  String get batteryTitle => 'Ekran kapalıyken de takip et';

  @override
  String get batteryBody =>
      'Bazı telefonlar (özellikle Samsung) pil tasarrufu için arka plandaki uygulamaları durdurur. Cepteki koşunun yarıda kesilmemesi için Sprint Tracker\'ın kısıtlamasız çalışmasına izin ver.';

  @override
  String get allow => 'İZİN VER';

  @override
  String get notNow => 'Şimdi değil';

  @override
  String get couldNotStart => 'Takip başlatılamadı. Tekrar dene.';

  @override
  String get runDiscardedNoGps => 'Koşu silindi: hiç GPS konumu kaydedilmedi.';

  @override
  String get readyTitle => 'Hazır olduğunda başla';

  @override
  String get readyBody =>
      'Telefonu cebine koy. Mesafe, süre ve tempo bildirimde görünür; kilit ekranından duraklatabilirsin.';

  @override
  String get startRun => 'KOŞUYU BAŞLAT';

  @override
  String get autoPausedCaps => 'OTOMATİK DURAKLATILDI';

  @override
  String get pausedCaps => 'DURAKLATILDI';

  @override
  String get resumesWhenRunning => 'Koşmaya başlayınca devam eder';

  @override
  String liveFooter(String elapsed, int climb, int fixes) {
    return 'Geçen $elapsed · Tırmanış $climb m · $fixes GPS konumu · harita için sola kaydır';
  }

  @override
  String get resumeCaps => 'DEVAM';

  @override
  String get holdToFinish => 'BİTİRMEK İÇİN BASILI TUT';

  @override
  String get pauseCaps => 'DURAKLAT';

  @override
  String get waitingForPoints => 'İlk GPS noktaları bekleniyor…';

  @override
  String get followMe => 'Beni takip et';

  @override
  String get sprintTitle => '100 m Sprint';

  @override
  String get issuePermissionTitle => 'Konum izni gerekli';

  @override
  String get issuePermissionBody =>
      'Hız ve mesafenin ölçülebilmesi için hassas konuma izin ver.';

  @override
  String get issueDisabledTitle => 'Konum kapalı';

  @override
  String get issueDisabledBody =>
      'Başlamak için sistem ayarlarından konumu (GPS) aç.';

  @override
  String get issueNoFixTitle => 'GPS sinyali yok';

  @override
  String issueNoFixBody(int seconds) {
    return '$seconds sn sonra uydu konumu yok. Binalardan uzak, açık bir alana çık. Süre işler ama hız ve mesafe sıfır kalır.';
  }

  @override
  String get issueWeakTitle => 'Zayıf GPS sinyali';

  @override
  String issueWeakBody(String meters) {
    return 'Doğruluk yalnızca ±$meters m. Sonuçlar birkaç metre sapabilir.';
  }

  @override
  String get issueLostTitle => 'GPS sinyali kayboldu';

  @override
  String get issueLostBody => 'Sinyal dönene kadar hız azalarak sıfırlanır.';

  @override
  String get newPr => 'Yeni kişisel rekor!';

  @override
  String get stateCalibrating => 'GPS kalibre ediliyor';

  @override
  String get stateCalibratingBody =>
      'Konum oturana kadar dışarıda hareketsiz dur.';

  @override
  String get stateReady => 'Hazır';

  @override
  String get stateReadyBody => 'Yerine geç: 3 saniyelik geri sayım.';

  @override
  String get stateSet => 'Hazır ol…';

  @override
  String get stateSetBody => 'Kıpırdama.';

  @override
  String get stateGo => 'Koş!';

  @override
  String get stateGoBody => 'Bitiş çizgisinde otomatik durur.';

  @override
  String get stateFinished => 'Bitti';

  @override
  String get stateSaved => 'Geçmişine kaydedildi.';

  @override
  String get stateInterpolated =>
      'Bitiş süresi GPS konumları arasında interpolasyonla bulunur.';

  @override
  String get startingIn => 'Başlamasına';

  @override
  String get progress => 'İlerleme';

  @override
  String metersToGo(int meters) {
    return '$meters m kaldı';
  }

  @override
  String get telemetry => 'Telemetri';

  @override
  String get tryAgainCaps => 'TEKRAR DENE';

  @override
  String get waitingForGps => 'GPS BEKLENİYOR';

  @override
  String get startSprint => 'SPRİNTE BAŞLA';

  @override
  String get cancelCaps => 'İPTAL';

  @override
  String get runAgain => 'TEKRAR KOŞ';
}
