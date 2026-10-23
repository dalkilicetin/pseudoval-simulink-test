%% Yakit_Yonetimi_run - zaman dongusu ve grafik
%% pseudoval tarafindan cok_kompleks.pseudo dosyasindan uretilmistir.
%%
%% Girisleri asagidaki 'SENARYO' bolumunde duzenleyin.

clear; clc; close all;
P  = Yakit_Yonetimi_params();
st = Yakit_Yonetimi_init();
dt = 0.02;          %% [s]
T  = 1.0;                %% kosum suresi [s]
t  = (0:dt:T)';
N  = numel(t);

%% ======================= SENARYO =========================
IN.p_tank1 = 0 * ones(N,1);   %% float [bar]
IN.p_tank2 = 0 * ones(N,1);   %% float [bar]
IN.p_tank3 = 0 * ones(N,1);   %% float [bar]
IN.sicaklik = -40 * ones(N,1);   %% float [C]
IN.komut = 0 * ones(N,1);   %% enum 
IN.sensor_ok = 0 * ones(N,1);   %% bool 
IN.maske = 0 * ones(N,1);   %% uint16 

%% Ornek: rampa / basamak tanimlari
%% IN.p_tank1(t>=0.2) = 1;

%% =========================================================

%% --- cikis kayitlari ---
OUT.durum = zeros(N,1);
OUT.alt_durum = zeros(N,1);
OUT.v_giris = zeros(N,1);
OUT.v_cikis = zeros(N,1);
OUT.v_tahliye = zeros(N,1);
OUT.p_secilen = zeros(N,1);
OUT.ariza_kodu = zeros(N,1);
OUT.deneme = zeros(N,1);
OUT.filtre = zeros(N,1);
OUT.histerezis = zeros(N,1);
OUT.kalp = zeros(N,1);

for k = 1:N
    u.p_tank1 = IN.p_tank1(k);
    u.p_tank2 = IN.p_tank2(k);
    u.p_tank3 = IN.p_tank3(k);
    u.sicaklik = IN.sicaklik(k);
    u.komut = IN.komut(k);
    u.sensor_ok = IN.sensor_ok(k);
    u.maske = IN.maske(k);
    [y, st] = Yakit_Yonetimi_step(u, st, P);
    OUT.durum(k) = y.durum;
    OUT.alt_durum(k) = y.alt_durum;
    OUT.v_giris(k) = y.v_giris;
    OUT.v_cikis(k) = y.v_cikis;
    OUT.v_tahliye(k) = y.v_tahliye;
    OUT.p_secilen(k) = y.p_secilen;
    OUT.ariza_kodu(k) = y.ariza_kodu;
    OUT.deneme(k) = y.deneme;
    OUT.filtre(k) = y.filtre;
    OUT.histerezis(k) = y.histerezis;
    OUT.kalp(k) = y.kalp;
end

%% --- grafik: girisler ---
figure('Name','Girisler');
ni = 7;
subplot(ni,1,1); plot(t, IN.p_tank1, 'LineWidth', 1.2); grid on; ylabel('p_tank1','Interpreter','none');
subplot(ni,1,2); plot(t, IN.p_tank2, 'LineWidth', 1.2); grid on; ylabel('p_tank2','Interpreter','none');
subplot(ni,1,3); plot(t, IN.p_tank3, 'LineWidth', 1.2); grid on; ylabel('p_tank3','Interpreter','none');
subplot(ni,1,4); plot(t, IN.sicaklik, 'LineWidth', 1.2); grid on; ylabel('sicaklik','Interpreter','none');
subplot(ni,1,5); plot(t, IN.komut, 'LineWidth', 1.2); grid on; ylabel('komut','Interpreter','none');
subplot(ni,1,6); plot(t, IN.sensor_ok, 'LineWidth', 1.2); grid on; ylabel('sensor_ok','Interpreter','none');
subplot(ni,1,7); plot(t, IN.maske, 'LineWidth', 1.2); grid on; ylabel('maske','Interpreter','none');
xlabel('t [s]');

%% --- grafik: cikislar ---
figure('Name','Cikislar');
no = 11;
subplot(no,1,1); stairs(t, OUT.durum, 'LineWidth', 1.2); grid on; ylabel('durum','Interpreter','none');
subplot(no,1,2); stairs(t, OUT.alt_durum, 'LineWidth', 1.2); grid on; ylabel('alt_durum','Interpreter','none');
subplot(no,1,3); stairs(t, OUT.v_giris, 'LineWidth', 1.2); grid on; ylabel('v_giris','Interpreter','none');
subplot(no,1,4); stairs(t, OUT.v_cikis, 'LineWidth', 1.2); grid on; ylabel('v_cikis','Interpreter','none');
subplot(no,1,5); stairs(t, OUT.v_tahliye, 'LineWidth', 1.2); grid on; ylabel('v_tahliye','Interpreter','none');
subplot(no,1,6); stairs(t, OUT.p_secilen, 'LineWidth', 1.2); grid on; ylabel('p_secilen','Interpreter','none');
subplot(no,1,7); stairs(t, OUT.ariza_kodu, 'LineWidth', 1.2); grid on; ylabel('ariza_kodu','Interpreter','none');
subplot(no,1,8); stairs(t, OUT.deneme, 'LineWidth', 1.2); grid on; ylabel('deneme','Interpreter','none');
subplot(no,1,9); stairs(t, OUT.filtre, 'LineWidth', 1.2); grid on; ylabel('filtre','Interpreter','none');
subplot(no,1,10); stairs(t, OUT.histerezis, 'LineWidth', 1.2); grid on; ylabel('histerezis','Interpreter','none');
subplot(no,1,11); stairs(t, OUT.kalp, 'LineWidth', 1.2); grid on; ylabel('kalp','Interpreter','none');
xlabel('t [s]');

fprintf('Kosum tamam: %d adim, %.2f s\n', N, T);