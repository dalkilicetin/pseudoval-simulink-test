# Motor_Kontrol — MATLAB kodu

Örnekleme zamanı: **5 ms**

## Dosyalar

| Dosya | İşlev |
|---|---|
| `Motor_Kontrol_params.m` | Veri tabanı parametreleri ve sembol sabitleri |
| `Motor_Kontrol_init.m` | Kalıcı durum yapısını başlatır |
| `Motor_Kontrol_step.m` | **Bir kontrol çevrimi** — `[y, st] = Motor_Kontrol_step(u, st, P)` |
| `Motor_Kontrol_run.m` | Zaman döngüsü + grafik (doğrudan çalıştırın) |

## Hızlı başlangıç

```matlab
>> Motor_Kontrol_run
```

## Giriş / çıkış

| Yön | Alan | Tip | Birim |
|---|---|---|---|
| giriş | `u.StartCommand` | bool |  |
| giriş | `u.PreparationComplete` | bool |  |
| giriş | `u.FuelPressureOK` | bool |  |
| giriş | `u.MotorRunning` | bool |  |
| giriş | `u.AbortCommand` | bool |  |
| çıkış | `y.MotorEnable` | bool |  |
| çıkış | `y.FuelValve` | enum |  |
| çıkış | `y.Ignition` | enum |  |

## Kapsam dışı

- Tüm sinyaller `double`; sabit nokta ve tamsayı taşması modellenmez.
- `WAIT` interpreter'daki gibi TON zamanlayıcısıdır (back-to-back
  testiyle doğrulanır).
- MATLAB Coder ile C'ye çevrilebilir; MISRA uyumu garanti edilmez.
