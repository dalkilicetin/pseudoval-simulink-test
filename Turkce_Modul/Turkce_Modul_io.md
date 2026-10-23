# Türkçe_Modül — S-Function paketi

Örnekleme zamanı: **10 ms** (0.01 s)

## HIZLI BAŞLANGIÇ

```matlab
>> cd('bu_klasor')
>> Turkce_Modul_selftest      % 1. ADIM: Simulink olmadan doğrula
>> Turkce_Modul_run           % 2. ADIM: zaman döngüsü + grafik
>> Turkce_Modul_harness       % 3. ADIM: Simulink modelini kur ve koştur
```

## Dosya yapısı — S-Function MANTIK İÇERMEZ

Algoritma `_step.m` içindedir; S-Function yalnızca ince bir
sarmalayıcıdır. Böylece aynı kod hem Simulink'te hem MATLAB komut
satırında çalışır ve tek kaynaktan doğrulanır.

| Dosya | Rol | Zorunlu |
|---|---|---|
| `Turkce_Modul_step.m` | **ALGORİTMA** — bir kontrol çevrimi | evet |
| `Turkce_Modul_init.m` | kalıcı durum yapısı | evet |
| `Turkce_Modul_params.m` | parametreler ve semboller | evet |
| `Turkce_Modul_selftest.m` | Simulink'siz doğrulama | önerilir |
| `Turkce_Modul_run.m` | zaman döngüsü + grafik | önerilir |
| `Turkce_Modul_sfun.m` | Level-2 MATLAB S-Function (**derlemesiz**) | Simulink için |
| `Turkce_Modul_sfun_mex.c` | Level-2 C MEX S-Function | isteğe bağlı |
| `Turkce_Modul_model.mdl` | **hazır Simulink modeli** (doğrudan açılır) | önerilir |
| `build_Turkce_Modul.m` | C sürümünü derler | isteğe bağlı |
| `Turkce_Modul_harness.m` | Simulink modelini kurar | isteğe bağlı |

> **Hepsi aynı klasörde olmalıdır.** S-Function `_step.m` olmadan
> çalışmaz.

## Simulink'te kullanım (derlemesiz — önerilen)

1. Kütüphane tarayıcısı: **Simulink > User-Defined Functions**
2. **Level-2 MATLAB S-Function** bloğunu modele sürükleyin
3. Bloğu çift tıklayın, *S-function name* alanına yazın:
   `Turkce_Modul_sfun`
4. Model ayarları: **Solver = Fixed-step**, **Type = Discrete**,
   **Fixed-step size = 0.01**

## Simulink'te kullanım (C MEX — isteğe bağlı)

```matlab
>> build_Turkce_Modul         % mex ile derler
```
Sonra **S-Function** bloğuna (Level-2 MATLAB olan değil) ad olarak
`Turkce_Modul_sfun_mex` yazın. Ayrıntılı olay kaydı için:
`mex -DSF_VERBOSE Turkce_Modul_sfun_mex.c`

> C sürümünün adı bilerek `Turkce_Modul_sfun_mex`'tir: MATLAB aynı klasörde
> MEX dosyasını `.m` dosyasından önce çağırır; adlar aynı olsaydı
> derleme sonrası derlemesiz (Level-2 MATLAB) blok bozulurdu.

## Doğrulama durumu

Üretilen kod, C ve MATLAB sürümleri **aynı test vektörleriyle**
koşturularak karşılaştırılmıştır; çıktılar birebir örtüşmektedir.
C kodu `-Wall -Wextra` altında uyarısız derlenir.

## Giriş portları

| # | Ad | Tip | Birim | Aralık | Kaynak |
|---|---|---|---|---|---|
| 1 | `komut` | enum |  |  | Yer |
| 2 | `sıcaklık` | float |  | 0 .. 100 | Sensör |

## Çıkış portları

| # | Ad | Tip | Başlangıç | Hedef |
|---|---|---|---|---|
| 1 | `durum` | enum | KAPALI | Yer |
| 2 | `çıkış` | float | 0 | Yer |

## Sembol eşlemesi

| Sembol | Sayısal değer |
|---|---|
| `AÇIK` | 1 |
| `BEKLE` | 0 |
| `KAPALI` | 0 |
| `ÇALIŞ` | 1 |
| `ŞALIŞ` | 2 |

## WAIT noktaları

Her WAIT satırı bir TON zamanlayıcısıdır (interpreter ile birebir): dolmadıysa yalnız içinde bulunduğu bloğun kalanı atlanır; bir çevrimde ulaşılmayan zamanlayıcı sıfırlanır.

| # | Süre | Kaynak satır | Periyot sayısı |
|---|---|---|---|
| Türkçe_Modül #1 | 30 ms | 21 | 3 |

## Kapsam dışı

- Simulink Design Verifier bu bloğun içine **bakamaz**; ölü mantık
  tespiti, formal ispat ve otomatik test üretimi çalışmaz.
- Tüm sinyaller `double`; sabit nokta ve tamsayı taşması modellenmez.
- `LOG EVENT`, `SEND`, `CHECK` yan etkisiz kabul edilir
  (C tarafında `-DSF_VERBOSE` ile yazdırılır).
