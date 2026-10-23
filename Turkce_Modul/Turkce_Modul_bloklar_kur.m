function Turkce_Modul_bloklar_kur(kaydet)
%% Turkce_Modul_bloklar_kur - pseudocode algoritmasini STANDART Simulink bloklariyla kurar
%%
%% pseudoval tarafindan turkce_adlar.pseudo dosyasindan uretilmistir.
%% S-Function YOKTUR: algoritma Sum / Product / Relational Operator /
%% Logical Operator / Switch / Unit Delay ... bloklarindan olusur.
%% Ana alt sistemde her pseudocode deyimi (IF, SWITCH, atama ...)
%% kendi alt sistemidir; adi satir numarasini ve deyimi tasir.
%% Kalici degiskenler 'onceki_<ad>' Unit Delay bloklaridir.
%%
%%   >> Turkce_Modul_bloklar_kur          %% modeli kurar, Turkce_Modul_bloklar.slx kaydeder
%%   >> sim('Turkce_Modul_bloklar')

if nargin < 1, kaydet = true; end
mdl = 'Turkce_Modul_bloklar';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
set_param(mdl, 'Solver', 'FixedStepDiscrete', 'FixedStep', '0.01', 'StopTime', '10');
% mantik bloklarinin cikisi double (C ile ayni 0 / 1)
set_param(mdl, 'BooleanDataType', 'off');
s = [mdl '/Turkce_Modul'];
add_block('simulink/Ports & Subsystems/Subsystem', s, 'Position', [300 60 520 180]);
Simulink.SubSystem.deleteContents(s);

