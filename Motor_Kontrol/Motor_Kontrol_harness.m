%% Motor_Kontrol_harness - Simulink modelini otomatik kurar
%%
%% Kullanim:
%%     >> Motor_Kontrol_harness
%%
%% Derleme GEREKMEZ: 'Level-2 MATLAB S-Function' blogu kullanilir.
%% Once selftest'i calistirmaniz onerilir:
%%     >> Motor_Kontrol_selftest

model = 'Motor_Kontrol_harness_model';
if bdIsLoaded(model), close_system(model, 0); end
new_system(model); open_system(model);
set_param(model, 'Solver', 'FixedStepDiscrete', ...
    'FixedStep', '0.005', 'StopTime', '2');

%% --- S-Function blogu (Level-2 MATLAB, derlemesiz) ---
sf = [model '/Motor_Kontrol'];
add_block('simulink/User-Defined Functions/Level-2 MATLAB S-Function', sf);
set_param(sf, 'FunctionName', 'Motor_Kontrol_sfun');

%% --- girisler (From Workspace) ---
t = (0:0.005:2)';
StartCommand_ts = timeseries(double(t >= 1.0), t);   %% 1. saniyede basamak
b = add_block('simulink/Sources/From Workspace', [model '/StartCommand']);
set_param(b, 'VariableName', 'StartCommand_ts');
add_line(model, 'StartCommand/1', 'Motor_Kontrol/1');
PreparationComplete_ts = timeseries(double(t >= 1.0), t);   %% 1. saniyede basamak
b = add_block('simulink/Sources/From Workspace', [model '/PreparationComplete']);
set_param(b, 'VariableName', 'PreparationComplete_ts');
add_line(model, 'PreparationComplete/1', 'Motor_Kontrol/2');
FuelPressureOK_ts = timeseries(double(t >= 1.0), t);   %% 1. saniyede basamak
b = add_block('simulink/Sources/From Workspace', [model '/FuelPressureOK']);
set_param(b, 'VariableName', 'FuelPressureOK_ts');
add_line(model, 'FuelPressureOK/1', 'Motor_Kontrol/3');
MotorRunning_ts = timeseries(double(t >= 1.0), t);   %% 1. saniyede basamak
b = add_block('simulink/Sources/From Workspace', [model '/MotorRunning']);
set_param(b, 'VariableName', 'MotorRunning_ts');
add_line(model, 'MotorRunning/1', 'Motor_Kontrol/4');
AbortCommand_ts = timeseries(double(t >= 1.0), t);   %% 1. saniyede basamak
b = add_block('simulink/Sources/From Workspace', [model '/AbortCommand']);
set_param(b, 'VariableName', 'AbortCommand_ts');
add_line(model, 'AbortCommand/1', 'Motor_Kontrol/5');

%% --- cikislar (Scope + To Workspace) ---
sc = add_block('simulink/Sinks/Scope', [model '/Scope']);
set_param(sc, 'NumInputPorts', '3');
add_line(model, 'Motor_Kontrol/1', 'Scope/1');
tw = add_block('simulink/Sinks/To Workspace', [model '/MotorEnable_log']);
set_param(tw, 'VariableName', 'MotorEnable_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Motor_Kontrol/1', 'MotorEnable_log/1');
add_line(model, 'Motor_Kontrol/2', 'Scope/2');
tw = add_block('simulink/Sinks/To Workspace', [model '/FuelValve_log']);
set_param(tw, 'VariableName', 'FuelValve_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Motor_Kontrol/2', 'FuelValve_log/1');
add_line(model, 'Motor_Kontrol/3', 'Scope/3');
tw = add_block('simulink/Sinks/To Workspace', [model '/Ignition_log']);
set_param(tw, 'VariableName', 'Ignition_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Motor_Kontrol/3', 'Ignition_log/1');

try, Simulink.BlockDiagram.arrangeSystem(model); catch, end
fprintf('Model kuruldu: %s\n', model);
fprintf('Simulasyon icin:  sim(''%s'')\n', model);

%% --- otomatik calistir ---
out = sim(model);
fprintf('Simulasyon tamamlandi.\n');
figure('Name','Motor_Kontrol sonuclari');
no = 3;
subplot(no,1,1); plot(MotorEnable_log); grid on; ylabel('MotorEnable','Interpreter','none'); title('');
subplot(no,1,2); plot(FuelValve_log); grid on; ylabel('FuelValve','Interpreter','none'); title('');
subplot(no,1,3); plot(Ignition_log); grid on; ylabel('Ignition','Interpreter','none'); title('');