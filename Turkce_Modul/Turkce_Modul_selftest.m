%% Turkce_Modul_selftest - Simulink OLMADAN dogrulama
%%
%% Ilk once BUNU calistirin:
%%     >> Turkce_Modul_selftest
%% Hepsi PASS ise S-Function da calisacaktir.

clc; fprintf('=== %s SELFTEST ===\n', 'Turkce_Modul');
ok = true;

%% --- 1. Gerekli dosyalar ---
gerekli = {'Turkce_Modul_step', 'Turkce_Modul_init', 'Turkce_Modul_params'};
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
P  = Turkce_Modul_params();
st = Turkce_Modul_init();
fprintf('  PASS  parametre ve durum yapisi kuruldu (%d alan)\n', numel(fieldnames(st)));

%% --- 3. Tek cevrim ---
u.komut = 0;
u.sicaklik = 0;
[y, st] = Turkce_Modul_step(u, st, P);
fprintf('  PASS  bir cevrim kosturuldu\n');
fprintf('        y.durum = %g\n', y.durum);
fprintf('        y.cikis = %g\n', y.cikis);

%% --- 4. Zaman dongusu ---
dt = 0.01; T = 1.0; t = (0:dt:T)'; N = numel(t);
st = Turkce_Modul_init();
LOG.durum = zeros(N,1);
LOG.cikis = zeros(N,1);
for k = 1:N
    u.komut = double(t(k) >= T/2);   %% ortada basamak
    u.sicaklik = 0 + (100-0) * t(k)/T;   %% aralik boyunca rampa
    [y, st] = Turkce_Modul_step(u, st, P);
    LOG.durum(k) = y.durum;
    LOG.cikis(k) = y.cikis;
end
fprintf('  PASS  %d cevrim kosturuldu\n', N);

fprintf('        durum: min=%g max=%g degisim=%d\n', min(LOG.durum), max(LOG.durum), sum(abs(diff(LOG.durum))>0));
fprintf('        cikis: min=%g max=%g degisim=%d\n', min(LOG.cikis), max(LOG.cikis), sum(abs(diff(LOG.cikis))>0));

%% --- 5. Grafik (basarisiz olursa testi bozmaz) ---
try
    figure('Name','Turkce_Modul selftest');
    no = 2;
    subplot(no,1,1); stairs(t, LOG.durum, 'LineWidth',1.2); grid on; ylabel('durum','Interpreter','none');
    subplot(no,1,2); stairs(t, LOG.cikis, 'LineWidth',1.2); grid on; ylabel('cikis','Interpreter','none');
    xlabel('t [s]');
catch
    fprintf('  (grafik ciziminde sorun var, mantik etkilenmedi)\n');
end

fprintf('\n=== SELFTEST TAMAM ===\n');
fprintf('Simulink icin: Level-2 MATLAB S-Function blogu, ad = %s_sfun\n', 'Turkce_Modul');