% --- kok: girisler / cikislar ---
add_block('simulink/Sources/In1', [mdl '/komut'], 'Port', '1', 'Interpolate', 'off', 'Position', [60 70 90 84]);
add_line(mdl, 'komut/1', 'Turkce_Modul/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [mdl '/sicaklik'], 'Port', '2', 'Interpolate', 'off', 'Position', [60 110 90 124]);
add_line(mdl, 'sicaklik/1', 'Turkce_Modul/2', 'autorouting', 'on');

% --- ana alt sistem: girisler, kalici durum, deyim alt sistemleri ---
add_block('simulink/Sources/In1', [s '/in_komut'], 'Port', '1', 'Position', [20 90 50 104]);
add_block('simulink/Sources/In1', [s '/in_sicaklik'], 'Port', '2', 'Position', [20 140 50 154]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_durum'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [140 40 180 70]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_cikis'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [140 90 180 120]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_ilk_cevrim'], 'InitialCondition', '1.0', 'SampleTime', '0.01', 'Position', [140 140 180 170]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_sayac'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [140 190 180 220]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_WAIT_s21_1_on'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [140 240 180 270]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_WAIT_s21_1_et'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [140 290 180 320]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_WAIT_s21_1_done'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [140 340 180 370]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_deger'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [140 390 180 420]);
add_block('simulink/Ports & Subsystems/Subsystem', [s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'Position', [320 40 500 568]);
Simulink.SubSystem.deleteContents([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK']);
add_block('simulink/Ports & Subsystems/Subsystem', [s '/Cevrim_sonu_durum_guncelleme'], 'Position', [580 40 760 100]);
Simulink.SubSystem.deleteContents([s '/Cevrim_sonu_durum_guncelleme']);
add_block('simulink/Sinks/Out1', [s '/out_durum'], 'Port', '1', 'Position', [900 90 930 104]);
add_block('simulink/Sinks/Out1', [mdl '/durum'], 'Port', '1', 'Position', [640 70 670 84]);
add_line(mdl, 'Turkce_Modul/1', 'durum/1', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [s '/out_cikis'], 'Port', '2', 'Position', [900 140 930 154]);
add_block('simulink/Sinks/Out1', [mdl '/cikis'], 'Port', '2', 'Position', [640 110 670 124]);
add_line(mdl, 'Turkce_Modul/2', 'cikis/1', 'autorouting', 'on');

% --- deyim alt sistemlerinin icerigi ---
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/not_30'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [270 40 320 70]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/rel_19'], 'Operator', '==', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [270 110 320 140]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/rel_10'], 'Operator', '>', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [270 180 320 210]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/rel_7'], 'Operator', '==', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [270 250 320 280]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/and_11'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [420 40 470 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/not_17'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [570 40 620 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/and_20'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [720 40 770 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/and_31'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [870 40 920 70]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_32'], 'Criteria', 'u2 ~= 0', 'Position', [1020 40 1070 80]);
add_block('simulink/Math Operations/Sum', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sum_26'], 'Inputs', '++', 'Position', [270 320 320 350]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_27'], 'Criteria', 'u2 ~= 0', 'Position', [420 110 470 150]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_28'], 'Criteria', 'u2 ~= 0', 'Position', [570 110 620 150]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_29'], 'Criteria', 'u2 ~= 0', 'Position', [870 110 920 150]);
add_block('simulink/Math Operations/Sum', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sum_36'], 'Inputs', '++', 'Position', [1020 110 1070 140]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/rel_37'], 'Operator', '>=', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1170 40 1220 70]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/rel_38'], 'Operator', '~=', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1170 110 1220 140]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/or_39'], 'Operator', 'OR', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1320 40 1370 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/and_40'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1470 40 1520 70]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_41'], 'Criteria', 'u2 ~= 0', 'Position', [1620 40 1670 80]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_33'], 'Criteria', 'u2 ~= 0', 'Position', [870 180 920 220]);
add_block('simulink/Math Operations/Sum', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sum_14'], 'Inputs', '++', 'Position', [270 390 320 420]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_15'], 'Criteria', 'u2 ~= 0', 'Position', [570 180 620 220]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/not_57'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [420 180 470 210]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/and_58'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [720 110 770 140]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_59'], 'Criteria', 'u2 ~= 0', 'Position', [870 250 920 290]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_16'], 'Criteria', 'u2 ~= 0', 'Position', [720 180 770 220]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/not_42'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1470 110 1520 140]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/and_43'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1620 110 1670 140]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/not_45'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1770 40 1820 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/and_46'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1920 40 1970 70]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_47'], 'Criteria', 'u2 ~= 0', 'Position', [2070 40 2120 80]);
add_block('simulink/Math Operations/Product', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/prod_48'], 'Inputs', '**', 'Position', [2220 40 2270 70]);
add_block('simulink/Math Operations/Sum', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sum_49'], 'Inputs', '++', 'Position', [2370 40 2420 70]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_50'], 'Criteria', 'u2 ~= 0', 'Position', [2520 40 2570 80]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_51'], 'Criteria', 'u2 ~= 0', 'Position', [2670 40 2720 80]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/rel_52'], 'Operator', '~=', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [2820 40 2870 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/not_53'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [2970 40 3020 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/and_54'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [3120 40 3170 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/and_55'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [3270 40 3320 70]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_56'], 'Criteria', 'u2 ~= 0', 'Position', [3420 40 3470 80]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_61'], 'Criteria', 'u2 ~= 0', 'Position', [3570 40 3620 80]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_12'], 'Criteria', 'u2 ~= 0', 'Position', [570 250 620 290]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_21'], 'Criteria', 'u2 ~= 0', 'Position', [870 320 920 360]);
add_block('simulink/Signal Routing/Switch', [[s '/Cevrim_sonu_durum_guncelleme'] '/sw_62'], 'Criteria', 'u2 ~= 0', 'Position', [270 40 320 80]);

