# Geliştirme Planı: Geçmiş, Rekorlar, Endurance, Harita ve Cepte Kullanım

> Durum: kararlar verildi · Hedef platform: Android (iOS sonraki aşama)
>
> **Verilen kararlar:** Harita için OpenStreetMap (`flutter_map`) · Arayüz ve sesli bildirimler Türkçe + İngilizce (telefon diline göre) · Bildirimdeki "Bitir" düğmesi yalnızca koşu duraklatılmışken görünür.
> Sıra: **A → B → C → D → E → F**. Her faz kendi başına çalışır durumda biter ve ayrı commit'lenir.

## 0. Temel fikir

Koşucu telefona bakmaz; telefon cepte veya kol bandındadır. Bu yüzden:

1. Takip, **uygulama ekranı kapalıyken ve uygulama arka plandayken** de kesintisiz sürmeli.
2. Koşu **bildirim panelinden ve kilit ekranından** yönetilebilmeli (duraklat, devam, bitir) ve canlı istatistik görünmeli.
3. **Sesli bildirimler** (her km'de süre/tempo) ekrana bakma ihtiyacını ortadan kaldırmalı.
4. Uygulama ya da sistem süreci öldürse bile **koşu kaybolmamalı** (kurtarma).

## 1. Mimari kararı: takip nerede çalışacak?

Şu an ham GPS `MainActivity` içindeki bir `EventChannel`'dan geliyor. Bu kanal **yalnızca Activity yaşarken** çalışır; ekran kilitlenip sistem Activity'yi kapatırsa GPS durur.

| Seçenek | Artı | Eksi |
|---|---|---|
| **A) `flutter_foreground_task` + yerel `raw_gnss` eklentisi (önerilen)** | Tüm takip mantığı Dart'ta kalır (Kalman, auto-pause, kalori tek yerde). Paket bildirim düğmelerini, Android 14 foreground service tiplerini ve yeniden başlatmayı hazır veriyor. | GPS kodunu `MainActivity`'den küçük bir yerel Flutter eklentisine taşımak gerekiyor; arka plan isolate'i ancak eklentileri görebiliyor. |
| B) Tamamen native Kotlin servis | En sağlam, sistemle en uyumlu. | Mantık Kotlin ve Dart arasında ikiye bölünür, iki kez yazılır. |

**Karar: A.** `packages/raw_gnss` adında yerel bir eklenti oluşturulur (mevcut Kotlin kodu buraya taşınır). Takip motoru, `flutter_foreground_task`'ın `TaskHandler`'ında, ayrı bir isolate'te çalışır. Arayüz bu isolate ile mesajlaşır.

```
┌───────────── Foreground Service (type=location) ─────────────┐
│  TaskHandler isolate                                         │
│   raw_gnss ─▶ TrackingEngine ─▶ RunRepository (drift/SQLite) │
│   accel    ─▶ (Kalman, auto-pause, splits, kalori)           │
│        │ her 1 sn                       ▲ komutlar           │
│        ▼                                │ (pause/resume/stop)│
│   Bildirim: "5,24 km · 28:13"  [Duraklat] [Bitir]            │
└──────────────┬──────────────────────────┬────────────────────┘
               │ sendDataToMain           │ sendDataToTask
               ▼                          │
         UI isolate (Riverpod) ── canlı ekran / harita
```

