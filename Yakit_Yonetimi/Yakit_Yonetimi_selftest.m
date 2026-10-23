%% Yakit_Yonetimi_selftest - Simulink OLMADAN dogrulama
%%
%% Ilk once BUNU calistirin:
%%     >> Yakit_Yonetimi_selftest
%% Hepsi PASS ise S-Function da calisacaktir.

clc; fprintf('=== %s SELFTEST ===\n', 'Yakit_Yonetimi');
ok = true;

%% --- 1. Gerekli dosyalar ---
gerekli = {'Yakit_Yonetimi_step', 'Yakit_Yonetimi_init', 'Yakit_Yonetimi_params'};
for i = 1:numel(gerekli)
    if exist(gerekli{i}, 'file') ~= 2
        fprintf('  FAIL  eksik dosya: %s.m\n', gerekli{i});
        ok = false;
    else
        fprintf('  PASS  %s.m bulundu\n', gerekli{i});
    end
end
if ~ok, error('Dosyalar eksik. Hepsi ayni klasorde olmali.'); end

%% --- 2. Baslatma ---
P  = Yakit_Yonetimi_params();
st = Yakit_Yonetimi_init();
fprintf('  PASS  parametre ve durum yapisi kuruldu (%d alan)\n', numel(fieldnames(st)));

%% --- 3. Tek cevrim ---
u.p_tank1 = 0;
u.p_tank2 = 0;
u.p_tank3 = 0;
u.sicaklik = -40;
u.komut = 0;
u.sensor_ok = 0;
u.maske = 0;
[y, st] = Yakit_Yonetimi_step(u, st, P);
fprintf('  PASS  bir cevrim kosturuldu\n');
fprintf('        y.durum = %g\n', y.durum);
fprintf('        y.alt_durum = %g\n', y.alt_durum);
fprintf('        y.v_giris = %g\n', y.v_giris);
fprintf('        y.v_cikis = %g\n', y.v_cikis);
fprintf('        y.v_tahliye = %g\n', y.v_tahliye);
fprintf('        y.p_secilen = %g\n', y.p_secilen);
fprintf('        y.ariza_kodu = %g\n', y.ariza_kodu);
fprintf('        y.deneme = %g\n', y.deneme);
fprintf('        y.filtre = %g\n', y.filtre);
fprintf('        y.histerezis = %g\n', y.histerezis);
fprintf('        y.kalp = %g\n', y.kalp);

%% --- 4. Zaman dongusu ---
dt = 0.02; T = 1.0; t = (0:dt:T)'; N = numel(t);
st = Yakit_Yonetimi_init();
LOG.durum = zeros(N,1);
LOG.alt_durum = zeros(N,1);
LOG.v_giris = zeros(N,1);
LOG.v_cikis = zeros(N,1);
LOG.v_tahliye = zeros(N,1);
LOG.p_secilen = zeros(N,1);
LOG.ariza_kodu = zeros(N,1);
LOG.deneme = zeros(N,1);
LOG.filtre = zeros(N,1);
LOG.histerezis = zeros(N,1);
LOG.kalp = zeros(N,1);
for k = 1:N
    u.p_tank1 = 0 + (60-0) * t(k)/T;   %% aralik boyunca rampa
    u.p_tank2 = 0 + (60-0) * t(k)/T;   %% aralik boyunca rampa
    u.p_tank3 = 0 + (60-0) * t(k)/T;   %% aralik boyunca rampa
    u.sicaklik = -40 + (120--40) * t(k)/T;   %% aralik boyunca rampa
    u.komut = double(t(k) >= T/2);   %% ortada basamak
    u.sensor_ok = double(t(k) >= T/2);   %% ortada basamak
    u.maske = 0 + (65535-0) * t(k)/T;   %% aralik boyunca rampa
    [y, st] = Yakit_Yonetimi_step(u, st, P);
    LOG.durum(k) = y.durum;
    LOG.alt_durum(k) = y.alt_durum;
    LOG.v_giris(k) = y.v_giris;
    LOG.v_cikis(k) = y.v_cikis;
    LOG.v_tahliye(k) = y.v_tahliye;
    LOG.p_secilen(k) = y.p_secilen;
    LOG.ariza_kodu(k) = y.ariza_kodu;
    LOG.deneme(k) = y.deneme;
    LOG.filtre(k) = y.filtre;
    LOG.histerezis(k) = y.histerezis;
    LOG.kalp(k) = y.kalp;
