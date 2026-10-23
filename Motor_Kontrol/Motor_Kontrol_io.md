# Motor_Kontrol — S-Function paketi

Örnekleme zamanı: **5 ms** (0.005 s)

## HIZLI BAŞLANGIÇ

```matlab
>> cd('bu_klasor')
>> Motor_Kontrol_selftest      % 1. ADIM: Simulink olmadan doğrula
>> Motor_Kontrol_run           % 2. ADIM: zaman döngüsü + grafik
>> Motor_Kontrol_harness       % 3. ADIM: Simulink modelini kur ve koştur
```

## Dosya yapısı — S-Function MANTIK İÇERMEZ

Algoritma `_step.m` içindedir; S-Function yalnızca ince bir
sarmalayıcıdır. Böylece aynı kod hem Simulink'te hem MATLAB komut
satırında çalışır ve tek kaynaktan doğrulanır.

| Dosya | Rol | Zorunlu |
|---|---|---|
| `Motor_Kontrol_step.m` | **ALGORİTMA** — bir kontrol çevrimi | evet |
| `Motor_Kontrol_init.m` | kalıcı durum yapısı | evet |
| `Motor_Kontrol_params.m` | parametreler ve semboller | evet |
| `Motor_Kontrol_selftest.m` | Simulink'siz doğrulama | önerilir |
| `Motor_Kontrol_run.m` | zaman döngüsü + grafik | önerilir |
| `Motor_Kontrol_sfun.m` | Level-2 MATLAB S-Function (**derlemesiz**) | Simulink için |
| `Motor_Kontrol_sfun_mex.c` | Level-2 C MEX S-Function | isteğe bağlı |
| `Motor_Kontrol_model.mdl` | **hazır Simulink modeli** (doğrudan açılır) | önerilir |
| `build_Motor_Kontrol.m` | C sürümünü derler | isteğe bağlı |
| `Motor_Kontrol_harness.m` | Simulink modelini kurar | isteğe bağlı |

> **Hepsi aynı klasörde olmalıdır.** S-Function `_step.m` olmadan
> çalışmaz.

## Simulink'te kullanım (derlemesiz — önerilen)

1. Kütüphane tarayıcısı: **Simulink > User-Defined Functions**
2. **Level-2 MATLAB S-Function** bloğunu modele sürükleyin
3. Bloğu çift tıklayın, *S-function name* alanına yazın:
   `Motor_Kontrol_sfun`
4. Model ayarları: **Solver = Fixed-step**, **Type = Discrete**,
   **Fixed-step size = 0.005**

## Simulink'te kullanım (C MEX — isteğe bağlı)

```matlab
>> build_Motor_Kontrol         % mex ile derler
```
Sonra **S-Function** bloğuna (Level-2 MATLAB olan değil) ad olarak
`Motor_Kontrol_sfun_mex` yazın. Ayrıntılı olay kaydı için:
`mex -DSF_VERBOSE Motor_Kontrol_sfun_mex.c`

> C sürümünün adı bilerek `Motor_Kontrol_sfun_mex`'tir: MATLAB aynı klasörde
> MEX dosyasını `.m` dosyasından önce çağırır; adlar aynı olsaydı
> derleme sonrası derlemesiz (Level-2 MATLAB) blok bozulurdu.

## Doğrulama durumu

Üretilen kod, C ve MATLAB sürümleri **aynı test vektörleriyle**
koşturularak karşılaştırılmıştır; çıktılar birebir örtüşmektedir.
C kodu `-Wall -Wextra` altında uyarısız derlenir.

## Giriş portları

| # | Ad | Tip | Birim | Aralık | Kaynak |
|---|---|---|---|---|---|
| 1 | `StartCommand` | bool |  |  | YerKontrol |
| 2 | `PreparationComplete` | bool |  |  | HazirlikModulu |
| 3 | `FuelPressureOK` | bool |  |  | BasincSensoru |
| 4 | `MotorRunning` | bool |  |  | MotorSensoru |
| 5 | `AbortCommand` | bool |  |  | EmniyetHakemi |

## Çıkış portları

| # | Ad | Tip | Başlangıç | Hedef |
|---|---|---|---|---|
| 1 | `MotorEnable` | bool | 0 | MotorSurucu |
| 2 | `FuelValve` | enum | 0 | ValfSurucu |
| 3 | `Ignition` | enum | 0 | Atesleyici |

## Sembol eşlemesi

| Sembol | Sayısal değer |
|---|---|
| `CLOSED` | 0 |
| `FUEL_ON` | 2 |
| `IGNITION` | 3 |
| `OFF` | 0 |
| `ON` | 1 |
| `OPEN` | 1 |
| `PREPARE` | 1 |
| `RUNNING` | 4 |

## Kapsam dışı

- Simulink Design Verifier bu bloğun içine **bakamaz**; ölü mantık
  tespiti, formal ispat ve otomatik test üretimi çalışmaz.
- Tüm sinyaller `double`; sabit nokta ve tamsayı taşması modellenmez.
- `LOG EVENT`, `SEND`, `CHECK` yan etkisiz kabul edilir
  (C tarafında `-DSF_VERBOSE` ile yazdırılır).
