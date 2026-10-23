function P = Motor_Kontrol_params()
%% Motor_Kontrol - veri tabani parametreleri ve sembol sabitleri
%% pseudoval tarafindan YENI_YAZIM_ornek_motor.pseudo dosyasindan uretilmistir.

%% --- veri tabani parametreleri ---

%% --- semboller (hata kodlari, enum uyeleri) ---
P.CLOSED = 0;
P.FUEL_ON = 2;
P.IGNITION = 3;
P.OFF = 0;
P.ON = 1;
P.OPEN = 1;
P.PREPARE = 1;
P.RUNNING = 4;

P.DT_MS = 5;
end