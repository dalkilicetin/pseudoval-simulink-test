# pseudoval — Simulink denemesi

pseudoval'ın pseudocode'dan ürettiği Simulink S-Function paketlerinin gerçek
MATLAB / Simulink'te koşturulması (GitHub Actions, `matlab-actions/setup-matlab`).
Bu depo yalnız **üretilmiş** dosyaları içerir; üreteç `pseudoval` deposundadır
(`tests/simulink/hazirla.py`).

Her push'ta `run_all.m`, `moduller.txt`'teki her modül için:

1. `<M>_selftest` — Simulink'siz
2. `<M>_model.mdl` — Level-2 MATLAB S-Function, `sim()`
3. `build_<M>` + `<M>_model_mex.mdl` — C MEX S-Function, `sim()`

Her `sim()` `ref_in.csv` girdileriyle koşulur, çıkışlar pseudoval
yorumlayıcısının `ref_out.csv`'siyle çevrim çevrim karşılaştırılır.
