%% Motor_Kontrol_run - zaman dongusu ve grafik
%% pseudoval tarafindan YENI_YAZIM_ornek_motor.pseudo dosyasindan uretilmistir.
%%
%% Girisleri asagidaki 'SENARYO' bolumunde duzenleyin.

clear; clc; close all;
P  = Motor_Kontrol_params();
st = Motor_Kontrol_init();
dt = 0.005;          %% [s]
T  = 1.0;                %% kosum suresi [s]
t  = (0:dt:T)';
N  = numel(t);

%% ======================= SENARYO =========================
IN.StartCommand = 0 * ones(N,1);   %% bool 
IN.PreparationComplete = 0 * ones(N,1);   %% bool 
IN.FuelPressureOK = 0 * ones(N,1);   %% bool 
IN.MotorRunning = 0 * ones(N,1);   %% bool 
IN.AbortCommand = 0 * ones(N,1);   %% bool 

%% Ornek: rampa / basamak tanimlari
%% IN.StartCommand(t>=0.2) = 1;

%% =========================================================

%% --- cikis kayitlari ---
OUT.MotorEnable = zeros(N,1);
OUT.FuelValve = zeros(N,1);
OUT.Ignition = zeros(N,1);

for k = 1:N
    u.StartCommand = IN.StartCommand(k);
    u.PreparationComplete = IN.PreparationComplete(k);
    u.FuelPressureOK = IN.FuelPressureOK(k);
    u.MotorRunning = IN.MotorRunning(k);
    u.AbortCommand = IN.AbortCommand(k);
    [y, st] = Motor_Kontrol_step(u, st, P);
    OUT.MotorEnable(k) = y.MotorEnable;
    OUT.FuelValve(k) = y.FuelValve;
    OUT.Ignition(k) = y.Ignition;
end

%% --- grafik: girisler ---
figure('Name','Girisler');
ni = 5;
subplot(ni,1,1); plot(t, IN.StartCommand, 'LineWidth', 1.2); grid on; ylabel('StartCommand','Interpreter','none');
subplot(ni,1,2); plot(t, IN.PreparationComplete, 'LineWidth', 1.2); grid on; ylabel('PreparationComplete','Interpreter','none');
subplot(ni,1,3); plot(t, IN.FuelPressureOK, 'LineWidth', 1.2); grid on; ylabel('FuelPressureOK','Interpreter','none');
subplot(ni,1,4); plot(t, IN.MotorRunning, 'LineWidth', 1.2); grid on; ylabel('MotorRunning','Interpreter','none');
subplot(ni,1,5); plot(t, IN.AbortCommand, 'LineWidth', 1.2); grid on; ylabel('AbortCommand','Interpreter','none');
xlabel('t [s]');

%% --- grafik: cikislar ---
figure('Name','Cikislar');
no = 3;
subplot(no,1,1); stairs(t, OUT.MotorEnable, 'LineWidth', 1.2); grid on; ylabel('MotorEnable','Interpreter','none');
subplot(no,1,2); stairs(t, OUT.FuelValve, 'LineWidth', 1.2); grid on; ylabel('FuelValve','Interpreter','none');
subplot(no,1,3); stairs(t, OUT.Ignition, 'LineWidth', 1.2); grid on; ylabel('Ignition','Interpreter','none');
xlabel('t [s]');

fprintf('Kosum tamam: %d adim, %.2f s\n', N, T);