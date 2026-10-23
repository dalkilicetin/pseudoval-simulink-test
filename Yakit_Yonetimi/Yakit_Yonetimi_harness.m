%% Yakit_Yonetimi_harness - Simulink modelini otomatik kurar
%%
%% Kullanim:
%%     >> Yakit_Yonetimi_harness
%%
%% Derleme GEREKMEZ: 'Level-2 MATLAB S-Function' blogu kullanilir.
%% Once selftest'i calistirmaniz onerilir:
%%     >> Yakit_Yonetimi_selftest

model = 'Yakit_Yonetimi_harness_model';
if bdIsLoaded(model), close_system(model, 0); end
new_system(model); open_system(model);
set_param(model, 'Solver', 'FixedStepDiscrete', ...
    'FixedStep', '0.02', 'StopTime', '2');

%% --- S-Function blogu (Level-2 MATLAB, derlemesiz) ---
sf = [model '/Yakit_Yonetimi'];
add_block('simulink/User-Defined Functions/Level-2 MATLAB S-Function', sf);
set_param(sf, 'FunctionName', 'Yakit_Yonetimi_sfun');

%% --- girisler (From Workspace) ---
t = (0:0.02:2)';
p_tank1_ts = timeseries(linspace(0, 60, numel(t))', t);   %% aralik boyunca rampa
b = add_block('simulink/Sources/From Workspace', [model '/p_tank1']);
set_param(b, 'VariableName', 'p_tank1_ts');
add_line(model, 'p_tank1/1', 'Yakit_Yonetimi/1');
p_tank2_ts = timeseries(linspace(0, 60, numel(t))', t);   %% aralik boyunca rampa
b = add_block('simulink/Sources/From Workspace', [model '/p_tank2']);
set_param(b, 'VariableName', 'p_tank2_ts');
add_line(model, 'p_tank2/1', 'Yakit_Yonetimi/2');
p_tank3_ts = timeseries(linspace(0, 60, numel(t))', t);   %% aralik boyunca rampa
b = add_block('simulink/Sources/From Workspace', [model '/p_tank3']);
set_param(b, 'VariableName', 'p_tank3_ts');
add_line(model, 'p_tank3/1', 'Yakit_Yonetimi/3');
sicaklik_ts = timeseries(linspace(-40, 120, numel(t))', t);   %% aralik boyunca rampa
b = add_block('simulink/Sources/From Workspace', [model '/sicaklik']);
set_param(b, 'VariableName', 'sicaklik_ts');
add_line(model, 'sicaklik/1', 'Yakit_Yonetimi/4');
komut_ts = timeseries(double(t >= 1.0), t);   %% 1. saniyede basamak
b = add_block('simulink/Sources/From Workspace', [model '/komut']);
set_param(b, 'VariableName', 'komut_ts');
add_line(model, 'komut/1', 'Yakit_Yonetimi/5');
sensor_ok_ts = timeseries(double(t >= 1.0), t);   %% 1. saniyede basamak
b = add_block('simulink/Sources/From Workspace', [model '/sensor_ok']);
set_param(b, 'VariableName', 'sensor_ok_ts');
add_line(model, 'sensor_ok/1', 'Yakit_Yonetimi/6');
maske_ts = timeseries(linspace(0, 65535, numel(t))', t);   %% aralik boyunca rampa
b = add_block('simulink/Sources/From Workspace', [model '/maske']);
set_param(b, 'VariableName', 'maske_ts');
add_line(model, 'maske/1', 'Yakit_Yonetimi/7');

%% --- cikislar (Scope + To Workspace) ---
sc = add_block('simulink/Sinks/Scope', [model '/Scope']);
set_param(sc, 'NumInputPorts', '11');
add_line(model, 'Yakit_Yonetimi/1', 'Scope/1');
tw = add_block('simulink/Sinks/To Workspace', [model '/durum_log']);
set_param(tw, 'VariableName', 'durum_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/1', 'durum_log/1');
add_line(model, 'Yakit_Yonetimi/2', 'Scope/2');
tw = add_block('simulink/Sinks/To Workspace', [model '/alt_durum_log']);
set_param(tw, 'VariableName', 'alt_durum_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/2', 'alt_durum_log/1');
add_line(model, 'Yakit_Yonetimi/3', 'Scope/3');
tw = add_block('simulink/Sinks/To Workspace', [model '/v_giris_log']);
set_param(tw, 'VariableName', 'v_giris_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/3', 'v_giris_log/1');
add_line(model, 'Yakit_Yonetimi/4', 'Scope/4');
tw = add_block('simulink/Sinks/To Workspace', [model '/v_cikis_log']);
set_param(tw, 'VariableName', 'v_cikis_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/4', 'v_cikis_log/1');
add_line(model, 'Yakit_Yonetimi/5', 'Scope/5');
tw = add_block('simulink/Sinks/To Workspace', [model '/v_tahliye_log']);
set_param(tw, 'VariableName', 'v_tahliye_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/5', 'v_tahliye_log/1');
add_line(model, 'Yakit_Yonetimi/6', 'Scope/6');
tw = add_block('simulink/Sinks/To Workspace', [model '/p_secilen_log']);
set_param(tw, 'VariableName', 'p_secilen_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/6', 'p_secilen_log/1');
add_line(model, 'Yakit_Yonetimi/7', 'Scope/7');
tw = add_block('simulink/Sinks/To Workspace', [model '/ariza_kodu_log']);
set_param(tw, 'VariableName', 'ariza_kodu_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/7', 'ariza_kodu_log/1');
add_line(model, 'Yakit_Yonetimi/8', 'Scope/8');
tw = add_block('simulink/Sinks/To Workspace', [model '/deneme_log']);
set_param(tw, 'VariableName', 'deneme_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/8', 'deneme_log/1');
add_line(model, 'Yakit_Yonetimi/9', 'Scope/9');
tw = add_block('simulink/Sinks/To Workspace', [model '/filtre_log']);
set_param(tw, 'VariableName', 'filtre_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/9', 'filtre_log/1');
add_line(model, 'Yakit_Yonetimi/10', 'Scope/10');
tw = add_block('simulink/Sinks/To Workspace', [model '/histerezis_log']);
set_param(tw, 'VariableName', 'histerezis_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/10', 'histerezis_log/1');
add_line(model, 'Yakit_Yonetimi/11', 'Scope/11');
tw = add_block('simulink/Sinks/To Workspace', [model '/kalp_log']);
set_param(tw, 'VariableName', 'kalp_log', 'SaveFormat', 'Timeseries');
add_line(model, 'Yakit_Yonetimi/11', 'kalp_log/1');

try, Simulink.BlockDiagram.arrangeSystem(model); catch, end
fprintf('Model kuruldu: %s\n', model);
fprintf('Simulasyon icin:  sim(''%s'')\n', model);

%% --- otomatik calistir ---
out = sim(model);
fprintf('Simulasyon tamamlandi.\n');
figure('Name','Yakit_Yonetimi sonuclari');
no = 11;
subplot(no,1,1); plot(durum_log); grid on; ylabel('durum','Interpreter','none'); title('');
subplot(no,1,2); plot(alt_durum_log); grid on; ylabel('alt_durum','Interpreter','none'); title('');
subplot(no,1,3); plot(v_giris_log); grid on; ylabel('v_giris','Interpreter','none'); title('');
subplot(no,1,4); plot(v_cikis_log); grid on; ylabel('v_cikis','Interpreter','none'); title('');
subplot(no,1,5); plot(v_tahliye_log); grid on; ylabel('v_tahliye','Interpreter','none'); title('');
subplot(no,1,6); plot(p_secilen_log); grid on; ylabel('p_secilen','Interpreter','none'); title('');
subplot(no,1,7); plot(ariza_kodu_log); grid on; ylabel('ariza_kodu','Interpreter','none'); title('');
subplot(no,1,8); plot(deneme_log); grid on; ylabel('deneme','Interpreter','none'); title('');
subplot(no,1,9); plot(filtre_log); grid on; ylabel('filtre','Interpreter','none'); title('');
subplot(no,1,10); plot(histerezis_log); grid on; ylabel('histerezis','Interpreter','none'); title('');
subplot(no,1,11); plot(kalp_log); grid on; ylabel('kalp','Interpreter','none'); title('');