end
fprintf('  PASS  %d cevrim kosturuldu\n', N);

fprintf('        durum: min=%g max=%g degisim=%d\n', min(LOG.durum), max(LOG.durum), sum(abs(diff(LOG.durum))>0));
fprintf('        alt_durum: min=%g max=%g degisim=%d\n', min(LOG.alt_durum), max(LOG.alt_durum), sum(abs(diff(LOG.alt_durum))>0));
fprintf('        v_giris: min=%g max=%g degisim=%d\n', min(LOG.v_giris), max(LOG.v_giris), sum(abs(diff(LOG.v_giris))>0));
fprintf('        v_cikis: min=%g max=%g degisim=%d\n', min(LOG.v_cikis), max(LOG.v_cikis), sum(abs(diff(LOG.v_cikis))>0));
fprintf('        v_tahliye: min=%g max=%g degisim=%d\n', min(LOG.v_tahliye), max(LOG.v_tahliye), sum(abs(diff(LOG.v_tahliye))>0));
fprintf('        p_secilen: min=%g max=%g degisim=%d\n', min(LOG.p_secilen), max(LOG.p_secilen), sum(abs(diff(LOG.p_secilen))>0));
fprintf('        ariza_kodu: min=%g max=%g degisim=%d\n', min(LOG.ariza_kodu), max(LOG.ariza_kodu), sum(abs(diff(LOG.ariza_kodu))>0));
fprintf('        deneme: min=%g max=%g degisim=%d\n', min(LOG.deneme), max(LOG.deneme), sum(abs(diff(LOG.deneme))>0));
fprintf('        filtre: min=%g max=%g degisim=%d\n', min(LOG.filtre), max(LOG.filtre), sum(abs(diff(LOG.filtre))>0));
fprintf('        histerezis: min=%g max=%g degisim=%d\n', min(LOG.histerezis), max(LOG.histerezis), sum(abs(diff(LOG.histerezis))>0));
fprintf('        kalp: min=%g max=%g degisim=%d\n', min(LOG.kalp), max(LOG.kalp), sum(abs(diff(LOG.kalp))>0));

%% --- 5. Grafik (basarisiz olursa testi bozmaz) ---
try
    figure('Name','Yakit_Yonetimi selftest');
    no = 11;
    subplot(no,1,1); stairs(t, LOG.durum, 'LineWidth',1.2); grid on; ylabel('durum','Interpreter','none');
    subplot(no,1,2); stairs(t, LOG.alt_durum, 'LineWidth',1.2); grid on; ylabel('alt_durum','Interpreter','none');
    subplot(no,1,3); stairs(t, LOG.v_giris, 'LineWidth',1.2); grid on; ylabel('v_giris','Interpreter','none');
    subplot(no,1,4); stairs(t, LOG.v_cikis, 'LineWidth',1.2); grid on; ylabel('v_cikis','Interpreter','none');
    subplot(no,1,5); stairs(t, LOG.v_tahliye, 'LineWidth',1.2); grid on; ylabel('v_tahliye','Interpreter','none');
    subplot(no,1,6); stairs(t, LOG.p_secilen, 'LineWidth',1.2); grid on; ylabel('p_secilen','Interpreter','none');
    subplot(no,1,7); stairs(t, LOG.ariza_kodu, 'LineWidth',1.2); grid on; ylabel('ariza_kodu','Interpreter','none');
    subplot(no,1,8); stairs(t, LOG.deneme, 'LineWidth',1.2); grid on; ylabel('deneme','Interpreter','none');
    subplot(no,1,9); stairs(t, LOG.filtre, 'LineWidth',1.2); grid on; ylabel('filtre','Interpreter','none');
    subplot(no,1,10); stairs(t, LOG.histerezis, 'LineWidth',1.2); grid on; ylabel('histerezis','Interpreter','none');
    subplot(no,1,11); stairs(t, LOG.kalp, 'LineWidth',1.2); grid on; ylabel('kalp','Interpreter','none');
    xlabel('t [s]');
catch
    fprintf('  (grafik ciziminde sorun var, mantik etkilenmedi)\n');
end

fprintf('\n=== SELFTEST TAMAM ===\n');
fprintf('Simulink icin: Level-2 MATLAB S-Function blogu, ad = %s_sfun\n', 'Yakit_Yonetimi');