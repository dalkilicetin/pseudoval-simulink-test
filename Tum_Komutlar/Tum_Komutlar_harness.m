%% Tum_Komutlar_harness - Simulink modelini otomatik kurar
%%
%% Kullanim:
%%     >> Tum_Komutlar_harness
%%
%% Derleme GEREKMEZ: 'Level-2 MATLAB S-Function' blogu kullanilir.
%% Once selftest'i calistirmaniz onerilir:
%%     >> Tum_Komutlar_selftest

model = 'Tum_Komutlar_harness_model';
if bdIsLoaded(model), close_system(model, 0); end
new_system(model); open_system(model);
set_param(model, 'Solver', 'FixedStepDiscrete', ...
    'FixedStep', '0.01', 'StopTime', '2');

%% --- S-Function blogu (Level-2 MATLAB, derlemesiz) ---
sf = [model '/Tum_Komutlar'];
add_block('simulink/User-Defined Functions/Level-2 MATLAB S-Function', sf);
set_param(sf, 'FunctionName', 'Tum_Komutlar_sfun');

%% --- girisler (From Workspace) ---
t = (0:0.01:2)';
basinc_ts = timeseries(linspace(0, 100, numel(t))', t);   %% aralik boyunca rampa
b = add_block('simulink/Sources/From Workspace', [model '/basinc']);
set_param(b, 'VariableName', 'basinc_ts');
add_line(model, 'basinc/1', 'Tum_Komutlar/1');
komut_ts = timeseries(double(t >= 1.0), t);   %% 1. saniyede basamak
b = add_block('simulink/Sources/From Workspace', [model '/komut']);
set_param(b, 'VariableName', 'komut_ts');
add_line(model, 'komut/1', 'Tum_Komutlar/2');
izin_ts = timeseries(double(t >= 1.0), t);   %% 1. saniyede basamak
b = add_block('simulink/Sources/From Workspace', [model '/izin']);
set_param(b, 'VariableName', 'izin_ts');
add_line(model, 'izin/1', 'Tum_Komutlar/3');
kelime_ts = timeseries(linspace(0, 65535, numel(t))', t);   %% aralik boyunca rampa
b = add_block('simulink/Sources/From Workspace', [model '/kelime']);
set_param(b, 'VariableName', 'kelime_ts');
add_line(model, 'kelime/1', 'Tum_Komutlar/4');
n_ts = timeseries(linspace(0, 6, numel(t))', t);   %% aralik boyunca rampa
b = add_block('simulink/Sources/From Workspace', [model '/n']);
set_param(b, 'VariableName', 'n_ts');
add_line(model, 'n/1', 'Tum_Komutlar/5');

%% --- cikislar (Scope + To Workspace) ---
sc = add_block('simulink/Sinks/Scope', [model '/Scope']);
set_param(sc, 'NumInputPorts', '9');
add_line(model, 'Tum_Komutlar/1', 'Scope/1');
tw = add_block('simulink/Sinks/To Workspace', [model '/valf_log']);
set_param(tw, 'VariableName', 'valf_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Tum_Komutlar/1', 'valf_log/1');
add_line(model, 'Tum_Komutlar/2', 'Scope/2');
tw = add_block('simulink/Sinks/To Workspace', [model '/pompa_log']);
set_param(tw, 'VariableName', 'pompa_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Tum_Komutlar/2', 'pompa_log/1');
add_line(model, 'Tum_Komutlar/3', 'Scope/3');
tw = add_block('simulink/Sinks/To Workspace', [model '/mod_log']);
set_param(tw, 'VariableName', 'mod_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Tum_Komutlar/3', 'mod_log/1');
add_line(model, 'Tum_Komutlar/4', 'Scope/4');
tw = add_block('simulink/Sinks/To Workspace', [model '/sayac_log']);
set_param(tw, 'VariableName', 'sayac_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Tum_Komutlar/4', 'sayac_log/1');
add_line(model, 'Tum_Komutlar/5', 'Scope/5');
tw = add_block('simulink/Sinks/To Workspace', [model '/toplam_log']);
set_param(tw, 'VariableName', 'toplam_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Tum_Komutlar/5', 'toplam_log/1');
add_line(model, 'Tum_Komutlar/6', 'Scope/6');
tw = add_block('simulink/Sinks/To Workspace', [model '/bitler_log']);
set_param(tw, 'VariableName', 'bitler_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Tum_Komutlar/6', 'bitler_log/1');
add_line(model, 'Tum_Komutlar/7', 'Scope/7');
tw = add_block('simulink/Sinks/To Workspace', [model '/hata_log']);
set_param(tw, 'VariableName', 'hata_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Tum_Komutlar/7', 'hata_log/1');
add_line(model, 'Tum_Komutlar/8', 'Scope/8');
tw = add_block('simulink/Sinks/To Workspace', [model '/f_log']);
set_param(tw, 'VariableName', 'f_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Tum_Komutlar/8', 'f_log/1');
add_line(model, 'Tum_Komutlar/9', 'Scope/9');
tw = add_block('simulink/Sinks/To Workspace', [model '/sonuc_log']);
set_param(tw, 'VariableName', 'sonuc_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Tum_Komutlar/9', 'sonuc_log/1');

try, Simulink.BlockDiagram.arrangeSystem(model); catch, end
fprintf('Model kuruldu: %s\n', model);
fprintf('Simulasyon icin:  sim(''%s'')\n', model);

%% --- otomatik calistir ---
out = sim(model);
fprintf('Simulasyon tamamlandi.\n');
figure('Name','Tum_Komutlar sonuclari');
no = 9;
subplot(no,1,1); plot(valf_log); grid on; ylabel('valf','Interpreter','none'); title('');
subplot(no,1,2); plot(pompa_log); grid on; ylabel('pompa','Interpreter','none'); title('');
subplot(no,1,3); plot(mod_log); grid on; ylabel('mod','Interpreter','none'); title('');
subplot(no,1,4); plot(sayac_log); grid on; ylabel('sayac','Interpreter','none'); title('');
subplot(no,1,5); plot(toplam_log); grid on; ylabel('toplam','Interpreter','none'); title('');
subplot(no,1,6); plot(bitler_log); grid on; ylabel('bitler','Interpreter','none'); title('');
subplot(no,1,7); plot(hata_log); grid on; ylabel('hata','Interpreter','none'); title('');
subplot(no,1,8); plot(f_log); grid on; ylabel('f','Interpreter','none'); title('');
subplot(no,1,9); plot(sonuc_log); grid on; ylabel('sonuc','Interpreter','none'); title('');