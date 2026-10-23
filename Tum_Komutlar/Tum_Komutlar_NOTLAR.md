# Tum_Komutlar — MATLAB kodu

Örnekleme zamanı: **10 ms**

## Dosyalar

| Dosya | İşlev |
|---|---|
| `Tum_Komutlar_params.m` | Veri tabanı parametreleri ve sembol sabitleri |
| `Tum_Komutlar_init.m` | Kalıcı durum yapısını başlatır |
| `Tum_Komutlar_step.m` | **Bir kontrol çevrimi** — `[y, st] = Tum_Komutlar_step(u, st, P)` |
| `Tum_Komutlar_run.m` | Zaman döngüsü + grafik (doğrudan çalıştırın) |

## Hızlı başlangıç

```matlab
>> Tum_Komutlar_run
```

## Giriş / çıkış

| Yön | Alan | Tip | Birim |
|---|---|---|---|
| giriş | `u.basinc` | float | bar |
| giriş | `u.komut` | enum |  |
| giriş | `u.izin` | bool |  |
| giriş | `u.kelime` | uint16 |  |
| giriş | `u.n` | uint8 |  |
| çıkış | `y.valf` | bool |  |
| çıkış | `y.pompa` | bool |  |
| çıkış | `y.mod` | enum |  |
| çıkış | `y.sayac` | int32 |  |
| çıkış | `y.toplam` | float |  |
| çıkış | `y.bitler` | uint16 |  |
| çıkış | `y.hata` | uint8 |  |
| çıkış | `y.f` | float |  |
| çıkış | `y.sonuc` | float |  |

## Kapsam dışı

- Tüm sinyaller `double`; sabit nokta ve tamsayı taşması modellenmez.
- `WAIT` interpreter'daki gibi TON zamanlayıcısıdır (back-to-back
  testiyle doğrulanır).
- MATLAB Coder ile C'ye çevrilebilir; MISRA uyumu garanti edilmez.
