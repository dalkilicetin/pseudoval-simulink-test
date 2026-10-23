%% Tum_Komutlar_selftest - Simulink OLMADAN dogrulama
%%
%% Ilk once BUNU calistirin:
%%     >> Tum_Komutlar_selftest
%% Hepsi PASS ise S-Function da calisacaktir.

clc; fprintf('=== %s SELFTEST ===\n', 'Tum_Komutlar');
ok = true;

%% --- 1. Gerekli dosyalar ---
gerekli = {'Tum_Komutlar_step', 'Tum_Komutlar_init', 'Tum_Komutlar_params'};
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
P  = Tum_Komutlar_params();
st = Tum_Komutlar_init();
fprintf('  PASS  parametre ve durum yapisi kuruldu (%d alan)\n', numel(fieldnames(st)));

%% --- 3. Tek cevrim ---
u.basinc = 0;
u.komut = 0;
u.izin = 0;
u.kelime = 0;
u.n = 0;
[y, st] = Tum_Komutlar_step(u, st, P);
fprintf('  PASS  bir cevrim kosturuldu\n');
fprintf('        y.valf = %g\n', y.valf);
fprintf('        y.pompa = %g\n', y.pompa);
fprintf('        y.mod = %g\n', y.mod);
fprintf('        y.sayac = %g\n', y.sayac);
fprintf('        y.toplam = %g\n', y.toplam);
fprintf('        y.bitler = %g\n', y.bitler);
fprintf('        y.hata = %g\n', y.hata);
fprintf('        y.f = %g\n', y.f);
fprintf('        y.sonuc = %g\n', y.sonuc);

%% --- 4. Zaman dongusu ---
dt = 0.01; T = 1.0; t = (0:dt:T)'; N = numel(t);
st = Tum_Komutlar_init();
LOG.valf = zeros(N,1);
LOG.pompa = zeros(N,1);
LOG.mod = zeros(N,1);
LOG.sayac = zeros(N,1);
LOG.toplam = zeros(N,1);
LOG.bitler = zeros(N,1);
LOG.hata = zeros(N,1);
LOG.f = zeros(N,1);
LOG.sonuc = zeros(N,1);
for k = 1:N
    u.basinc = 0 + (100-0) * t(k)/T;   %% aralik boyunca rampa
    u.komut = double(t(k) >= T/2);   %% ortada basamak
    u.izin = double(t(k) >= T/2);   %% ortada basamak
    u.kelime = 0 + (65535-0) * t(k)/T;   %% aralik boyunca rampa
    u.n = 0 + (6-0) * t(k)/T;   %% aralik boyunca rampa
    [y, st] = Tum_Komutlar_step(u, st, P);
    LOG.valf(k) = y.valf;
    LOG.pompa(k) = y.pompa;
    LOG.mod(k) = y.mod;
    LOG.sayac(k) = y.sayac;
    LOG.toplam(k) = y.toplam;
    LOG.bitler(k) = y.bitler;
    LOG.hata(k) = y.hata;
    LOG.f(k) = y.f;
    LOG.sonuc(k) = y.sonuc;
end
fprintf('  PASS  %d cevrim kosturuldu\n', N);

fprintf('        valf: min=%g max=%g degisim=%d\n', min(LOG.valf), max(LOG.valf), sum(abs(diff(LOG.valf))>0));
fprintf('        pompa: min=%g max=%g degisim=%d\n', min(LOG.pompa), max(LOG.pompa), sum(abs(diff(LOG.pompa))>0));
fprintf('        mod: min=%g max=%g degisim=%d\n', min(LOG.mod), max(LOG.mod), sum(abs(diff(LOG.mod))>0));
fprintf('        sayac: min=%g max=%g degisim=%d\n', min(LOG.sayac), max(LOG.sayac), sum(abs(diff(LOG.sayac))>0));
fprintf('        toplam: min=%g max=%g degisim=%d\n', min(LOG.toplam), max(LOG.toplam), sum(abs(diff(LOG.toplam))>0));
fprintf('        bitler: min=%g max=%g degisim=%d\n', min(LOG.bitler), max(LOG.bitler), sum(abs(diff(LOG.bitler))>0));
fprintf('        hata: min=%g max=%g degisim=%d\n', min(LOG.hata), max(LOG.hata), sum(abs(diff(LOG.hata))>0));
fprintf('        f: min=%g max=%g degisim=%d\n', min(LOG.f), max(LOG.f), sum(abs(diff(LOG.f))>0));
fprintf('        sonuc: min=%g max=%g degisim=%d\n', min(LOG.sonuc), max(LOG.sonuc), sum(abs(diff(LOG.sonuc))>0));

%% --- 5. Grafik (basarisiz olursa testi bozmaz) ---
try
    figure('Name','Tum_Komutlar selftest');
    no = 9;
    subplot(no,1,1); stairs(t, LOG.valf, 'LineWidth',1.2); grid on; ylabel('valf','Interpreter','none');
    subplot(no,1,2); stairs(t, LOG.pompa, 'LineWidth',1.2); grid on; ylabel('pompa','Interpreter','none');
    subplot(no,1,3); stairs(t, LOG.mod, 'LineWidth',1.2); grid on; ylabel('mod','Interpreter','none');
    subplot(no,1,4); stairs(t, LOG.sayac, 'LineWidth',1.2); grid on; ylabel('sayac','Interpreter','none');
    subplot(no,1,5); stairs(t, LOG.toplam, 'LineWidth',1.2); grid on; ylabel('toplam','Interpreter','none');
    subplot(no,1,6); stairs(t, LOG.bitler, 'LineWidth',1.2); grid on; ylabel('bitler','Interpreter','none');
    subplot(no,1,7); stairs(t, LOG.hata, 'LineWidth',1.2); grid on; ylabel('hata','Interpreter','none');
    subplot(no,1,8); stairs(t, LOG.f, 'LineWidth',1.2); grid on; ylabel('f','Interpreter','none');
    subplot(no,1,9); stairs(t, LOG.sonuc, 'LineWidth',1.2); grid on; ylabel('sonuc','Interpreter','none');
    xlabel('t [s]');
catch
    fprintf('  (grafik ciziminde sorun var, mantik etkilenmedi)\n');
end

fprintf('\n=== SELFTEST TAMAM ===\n');
fprintf('Simulink icin: Level-2 MATLAB S-Function blogu, ad = %s_sfun\n', 'Tum_Komutlar');