function P = Yakit_Yonetimi_params()
%% Yakit_Yonetimi - veri tabani parametreleri ve sembol sabitleri
%% pseudoval tarafindan cok_kompleks.pseudo dosyasindan uretilmistir.

%% --- veri tabani parametreleri ---
P.P_UST = 45;   %% [bar]
P.P_ALT = 10;   %% [bar]
P.P_FARK = 5;
P.T_MAX = 90;
P.MAKS_DENEME = 3;
P.ALFA = 0.25;

%% --- semboller (hata kodlari, enum uyeleri) ---
P.ACIL = 3;
P.ARIZA = 5;
P.ASIRI_SICAKLIK = 2;
P.BOSALIYOR = 4;
P.BOSALT = 2;
P.BOSTA = 0;
P.DENGELEME = 3;
P.DOLUM = 1;
P.DOLUYOR = 2;
P.GUVENLI = 6;
P.HATA_YOK = 0;
P.ON_KONTROL = 1;
P.SENSOR_ARIZA = 1;
P.SIFIRLA = 4;
P.TUTARSIZLIK = 4;
P.YOK = 0;
P.ZAMAN_ASIMI = 8;

P.DT_MS = 20;
end