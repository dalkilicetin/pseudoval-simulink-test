# Turkce_Modul — MATLAB kodu

Örnekleme zamanı: **10 ms**

## Dosyalar

| Dosya | İşlev |
|---|---|
| `Turkce_Modul_params.m` | Veri tabanı parametreleri ve sembol sabitleri |
| `Turkce_Modul_init.m` | Kalıcı durum yapısını başlatır |
| `Turkce_Modul_step.m` | **Bir kontrol çevrimi** — `[y, st] = Turkce_Modul_step(u, st, P)` |
| `Turkce_Modul_run.m` | Zaman döngüsü + grafik (doğrudan çalıştırın) |

## Hızlı başlangıç

```matlab
>> Turkce_Modul_run
```

## Giriş / çıkış

| Yön | Alan | Tip | Birim |
|---|---|---|---|
| giriş | `u.komut` | enum |  |
| giriş | `u.sıcaklık` | float |  |
| çıkış | `y.durum` | enum |  |
| çıkış | `y.çıkış` | float |  |

## Kapsam dışı

- Tüm sinyaller `double`; sabit nokta ve tamsayı taşması modellenmez.
- `WAIT` interpreter'daki gibi TON zamanlayıcısıdır (back-to-back
  testiyle doğrulanır).
- MATLAB Coder ile C'ye çevrilebilir; MISRA uyumu garanti edilmez.
