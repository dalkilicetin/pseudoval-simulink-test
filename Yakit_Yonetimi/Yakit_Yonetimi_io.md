# Yakit_Yonetimi — S-Function paketi

Örnekleme zamanı: **20 ms** (0.02 s)

## HIZLI BAŞLANGIÇ

```matlab
>> cd('bu_klasor')
>> Yakit_Yonetimi_selftest      % 1. ADIM: Simulink olmadan doğrula
>> Yakit_Yonetimi_run           % 2. ADIM: zaman döngüsü + grafik
>> Yakit_Yonetimi_harness       % 3. ADIM: Simulink modelini kur ve koştur
```

## Dosya yapısı — S-Function MANTIK İÇERMEZ

Algoritma `_step.m` içindedir; S-Function yalnızca ince bir
sarmalayıcıdır. Böylece aynı kod hem Simulink'te hem MATLAB komut
satırında çalışır ve tek kaynaktan doğrulanır.

| Dosya | Rol | Zorunlu |
|---|---|---|
| `Yakit_Yonetimi_step.m` | **ALGORİTMA** — bir kontrol çevrimi | evet |
| `Yakit_Yonetimi_init.m` | kalıcı durum yapısı | evet |
| `Yakit_Yonetimi_params.m` | parametreler ve semboller | evet |
| `Yakit_Yonetimi_selftest.m` | Simulink'siz doğrulama | önerilir |
| `Yakit_Yonetimi_run.m` | zaman döngüsü + grafik | önerilir |
| `Yakit_Yonetimi_sfun.m` | Level-2 MATLAB S-Function (**derlemesiz**) | Simulink için |
| `Yakit_Yonetimi_sfun_mex.c` | Level-2 C MEX S-Function | isteğe bağlı |
| `Yakit_Yonetimi_model.mdl` | **hazır Simulink modeli** (doğrudan açılır) | önerilir |
| `build_Yakit_Yonetimi.m` | C sürümünü derler | isteğe bağlı |
| `Yakit_Yonetimi_harness.m` | Simulink modelini kurar | isteğe bağlı |

> **Hepsi aynı klasörde olmalıdır.** S-Function `_step.m` olmadan
> çalışmaz.

## Simulink'te kullanım (derlemesiz — önerilen)

1. Kütüphane tarayıcısı: **Simulink > User-Defined Functions**
2. **Level-2 MATLAB S-Function** bloğunu modele sürükleyin
3. Bloğu çift tıklayın, *S-function name* alanına yazın:
   `Yakit_Yonetimi_sfun`
4. Model ayarları: **Solver = Fixed-step**, **Type = Discrete**,
   **Fixed-step size = 0.02**

## Simulink'te kullanım (C MEX — isteğe bağlı)

```matlab
>> build_Yakit_Yonetimi         % mex ile derler
```
Sonra **S-Function** bloğuna (Level-2 MATLAB olan değil) ad olarak
`Yakit_Yonetimi_sfun_mex` yazın. Ayrıntılı olay kaydı için:
`mex -DSF_VERBOSE Yakit_Yonetimi_sfun_mex.c`

> C sürümünün adı bilerek `Yakit_Yonetimi_sfun_mex`'tir: MATLAB aynı klasörde
> MEX dosyasını `.m` dosyasından önce çağırır; adlar aynı olsaydı
> derleme sonrası derlemesiz (Level-2 MATLAB) blok bozulurdu.

## Doğrulama durumu

Üretilen kod, C ve MATLAB sürümleri **aynı test vektörleriyle**
koşturularak karşılaştırılmıştır; çıktılar birebir örtüşmektedir.
C kodu `-Wall -Wextra` altında uyarısız derlenir.

## Giriş portları

| # | Ad | Tip | Birim | Aralık | Kaynak |
|---|---|---|---|---|---|
| 1 | `p_tank1` | float | bar | 0 .. 60 | Sensor1 |
| 2 | `p_tank2` | float | bar | 0 .. 60 | Sensor2 |
| 3 | `p_tank3` | float | bar | 0 .. 60 | Sensor3 |
| 4 | `sicaklik` | float | C | -40 .. 120 | Sensor4 |
| 5 | `komut` | enum |  |  | Yer |
| 6 | `sensor_ok` | bool |  |  | Saglik |
| 7 | `maske` | uint16 |  | 0 .. 65535 | Yer |

## Çıkış portları

| # | Ad | Tip | Başlangıç | Hedef |
|---|---|---|---|---|
| 1 | `durum` | enum | BOSTA | Yer |
| 2 | `alt_durum` | int32 | 0 | Yer |
| 3 | `v_giris` | bool | 0 | Valf |
| 4 | `v_cikis` | bool | 0 | Valf |
| 5 | `v_tahliye` | bool | 0 | Valf |
| 6 | `p_secilen` | float | 0 | Yer |
| 7 | `ariza_kodu` | uint16 | 0 | Yer |
| 8 | `deneme` | int32 | 0 | Yer |
| 9 | `filtre` | float | 0 | Yer |
| 10 | `histerezis` | bool | 0 | Yer |
| 11 | `kalp` | bool | 0 | Yer |

## Sembol eşlemesi

| Sembol | Sayısal değer |
|---|---|
| `ACIL` | 3 |
| `ARIZA` | 5 |
| `ASIRI_SICAKLIK` | 2 |
| `BOSALIYOR` | 4 |
| `BOSALT` | 2 |
| `BOSTA` | 0 |
| `DENGELEME` | 3 |
| `DOLUM` | 1 |
| `DOLUYOR` | 2 |
| `GUVENLI` | 6 |
| `HATA_YOK` | 0 |
| `ON_KONTROL` | 1 |
| `SENSOR_ARIZA` | 1 |
| `SIFIRLA` | 4 |
| `TUTARSIZLIK` | 4 |
| `YOK` | 0 |
| `ZAMAN_ASIMI` | 8 |

## WAIT noktaları

Her WAIT satırı bir TON zamanlayıcısıdır (interpreter ile birebir): dolmadıysa yalnız içinde bulunduğu bloğun kalanı atlanır; bir çevrimde ulaşılmayan zamanlayıcı sıfırlanır.

| # | Süre | Kaynak satır | Periyot sayısı |
|---|---|---|---|
| Yakit_Yonetimi #1 | None ms | 100 | ? |
| Yakit_Yonetimi #2 | 100 ms | 128 | 5 |
| Bekle_Sabit #1 | 60 ms | 193 | 3 |

## Kapsam dışı

- Simulink Design Verifier bu bloğun içine **bakamaz**; ölü mantık
  tespiti, formal ispat ve otomatik test üretimi çalışmaz.
- Tüm sinyaller `double`; sabit nokta ve tamsayı taşması modellenmez.
- `LOG EVENT`, `SEND`, `CHECK` yan etkisiz kabul edilir
  (C tarafında `-DSF_VERBOSE` ile yazdırılır).
