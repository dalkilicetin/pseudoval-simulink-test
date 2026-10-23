# Yakit_Yonetimi — MATLAB kodu

Örnekleme zamanı: **20 ms**

## Dosyalar

| Dosya | İşlev |
|---|---|
| `Yakit_Yonetimi_params.m` | Veri tabanı parametreleri ve sembol sabitleri |
| `Yakit_Yonetimi_init.m` | Kalıcı durum yapısını başlatır |
| `Yakit_Yonetimi_step.m` | **Bir kontrol çevrimi** — `[y, st] = Yakit_Yonetimi_step(u, st, P)` |
| `Yakit_Yonetimi_run.m` | Zaman döngüsü + grafik (doğrudan çalıştırın) |

## Hızlı başlangıç

```matlab
>> Yakit_Yonetimi_run
```

## Giriş / çıkış

| Yön | Alan | Tip | Birim |
|---|---|---|---|
| giriş | `u.p_tank1` | float | bar |
| giriş | `u.p_tank2` | float | bar |
| giriş | `u.p_tank3` | float | bar |
| giriş | `u.sicaklik` | float | C |
| giriş | `u.komut` | enum |  |
| giriş | `u.sensor_ok` | bool |  |
| giriş | `u.maske` | uint16 |  |
| çıkış | `y.durum` | enum |  |
| çıkış | `y.alt_durum` | int32 |  |
| çıkış | `y.v_giris` | bool |  |
| çıkış | `y.v_cikis` | bool |  |
| çıkış | `y.v_tahliye` | bool |  |
| çıkış | `y.p_secilen` | float |  |
| çıkış | `y.ariza_kodu` | uint16 |  |
| çıkış | `y.deneme` | int32 |  |
| çıkış | `y.filtre` | float |  |
| çıkış | `y.histerezis` | bool |  |
| çıkış | `y.kalp` | bool |  |

## Kapsam dışı

- Tüm sinyaller `double`; sabit nokta ve tamsayı taşması modellenmez.
- `WAIT` interpreter'daki gibi TON zamanlayıcısıdır (back-to-back
  testiyle doğrulanır).
- MATLAB Coder ile C'ye çevrilebilir; MISRA uyumu garanti edilmez.
