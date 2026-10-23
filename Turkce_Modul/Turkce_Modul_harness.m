%% Turkce_Modul_harness - Simulink modelini otomatik kurar
%%
%% Kullanim:
%%     >> Turkce_Modul_harness
%%
%% Derleme GEREKMEZ: 'Level-2 MATLAB S-Function' blogu kullanilir.
%% Once selftest'i calistirmaniz onerilir:
%%     >> Turkce_Modul_selftest

model = 'Turkce_Modul_harness_model';
if bdIsLoaded(model), close_system(model, 0); end
new_system(model); open_system(model);
set_param(model, 'Solver', 'FixedStepDiscrete', ...
    'FixedStep', '0.01', 'StopTime', '2');

%% --- S-Function blogu (Level-2 MATLAB, derlemesiz) ---
sf = [model '/Turkce_Modul'];
add_block('simulink/User-Defined Functions/Level-2 MATLAB S-Function', sf);
set_param(sf, 'FunctionName', 'Turkce_Modul_sfun');

%% --- girisler (From Workspace) ---
t = (0:0.01:2)';
komut_ts = timeseries(double(t >= 1.0), t);   %% 1. saniyede basamak
b = add_block('simulink/Sources/From Workspace', [model '/komut']);
set_param(b, 'VariableName', 'komut_ts');
add_line(model, 'komut/1', 'Turkce_Modul/1');
sicaklik_ts = timeseries(linspace(0, 100, numel(t))', t);   %% aralik boyunca rampa
b = add_block('simulink/Sources/From Workspace', [model '/sicaklik']);
set_param(b, 'VariableName', 'sicaklik_ts');
add_line(model, 'sicaklik/1', 'Turkce_Modul/2');

%% --- cikislar (Scope + To Workspace) ---
sc = add_block('simulink/Sinks/Scope', [model '/Scope']);
set_param(sc, 'NumInputPorts', '2');
add_line(model, 'Turkce_Modul/1', 'Scope/1');
tw = add_block('simulink/Sinks/To Workspace', [model '/durum_log']);
set_param(tw, 'VariableName', 'durum_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Turkce_Modul/1', 'durum_log/1');
add_line(model, 'Turkce_Modul/2', 'Scope/2');
tw = add_block('simulink/Sinks/To Workspace', [model '/cikis_log']);
set_param(tw, 'VariableName', 'cikis_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Turkce_Modul/2', 'cikis_log/1');

try, Simulink.BlockDiagram.arrangeSystem(model); catch, end
fprintf('Model kuruldu: %s\n', model);
fprintf('Simulasyon icin:  sim(''%s'')\n', model);

%% --- otomatik calistir ---
out = sim(model);
fprintf('Simulasyon tamamlandi.\n');
figure('Name','Turkce_Modul sonuclari');
no = 2;
subplot(no,1,1); plot(durum_log); grid on; ylabel('durum','Interpreter','none'); title('');
subplot(no,1,2); plot(cikis_log); grid on; ylabel('cikis','Interpreter','none'); title('');