% --- baglantilar ---
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_WAIT_s21_1_on_22'], 'Port', '1', 'Position', [20 70 50 84]);
add_line(s, 'onceki_WAIT_s21_1_on/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_on_22/1', 'not_30/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/komut_6'], 'Port', '2', 'Position', [20 100 50 114]);
add_line(s, 'in_komut/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'komut_6/1', 'rel_19/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_1'], 'Value', '2.0', 'Position', [190 90 240 108]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_1/1', 'rel_19/2', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sicaklik_8'], 'Port', '3', 'Position', [20 130 50 144]);
add_line(s, 'in_sicaklik/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sicaklik_8/1', 'rel_10/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_2'], 'Value', '50.0', 'Position', [190 90 240 108]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_2/1', 'rel_10/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'komut_6/1', 'rel_7/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_3'], 'Value', '1.0', 'Position', [190 90 240 108]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_3/1', 'rel_7/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'rel_7/1', 'and_11/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'rel_10/1', 'and_11/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_11/1', 'not_17/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'not_17/1', 'and_20/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'rel_19/1', 'and_20/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_20/1', 'and_31/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'not_30/1', 'and_31/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_31/1', 'sw_32/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_4'], 'Value', '0.0', 'Position', [940 65 990 83]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_4/1', 'sw_32/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_WAIT_s21_1_done_24'], 'Port', '4', 'Position', [20 160 50 174]);
add_line(s, 'onceki_WAIT_s21_1_done/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/4', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_done_24/1', 'sw_32/3', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_WAIT_s21_1_et_23'], 'Port', '5', 'Position', [20 190 50 204]);
add_line(s, 'onceki_WAIT_s21_1_et/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/5', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_et_23/1', 'sum_26/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_5'], 'Value', '10.0', 'Position', [190 90 240 108]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_5/1', 'sum_26/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_done_24/1', 'sw_27/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_et_23/1', 'sw_27/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sum_26/1', 'sw_27/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_on_22/1', 'sw_28/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_27/1', 'sw_28/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_6'], 'Value', '0.0', 'Position', [490 115 540 133]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_6/1', 'sw_28/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_20/1', 'sw_29/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_28/1', 'sw_29/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_et_23/1', 'sw_29/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_29/1', 'sum_36/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_7'], 'Value', '1e-09', 'Position', [940 90 990 108]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_7/1', 'sum_36/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sum_36/1', 'rel_37/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_8'], 'Value', '30.0', 'Position', [1090 90 1140 108]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_8/1', 'rel_37/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_32/1', 'rel_38/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_9'], 'Value', '0.0', 'Position', [1090 90 1140 108]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_9/1', 'rel_38/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'rel_38/1', 'or_39/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'rel_37/1', 'or_39/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_20/1', 'and_40/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'or_39/1', 'and_40/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_40/1', 'sw_41/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_10'], 'Value', '1.0', 'Position', [1540 65 1590 83]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_10/1', 'sw_41/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_32/1', 'sw_41/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_20/1', 'sw_33/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_11'], 'Value', '1.0', 'Position', [790 65 840 83]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_11/1', 'sw_33/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_on_22/1', 'sw_33/3', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/o_ara_20_20'], 'Port', '1', 'Position', [870 70 900 84]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_20/1', 'o_ara_20_20/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/Cevrim_sonu_durum_guncelleme'] '/ara_20_20'], 'Port', '1', 'Position', [20 70 50 84]);
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/1', 'Cevrim_sonu_durum_guncelleme/1', 'autorouting', 'on');
add_line([s '/Cevrim_sonu_durum_guncelleme'], 'ara_20_20/1', 'sw_62/2', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/o_ara_33_33'], 'Port', '2', 'Position', [1020 100 1050 114]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_33/1', 'o_ara_33_33/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/Cevrim_sonu_durum_guncelleme'] '/ara_33_33'], 'Port', '2', 'Position', [20 100 50 114]);
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/2', 'Cevrim_sonu_durum_guncelleme/2', 'autorouting', 'on');
add_line([s '/Cevrim_sonu_durum_guncelleme'], 'ara_33_33/1', 'sw_62/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/Cevrim_sonu_durum_guncelleme'] '/k_12'], 'Value', '0.0', 'Position', [190 115 240 133]);
add_line([s '/Cevrim_sonu_durum_guncelleme'], 'k_12/1', 'sw_62/3', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_sayac_13'], 'Port', '6', 'Position', [20 220 50 234]);
add_line(s, 'onceki_sayac/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/6', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_sayac_13/1', 'sum_14/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_13'], 'Value', '1.0', 'Position', [190 90 240 108]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_13/1', 'sum_14/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_11/1', 'sw_15/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sum_14/1', 'sw_15/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_sayac_13/1', 'sw_15/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'rel_19/1', 'not_57/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'not_17/1', 'and_58/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'not_57/1', 'and_58/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_58/1', 'sw_59/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_14'], 'Value', '0.0', 'Position', [790 65 840 83]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_14/1', 'sw_59/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_15/1', 'sw_59/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_11/1', 'sw_16/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_15/1', 'sw_16/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_cikis_1'], 'Port', '7', 'Position', [20 250 50 264]);
add_line(s, 'onceki_cikis/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/7', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_cikis_1/1', 'sw_16/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'or_39/1', 'not_42/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_20/1', 'and_43/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'not_42/1', 'and_43/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_43/1', 'not_45/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_20/1', 'and_46/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'not_45/1', 'and_46/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_46/1', 'sw_47/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sicaklik_8/1', 'sw_47/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_deger_44'], 'Port', '8', 'Position', [20 280 50 294]);
add_line(s, 'onceki_deger/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/8', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_deger_44/1', 'sw_47/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_47/1', 'prod_48/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_15'], 'Value', '2.0', 'Position', [2140 90 2190 108]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_15/1', 'prod_48/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'prod_48/1', 'sum_49/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_16'], 'Value', '50.0', 'Position', [2290 90 2340 108]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_16/1', 'sum_49/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_46/1', 'sw_50/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sum_49/1', 'sw_50/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_17'], 'Value', 'NaN', 'Position', [2440 115 2490 133]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_17/1', 'sw_50/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_20/1', 'sw_51/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_50/1', 'sw_51/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_18'], 'Value', 'NaN', 'Position', [2590 115 2640 133]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_18/1', 'sw_51/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_51/1', 'rel_52/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_51/1', 'rel_52/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'rel_52/1', 'not_53/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_20/1', 'and_54/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'not_53/1', 'and_54/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_54/1', 'and_55/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'not_45/1', 'and_55/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_55/1', 'sw_56/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_51/1', 'sw_56/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_16/1', 'sw_56/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_58/1', 'sw_61/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_19'], 'Value', '3.0', 'Position', [3490 65 3540 83]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_19/1', 'sw_61/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_56/1', 'sw_61/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_11/1', 'sw_12/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_20'], 'Value', '1.0', 'Position', [490 65 540 83]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_20/1', 'sw_12/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_durum_0'], 'Port', '9', 'Position', [20 310 50 324]);
add_line(s, 'onceki_durum/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/9', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_durum_0/1', 'sw_12/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_20/1', 'sw_21/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_21'], 'Value', '0.0', 'Position', [790 65 840 83]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_21/1', 'sw_21/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_12/1', 'sw_21/3', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/o_durum_21'], 'Port', '3', 'Position', [1020 130 1050 144]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_21/1', 'o_durum_21/1', 'autorouting', 'on');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/3', 'onceki_durum/1', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/o_cikis_61'], 'Port', '4', 'Position', [3720 160 3750 174]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_61/1', 'o_cikis_61/1', 'autorouting', 'on');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/4', 'onceki_cikis/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_22'], 'Value', '0.0', 'Position', [60 40 110 58]);
add_line(s, 'k_22/1', 'onceki_ilk_cevrim/1', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/o_sayac_59'], 'Port', '5', 'Position', [1020 190 1050 204]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_59/1', 'o_sayac_59/1', 'autorouting', 'on');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/5', 'onceki_sayac/1', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/Cevrim_sonu_durum_guncelleme'] '/o_ara_62_62'], 'Port', '1', 'Position', [420 70 450 84]);
add_line([s '/Cevrim_sonu_durum_guncelleme'], 'sw_62/1', 'o_ara_62_62/1', 'autorouting', 'on');
add_line(s, 'Cevrim_sonu_durum_guncelleme/1', 'onceki_WAIT_s21_1_on/1', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/o_ara_29_29'], 'Port', '6', 'Position', [1020 220 1050 234]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_29/1', 'o_ara_29_29/1', 'autorouting', 'on');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/6', 'onceki_WAIT_s21_1_et/1', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/o_ara_41_41'], 'Port', '7', 'Position', [1770 250 1800 264]);
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_41/1', 'o_ara_41_41/1', 'autorouting', 'on');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/7', 'onceki_WAIT_s21_1_done/1', 'autorouting', 'on');
add_line(s, 'onceki_deger/1', 'onceki_deger/1', 'autorouting', 'on');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/3', 'out_durum/1', 'autorouting', 'on');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/4', 'out_cikis/1', 'autorouting', 'on');

% --- yerlesim ---
try
    Simulink.BlockDiagram.arrangeSystem([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK']);
    Simulink.BlockDiagram.arrangeSystem([s '/Cevrim_sonu_durum_guncelleme']);
    Simulink.BlockDiagram.arrangeSystem(s);
catch
end
if kaydet
    save_system(mdl, [mdl '.slx']);
    fprintf('Kaydedildi: %s.slx\n', mdl);
end
end