Sprint modu kısa sürdüğü ve telefon elde tutulduğu için mevcut haliyle (UI isolate'inde) kalabilir; ancak aynı `raw_gnss` eklentisini kullanır.

## 2. Veri modeli (Faz A)

**Paket:** `drift` (tipli SQLite, migration desteği, `NativeDatabase.memory()` ile kolay test).

```
profiles        id, weightKg, heightCm?, birthYear?, sex?, units(km|mi),
                audioCues(bool), cueEveryKm(1), autoPause(bool)

runs            id, type(sprint|endurance), status(active|paused|finished|recovered),
                startedAt, endedAt, elapsedMs, movingMs, distanceM,
                avgSpeedMps, maxSpeedMps, kcal, elevGainM?,
                sprintTimeMs?, targetDistanceM?, gpsQuality(good|weak|none), note?

track_points    runId, seq, tMs, lat, lon, speedMps, speedAccMps, accM,
                altM?, segment   ← duraklatmada segment +1 (harita çizgisi kopar)

splits          runId, index, distanceM(1000), durationMs, avgSpeedMps, elevDeltaM?

best_efforts    runId, kind(100m|400m|1k|5k|10k|21k|top_speed|longest),
                valueMs | valueMps | valueM, startSeq, endSeq
```

- Koşu sırasında `track_points` **her konum geldiğinde** yazılır (toplu, ~5 sn'de bir transaction). Böylece süreç ölse bile koşu kurtarılabilir.
- Kişisel rekorlar `best_efforts` tablosundan sorgu ile türetilir (`MIN(valueMs) GROUP BY kind`); ayrı bir PR tablosu tutulmaz, tutarsızlık riski olmaz.

## 3. Faz A: Altyapı (veri katmanı, profil, gezinme)

- [x] `drift` + `drift_dev` + `build_runner`; `AppDatabase`, DAO'lar ve migration v1.
- [x] **Profil ekranı:** kilo (kalori için zorunlu), boy/yaş/cinsiyet (opsiyonel), birim km/mi, sesli bildirim ve auto-pause anahtarları.
- [x] İlk açılışta kısa bir "kilonu gir" adımı (atlanabilir; atlanırsa kalori gösterilmez).
- [x] **Alt gezinme çubuğu:** `Koş` · `Geçmiş` · `Rekorlar` · `Profil`.
- [x] Sprint bitince sonuç **otomatik kaydedilir** (tip=sprint, süre, maks hız, ort. hız, GPS kalitesi, `track_points`).
- [x] Testler: DAO'lar (bellek içi veritabanı), migration.

## 4. Faz B: Koşu geçmişi ve kişisel rekorlar

**Geçmiş ekranı**
- Haftalara göre gruplanmış liste; her haftanın başlığında toplam km, süre ve koşu sayısı.
- Kartta: tip sembolü (sprint/jog), tarih, mesafe, süre, tempo veya hız, PR rozeti, küçük rota önizlemesi (Faz E).
- Kaydırarak silme ve geri alma (Snackbar ile "Undo").
- Üstte son 8 haftanın km'lerini gösteren sade bir çubuk grafik (`fl_chart`).

**Koşu detay ekranı**
- Özet kutuları: mesafe, süre, hareket süresi, ort./maks hız, tempo, kalori.
- Sprint için: 10 m'lik ara süreler ve hız-mesafe eğrisi (CSV'deki Kalman verisinden).
- Endurance için: km ara süreleri tablosu, tempo grafiği, harita (Faz E).
- Not ekleme; GPX dışa aktarma (Faz F).

**Rekorlar ekranı**
- Sprint: en iyi 100 m süresi, en yüksek hız.
- Endurance: en hızlı 400 m / 1 km / 5 km / 10 km / yarı maraton, en uzun koşu.
- Her rekorda tarih ve koşuya bağlantı; rekor gelişimini gösteren küçük bir grafik.
- **"Yeni PR!" rozeti:** sonuç ekranında ve geçmiş kartında.

**En iyi efor (best effort) algoritması:** Kümülatif mesafe/zaman dizisi üzerinde iki işaretçili kayan pencere (O(n)). Her hedef mesafe D için `dist[j] - dist[i] ≥ D` olan en kısa `t[j] - t[i]` bulunur ve hedef mesafeye doğrusal interpolasyonla düzeltilir. Kaydetme anında bir kez hesaplanır.

## 5. Faz C: Arka planda takip ve bildirimden yönetim

**İzinler ve sistem ayarları** (sırayla, her biri gerekçesiyle istenir):
1. `ACCESS_FINE_LOCATION` ("uygulama kullanılırken" yeterli; servis ön plandayken başlatıldığı için arka plan konum izni **gerekmez**).
2. `POST_NOTIFICATIONS` (Android 13+). Verilmezse servis yine çalışır ama bildirim görünmez; kullanıcı uyarılır.
3. `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_LOCATION` (manifest, Android 14+ zorunlu), servis `foregroundServiceType="location"`.
4. **Pil optimizasyonundan muafiyet** isteği. Samsung cihazlar arka plan uygulamalarını agresif öldürüyor; bunun için tek seferlik açıklama ekranı gösterilir.

**Bildirim (devam eden, sessiz kanal "Aktif koşu")**
- Başlık: `Koşu · 5,24 km` · Metin: `28:13 · 5:23 /km · 412 kcal`
- Saniyede bir güncellenir (Android'in bildirim hız sınırının altında).
- Düğmeler:
  - Koşarken: **[Duraklat]**
  - Duraklatılmışken: **[Devam] [Bitir]**. "Bitir" yalnızca duraklatılmışken görünür; böylece cepte yanlışlıkla bitirme engellenir (Strava da böyle yapıyor).
- Kilit ekranında görünür; gizlilik ayarı kullanıcıya bırakılır.
- Bildirime dokununca uygulama canlı koşu ekranında açılır.

**Kurtarma**
- Servis başlarken `runs.status=active` kaydı oluşturulur.
- Uygulama açıldığında aktif bir koşu varsa ve servis çalışıyorsa: canlı ekrana bağlanılır.
- Servis ölmüşse: "Yarım kalan koşu bulundu. Devam et / Kaydet / Sil" seçenekleri sunulur.

## 6. Faz D: Endurance modu

**TrackingEngine** (saf Dart, platformdan bağımsız, birim test edilebilir):
- **Mesafe:** Doppler hızının zamanla integrali (sprintteki Kalman'ın sadeleştirilmiş hali) ana kaynak. Konumlar harita ve tutarlılık kontrolü için kullanılır. İki kaynak 50 m'den fazla ayrışırsa log'a uyarı yazılır.
- **Auto-pause:** hız < 0,8 m/s, 5 sn boyunca → duraklat; hız > 1,5 m/s, 2 sn boyunca → devam. Histerezis sayesinde trafik ışığında titreşim olmaz. Ayarlardan kapatılabilir.
- **Süreler:** toplam süre (duvar saati) ve hareket süresi (duraklamalar hariç). Tempo hesapları hareket süresine göre yapılır.
- **Anlık tempo:** son 15 sn'nin kayan ortalaması (GPS gürültüsünü bastırır); ortalama tempo; km ara süreleri.
- **Kalori:** bkz. §8.
- **Yükselti:** GPS yüksekliği ±10 m gürültülü; 3 m eşikli bir histerezisle toplanır. Barometre desteği sonraya bırakılır.
- **GPS kaybı:** 10 sn'den uzun sürerse "GPS kayboldu" sesli uyarısı verilir; mesafe sonradan uydurulmaz.

**Canlı koşu ekranı** (büyük, eldivenle bile okunabilir)
- Ana sayı: mesafe; altında süre, anlık tempo, ortalama tempo, kalori.
- Kaydırarak geçilen ikinci sayfa: canlı harita (Faz E).
- Düğmeler: **Duraklat** büyük; **Bitir** ise basılı tutularak (1 sn) çalışır, yanlışlıkla basılmasını önler.
- Ekran kapanabilir; takip servis tarafından yürütülür.

**Sesli bildirimler** (`flutter_tts`, Türkçe/İngilizce)
- Her km'de: "3 kilometre. Süre 16 dakika 2 saniye. Son kilometre tempo 5 dakika 21 saniye."
- Duraklat/devam onayı, GPS kaybı uyarısı.
- Müzik çalarken ses kısılması için `AudioFocus` "duck" modu kullanılır.

## 7. Faz E: Harita

- **`flutter_map` + OpenStreetMap karoları (önerilen):** API anahtarı ve faturalandırma yok. OSM karo kullanım politikası gereği uygulamaya özel bir `userAgentPackageName` ayarlanır. Kullanıcı sayısı büyürse ücretsiz katmanı olan bir sağlayıcıya (MapTiler veya Stadia) geçilir.
- Alternatif `google_maps_flutter`: daha tanıdık görünür ama API anahtarı ve faturalandırma hesabı gerektirir.
- **Hıza göre renklenen rota:** konumlar 5 hız aralığına bölünür ve her aralık ayrı bir polyline olarak çizilir (yavaş: gri-mavi, hızlı: pist turuncusu). Duraklamalarda çizgi kopar (`segment`).
- Başlangıç ve bitiş işaretleri, km işaretleri (1, 2, 3 …).
- Detay ekranında harita ile tempo grafiği senkron çalışır: grafikte bir noktaya dokununca haritada o konum gösterilir.
- Geçmiş kartında küçük statik rota önizlemesi (karo kullanmadan, `CustomPainter` ile çizilen çizgi).
- Canlı koşuda harita isteğe bağlı ikinci sayfadadır; harita açık değilken karo indirilmez (pil ve veri tasarrufu).

## 8. Kalori hesabı

Gerçek ölçüm yok, bu yüzden **tahmin** olduğu arayüzde açıkça belirtilir ("≈ 412 kcal").

ACSM metabolik denklemleri (v: m/dk, grade: eğim oranı):

```
Koşu (v ≥ 134 m/dk ≈ 8 km/s):  VO2 = 0.2·v + 0.9·v·grade + 3.5   (ml/kg/dk)
Yürüyüş (v < 134 m/dk):        VO2 = 0.1·v + 1.8·v·grade + 3.5
kcal/dk ≈ VO2 · kg / 1000 · 5
```

- Her konum aralığında (Δt) hesaplanıp toplanır. Eğim, yumuşatılmış yükseltiden alınır ve ±%15 ile sınırlandırılır.
- Sağlama: 70 kg, 10 km/s, düz zemin → yaklaşık 770 kcal/saat (yayınlanmış MET ≈ 9,8 değeriyle tutarlı).
- Duraklama süreleri sayılmaz.
- Kilo girilmemişse kalori gösterilmez.

## 9. Faz F: Cila ve dışa aktarma

- [ ] GPX dışa aktarma ve paylaşma (`share_plus`). Bu dosya Strava'ya veya Garmin'e elle yüklenebilir.
- [ ] Birim desteği (km/mi), Türkçe ve İngilizce arayüz (`flutter_localizations` + ARB dosyaları).
- [ ] Ayarlar: sesli bildirim aralığı (km / dakika), auto-pause eşikleri, ekranın açık kalması.
- [ ] Demo modunu yeni ekranlara genişletmek ve README ekran görüntülerini güncellemek.

## 10. Test stratejisi

| Katman | Nasıl |
|---|---|
| Kalori, best effort, auto-pause durum makinesi, split'ler | Saf Dart birim testleri (sabit girdi → beklenen çıktı) |
| Veritabanı | `drift` bellek içi veritabanı ile DAO ve migration testleri |
| TrackingEngine | **GPS tekrar oynatma:** kayıtlı CSV/GPX izi sahte konum kaynağıyla beslenir; toplam mesafe, split'ler ve auto-pause doğrulanır |
| Arayüz | Widget testleri (mevcut desen) ve demo modu |
| Cihazda | Emülatörün GPX rota oynatma özelliği; sonra gerçek koşu (ekran kapalı, telefon cepte, 30+ dk) |

Kabul ölçütü (Faz C/D): Ekran kapalı ve telefon cepteyken 30 dakikalık koşuda kesinti olmamalı; bildirimden duraklat/devam/bitir çalışmalı; uygulama son kullanılanlardan kaydırılıp kapatılsa bile koşu kaybolmamalı.

## 11. Eklenecek paketler (sürümler uygulama sırasında güncel kararlı sürüme sabitlenecek)

`drift`, `drift_flutter`, `sqlite3_flutter_libs`, `drift_dev` (dev), `build_runner` (dev), `flutter_foreground_task`, `permission_handler`, `flutter_map`, `latlong2`, `fl_chart`, `flutter_tts`, `share_plus`, `intl`.

## 12. Riskler

- **Samsung arka plan kısıtlamaları:** pil muafiyeti alınsa bile "Uyuyan uygulamalar" listesi servisi öldürebilir. Kullanıcıya bir kerelik yönlendirme gösterilir ve kurtarma akışı devreye girer.
- **OSM karo politikası:** yoğun kullanımda ücretli veya kendi karo sunucusuna geçmek gerekir.
- **Kalori yalnızca tahmindir;** nabız kemeri desteği (BLE) ileride doğruluğu artırır.
- **iOS:** arka plan konum ve Live Activities ayrı bir iş; bu plan Android'e odaklı.

## 13. Tahmini iş yükü

| Faz | Kapsam | Tahmin |
|---|---|---|
| A | Veritabanı, profil, gezinme, sprint kaydı | 1 oturum |
| B | Geçmiş, detay, rekorlar, best effort | 1–2 oturum |
| C | raw_gnss eklentisi, foreground service, bildirim, kurtarma | 2 oturum |
| D | TrackingEngine, canlı ekran, sesli bildirim, kalori | 2 oturum |
| E | Harita, renkli rota, grafik senkronu | 1 oturum |
| F | GPX, yerelleştirme, ayarlar, ekran görüntüleri | 1 oturum |
