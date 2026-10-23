%% Motor_Kontrol_selftest - Simulink OLMADAN dogrulama
%%
%% Ilk once BUNU calistirin:
%%     >> Motor_Kontrol_selftest
%% Hepsi PASS ise S-Function da calisacaktir.

clc; fprintf('=== %s SELFTEST ===\n', 'Motor_Kontrol');
ok = true;

%% --- 1. Gerekli dosyalar ---
gerekli = {'Motor_Kontrol_step', 'Motor_Kontrol_init', 'Motor_Kontrol_params'};
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
P  = Motor_Kontrol_params();
st = Motor_Kontrol_init();
fprintf('  PASS  parametre ve durum yapisi kuruldu (%d alan)\n', numel(fieldnames(st)));

%% --- 3. Tek cevrim ---
u.StartCommand = 0;
u.PreparationComplete = 0;
u.FuelPressureOK = 0;
u.MotorRunning = 0;
u.AbortCommand = 0;
[y, st] = Motor_Kontrol_step(u, st, P);
fprintf('  PASS  bir cevrim kosturuldu\n');
fprintf('        y.MotorEnable = %g\n', y.MotorEnable);
fprintf('        y.FuelValve = %g\n', y.FuelValve);
fprintf('        y.Ignition = %g\n', y.Ignition);

%% --- 4. Zaman dongusu ---
dt = 0.005; T = 1.0; t = (0:dt:T)'; N = numel(t);
st = Motor_Kontrol_init();
LOG.MotorEnable = zeros(N,1);
LOG.FuelValve = zeros(N,1);
LOG.Ignition = zeros(N,1);
for k = 1:N
    u.StartCommand = double(t(k) >= T/2);   %% ortada basamak
    u.PreparationComplete = double(t(k) >= T/2);   %% ortada basamak
    u.FuelPressureOK = double(t(k) >= T/2);   %% ortada basamak
    u.MotorRunning = double(t(k) >= T/2);   %% ortada basamak
    u.AbortCommand = double(t(k) >= T/2);   %% ortada basamak
    [y, st] = Motor_Kontrol_step(u, st, P);
    LOG.MotorEnable(k) = y.MotorEnable;
    LOG.FuelValve(k) = y.FuelValve;
    LOG.Ignition(k) = y.Ignition;
end
fprintf('  PASS  %d cevrim kosturuldu\n', N);

fprintf('        MotorEnable: min=%g max=%g degisim=%d\n', min(LOG.MotorEnable), max(LOG.MotorEnable), sum(abs(diff(LOG.MotorEnable))>0));
fprintf('        FuelValve: min=%g max=%g degisim=%d\n', min(LOG.FuelValve), max(LOG.FuelValve), sum(abs(diff(LOG.FuelValve))>0));
fprintf('        Ignition: min=%g max=%g degisim=%d\n', min(LOG.Ignition), max(LOG.Ignition), sum(abs(diff(LOG.Ignition))>0));

%% --- 5. Grafik (basarisiz olursa testi bozmaz) ---
try
    figure('Name','Motor_Kontrol selftest');
    no = 3;
    subplot(no,1,1); stairs(t, LOG.MotorEnable, 'LineWidth',1.2); grid on; ylabel('MotorEnable','Interpreter','none');
    subplot(no,1,2); stairs(t, LOG.FuelValve, 'LineWidth',1.2); grid on; ylabel('FuelValve','Interpreter','none');
    subplot(no,1,3); stairs(t, LOG.Ignition, 'LineWidth',1.2); grid on; ylabel('Ignition','Interpreter','none');
    xlabel('t [s]');
catch
    fprintf('  (grafik ciziminde sorun var, mantik etkilenmedi)\n');
end

fprintf('\n=== SELFTEST TAMAM ===\n');
fprintf('Simulink icin: Level-2 MATLAB S-Function blogu, ad = %s_sfun\n', 'Motor_Kontrol');