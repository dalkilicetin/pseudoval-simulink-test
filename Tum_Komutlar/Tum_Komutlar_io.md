# Tum_Komutlar — S-Function paketi

Örnekleme zamanı: **10 ms** (0.01 s)

## HIZLI BAŞLANGIÇ

```matlab
>> cd('bu_klasor')
>> Tum_Komutlar_selftest      % 1. ADIM: Simulink olmadan doğrula
>> Tum_Komutlar_run           % 2. ADIM: zaman döngüsü + grafik
>> Tum_Komutlar_harness       % 3. ADIM: Simulink modelini kur ve koştur
```

## Dosya yapısı — S-Function MANTIK İÇERMEZ

Algoritma `_step.m` içindedir; S-Function yalnızca ince bir
sarmalayıcıdır. Böylece aynı kod hem Simulink'te hem MATLAB komut
satırında çalışır ve tek kaynaktan doğrulanır.

| Dosya | Rol | Zorunlu |
|---|---|---|
| `Tum_Komutlar_step.m` | **ALGORİTMA** — bir kontrol çevrimi | evet |
| `Tum_Komutlar_init.m` | kalıcı durum yapısı | evet |
| `Tum_Komutlar_params.m` | parametreler ve semboller | evet |
| `Tum_Komutlar_selftest.m` | Simulink'siz doğrulama | önerilir |
| `Tum_Komutlar_run.m` | zaman döngüsü + grafik | önerilir |
| `Tum_Komutlar_sfun.m` | Level-2 MATLAB S-Function (**derlemesiz**) | Simulink için |
| `Tum_Komutlar_sfun_mex.c` | Level-2 C MEX S-Function | isteğe bağlı |
| `Tum_Komutlar_model.mdl` | **hazır Simulink modeli** (doğrudan açılır) | önerilir |
| `build_Tum_Komutlar.m` | C sürümünü derler | isteğe bağlı |
| `Tum_Komutlar_harness.m` | Simulink modelini kurar | isteğe bağlı |

> **Hepsi aynı klasörde olmalıdır.** S-Function `_step.m` olmadan
> çalışmaz.

## Simulink'te kullanım (derlemesiz — önerilen)

1. Kütüphane tarayıcısı: **Simulink > User-Defined Functions**
2. **Level-2 MATLAB S-Function** bloğunu modele sürükleyin
3. Bloğu çift tıklayın, *S-function name* alanına yazın:
   `Tum_Komutlar_sfun`
4. Model ayarları: **Solver = Fixed-step**, **Type = Discrete**,
   **Fixed-step size = 0.01**

## Simulink'te kullanım (C MEX — isteğe bağlı)

```matlab
>> build_Tum_Komutlar         % mex ile derler
```
Sonra **S-Function** bloğuna (Level-2 MATLAB olan değil) ad olarak
`Tum_Komutlar_sfun_mex` yazın. Ayrıntılı olay kaydı için:
`mex -DSF_VERBOSE Tum_Komutlar_sfun_mex.c`

> C sürümünün adı bilerek `Tum_Komutlar_sfun_mex`'tir: MATLAB aynı klasörde
> MEX dosyasını `.m` dosyasından önce çağırır; adlar aynı olsaydı
> derleme sonrası derlemesiz (Level-2 MATLAB) blok bozulurdu.

## Doğrulama durumu

Üretilen kod, C ve MATLAB sürümleri **aynı test vektörleriyle**
koşturularak karşılaştırılmıştır; çıktılar birebir örtüşmektedir.
C kodu `-Wall -Wextra` altında uyarısız derlenir.

## Giriş portları

| # | Ad | Tip | Birim | Aralık | Kaynak |
|---|---|---|---|---|---|
| 1 | `basinc` | float | bar | 0 .. 100 | Sensor |
| 2 | `komut` | enum |  |  | Yer |
| 3 | `izin` | bool |  |  | Yer |
| 4 | `kelime` | uint16 |  | 0 .. 65535 | Yer |
| 5 | `n` | uint8 |  | 0 .. 6 | Yer |

## Çıkış portları

| # | Ad | Tip | Başlangıç | Hedef |
|---|---|---|---|---|
| 1 | `valf` | bool | FALSE | Surucu |
| 2 | `pompa` | bool | 0 | Surucu |
| 3 | `mod` | enum | KAPALI | Yer |
| 4 | `sayac` | int32 | 0 | Yer |
| 5 | `toplam` | float | 0 | Yer |
| 6 | `bitler` | uint16 | 0 | Yer |
| 7 | `hata` | uint8 | 0 | Yer |
| 8 | `f` | float | 0 | Yer |
| 9 | `sonuc` | float | 0 | Yer |

## Sembol eşlemesi

| Sembol | Sayısal değer |
|---|---|
| `ASIRI_BASINC` | 1 |
| `BASLA` | 1 |
| `BEKLE` | 0 |
| `CALISIYOR` | 2 |
| `DUR` | 2 |
| `F0` | 0 |
| `F1` | 1 |
| `F2` | 2 |
| `HATA` | 3 |
| `HAZIR` | 1 |
| `KAPALI` | 0 |
| `OK` | 0 |
| `ZAMAN_ASIMI` | 2 |

## WAIT noktaları

Her WAIT satırı bir TON zamanlayıcısıdır (interpreter ile birebir): dolmadıysa yalnız içinde bulunduğu bloğun kalanı atlanır; bir çevrimde ulaşılmayan zamanlayıcı sıfırlanır.

| # | Süre | Kaynak satır | Periyot sayısı |
|---|---|---|---|
| Tum_Komutlar #1 | 50 ms | 69 | 5 |
| Tum_Komutlar #2 | None ms | 79 | ? |
| Tum_Komutlar #3 | 30 ms | 88 | 3 |

## Kapsam dışı

- Simulink Design Verifier bu bloğun içine **bakamaz**; ölü mantık
  tespiti, formal ispat ve otomatik test üretimi çalışmaz.
- Tüm sinyaller `double`; sabit nokta ve tamsayı taşması modellenmez.
- `LOG EVENT`, `SEND`, `CHECK` yan etkisiz kabul edilir
  (C tarafında `-DSF_VERBOSE` ile yazdırılır).
