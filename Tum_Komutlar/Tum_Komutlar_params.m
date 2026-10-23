function P = Tum_Komutlar_params()
%% Tum_Komutlar - veri tabani parametreleri ve sembol sabitleri
%% pseudoval tarafindan tum_komutlar.pseudo dosyasindan uretilmistir.

%% --- veri tabani parametreleri ---
P.P_MAX = 80;   %% [bar]
P.N_ADIM = 4;

%% --- semboller (hata kodlari, enum uyeleri) ---
P.ASIRI_BASINC = 1;
P.BASLA = 1;
P.BEKLE = 0;
P.CALISIYOR = 2;
P.DUR = 2;
P.F0 = 0;
P.F1 = 1;
P.F2 = 2;
P.HATA = 3;
P.HAZIR = 1;
P.KAPALI = 0;
P.OK = 0;
P.ZAMAN_ASIMI = 2;

P.DT_MS = 10;
end