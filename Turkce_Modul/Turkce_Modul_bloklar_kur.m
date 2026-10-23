function Turkce_Modul_bloklar_kur(kaydet)
%% Turkce_Modul_bloklar_kur - pseudocode algoritmasini STANDART Simulink bloklariyla kurar
%%
%% pseudoval tarafindan turkce_adlar.pseudo dosyasindan uretilmistir.
%% S-Function YOKTUR: algoritma Sum / Product / Relational Operator /
%% Logical Operator / Switch / Unit Delay ... bloklarindan olusur;
%% Simulink Design Verifier ve kod uretimi dogrudan calisir.
%%
%% Kullanim:
%%   >> Turkce_Modul_bloklar_kur          %% modeli kurar ve Turkce_Modul_bloklar.slx kaydeder
%%   >> sim('Turkce_Modul_bloklar')

if nargin < 1, kaydet = true; end
mdl = 'Turkce_Modul_bloklar';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
set_param(mdl, 'Solver', 'FixedStepDiscrete', 'FixedStep', '0.01', 'StopTime', '10');
% mantik bloklarinin cikisi double (C ile ayni 0 / 1)
set_param(mdl, 'BooleanDataType', 'off');
s = [mdl '/Turkce_Modul'];
add_block('simulink/Ports & Subsystems/Subsystem', s, 'Position', [300 80 520 200]);
Simulink.SubSystem.deleteContents(s);
set_param(s, 'TreatAsAtomicUnit', 'on');

% --- girisler / cikislar (kok ve alt sistem) ---
add_block('simulink/Sources/In1', [mdl '/komut'], 'Port', '1', 'Interpolate', 'off', 'Position', [40 90 70 104]);
add_block('simulink/Sources/In1', [s '/in_komut'], 'Port', '1', 'Position', [20 180 50 194]);
add_block('simulink/Sources/In1', [mdl '/sicaklik'], 'Port', '2', 'Interpolate', 'off', 'Position', [40 140 70 154]);
add_block('simulink/Sources/In1', [s '/in_sicaklik'], 'Port', '2', 'Position', [20 280 50 294]);
add_block('simulink/Sinks/Out1', [mdl '/durum'], 'Port', '1', 'Position', [700 90 730 104]);
add_block('simulink/Sinks/Out1', [mdl '/cikis'], 'Port', '2', 'Position', [700 140 730 154]);
add_block('simulink/Sinks/Out1', [s '/out_durum'], 'Port', '1', 'Position', [4060 80 4090 94]);
add_block('simulink/Sinks/Out1', [s '/out_cikis'], 'Port', '2', 'Position', [4060 160 4090 174]);

% --- algoritma ---
add_block('simulink/Discrete/Unit Delay', [s '/onceki_ilk_cevrim'], 'InitialCondition', '1.0', 'SampleTime', '0.01', 'Position', [80 40 130 70]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_deger'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [80 110 130 140]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_WAIT_s21_1_done'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [80 180 130 210]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_WAIT_s21_1_on'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [80 250 130 280]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_WAIT_s21_1_et'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [80 460 130 490]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_sayac'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [80 530 130 560]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_cikis'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [80 600 130 630]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_durum'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [80 670 130 700]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/not_30_s21'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [240 40 290 70]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [s '/rel_19_s15'], 'Operator', '==', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [240 110 290 140]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [s '/rel_10_s15'], 'Operator', '>', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [240 180 290 210]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [s '/rel_7_s15'], 'Operator', '==', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [240 250 290 280]);
add_block('simulink/Math Operations/Sum', [s '/sum_26_s21'], 'Inputs', '++', 'Position', [240 320 290 350]);
add_block('simulink/Math Operations/Sum', [s '/sum_14_s17'], 'Inputs', '++', 'Position', [240 390 290 420]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/and_11_s15'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [400 40 450 70]);
add_block('simulink/Signal Routing/Switch', [s '/sw_27_s21'], 'Criteria', 'u2 ~= 0', 'Position', [400 110 450 150]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/not_57_s15'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [400 180 450 210]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/not_17_s15'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [560 40 610 70]);
add_block('simulink/Signal Routing/Switch', [s '/sw_28_s21'], 'Criteria', 'u2 ~= 0', 'Position', [560 110 610 150]);
add_block('simulink/Signal Routing/Switch', [s '/sw_15_s17'], 'Criteria', 'u2 ~= 0', 'Position', [560 180 610 220]);
add_block('simulink/Signal Routing/Switch', [s '/sw_12_s16'], 'Criteria', 'u2 ~= 0', 'Position', [560 250 610 290]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/and_20_s15'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [720 40 770 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/and_58_s15'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [720 110 770 140]);
add_block('simulink/Signal Routing/Switch', [s '/sw_16_s18'], 'Criteria', 'u2 ~= 0', 'Position', [720 180 770 220]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/and_31_s21'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [880 40 930 70]);
add_block('simulink/Signal Routing/Switch', [s '/sw_29_s21'], 'Criteria', 'u2 ~= 0', 'Position', [880 110 930 150]);
add_block('simulink/Signal Routing/Switch', [s '/sw_33_s21'], 'Criteria', 'u2 ~= 0', 'Position', [880 180 930 220]);
add_block('simulink/Signal Routing/Switch', [s '/sw_59_s24'], 'Criteria', 'u2 ~= 0', 'Position', [880 250 930 290]);
add_block('simulink/Signal Routing/Switch', [s '/sw_21_s20'], 'Criteria', 'u2 ~= 0', 'Position', [880 320 930 360]);
add_block('simulink/Signal Routing/Switch', [s '/sw_32_s21'], 'Criteria', 'u2 ~= 0', 'Position', [1040 40 1090 80]);
add_block('simulink/Math Operations/Sum', [s '/sum_36_s21'], 'Inputs', '++', 'Position', [1040 110 1090 140]);
add_block('simulink/Signal Routing/Switch', [s '/sw_62'], 'Criteria', 'u2 ~= 0', 'Position', [1040 180 1090 220]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [s '/rel_37_s21'], 'Operator', '>=', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1200 40 1250 70]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [s '/rel_38_s21'], 'Operator', '~=', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1200 110 1250 140]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/or_39_s21'], 'Operator', 'OR', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1360 40 1410 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/and_40_s21'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1520 40 1570 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/not_42_s21'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1520 110 1570 140]);
add_block('simulink/Signal Routing/Switch', [s '/sw_41_s21'], 'Criteria', 'u2 ~= 0', 'Position', [1680 40 1730 80]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/and_43_s21'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1680 110 1730 140]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/not_45_s22'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [1840 40 1890 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/and_46_s22'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [2000 40 2050 70]);
add_block('simulink/Signal Routing/Switch', [s '/sw_47_s22'], 'Criteria', 'u2 ~= 0', 'Position', [2160 40 2210 80]);
add_block('simulink/Math Operations/Product', [s '/prod_48_s31'], 'Inputs', '**', 'Position', [2320 40 2370 70]);
add_block('simulink/Math Operations/Sum', [s '/sum_49_s31'], 'Inputs', '++', 'Position', [2480 40 2530 70]);
add_block('simulink/Signal Routing/Switch', [s '/sw_50_s31'], 'Criteria', 'u2 ~= 0', 'Position', [2640 40 2690 80]);
add_block('simulink/Signal Routing/Switch', [s '/sw_51_s22'], 'Criteria', 'u2 ~= 0', 'Position', [2800 40 2850 80]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [s '/rel_52_s22'], 'Operator', '~=', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [2960 40 3010 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/not_53_s22'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [3120 40 3170 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/and_54_s22'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [3280 40 3330 70]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [s '/and_55_s22'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)', 'Position', [3440 40 3490 70]);
add_block('simulink/Signal Routing/Switch', [s '/sw_56_s22'], 'Criteria', 'u2 ~= 0', 'Position', [3600 40 3650 80]);
add_block('simulink/Signal Routing/Switch', [s '/sw_61_s25'], 'Criteria', 'u2 ~= 0', 'Position', [3760 40 3810 80]);

% --- baglantilar ---
add_line(s, 'onceki_WAIT_s21_1_on/1', 'not_30_s21/1', 'autorouting', 'on');
add_line(s, 'in_komut/1', 'rel_19_s15/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_1'], 'Value', '2.0', 'Position', [170 130 220 148]);
add_line(s, 'k_1/1', 'rel_19_s15/2', 'autorouting', 'on');
add_line(s, 'in_sicaklik/1', 'rel_10_s15/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_2'], 'Value', '50.0', 'Position', [170 200 220 218]);
add_line(s, 'k_2/1', 'rel_10_s15/2', 'autorouting', 'on');
add_line(s, 'in_komut/1', 'rel_7_s15/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_3'], 'Value', '1.0', 'Position', [170 270 220 288]);
add_line(s, 'k_3/1', 'rel_7_s15/2', 'autorouting', 'on');
add_line(s, 'onceki_WAIT_s21_1_et/1', 'sum_26_s21/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_4'], 'Value', '10.0', 'Position', [170 340 220 358]);
add_line(s, 'k_4/1', 'sum_26_s21/2', 'autorouting', 'on');
add_line(s, 'onceki_sayac/1', 'sum_14_s17/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_5'], 'Value', '1.0', 'Position', [170 410 220 428]);
add_line(s, 'k_5/1', 'sum_14_s17/2', 'autorouting', 'on');
add_line(s, 'rel_7_s15/1', 'and_11_s15/1', 'autorouting', 'on');
add_line(s, 'rel_10_s15/1', 'and_11_s15/2', 'autorouting', 'on');
add_line(s, 'onceki_WAIT_s21_1_done/1', 'sw_27_s21/2', 'autorouting', 'on');
add_line(s, 'onceki_WAIT_s21_1_et/1', 'sw_27_s21/1', 'autorouting', 'on');
add_line(s, 'sum_26_s21/1', 'sw_27_s21/3', 'autorouting', 'on');
add_line(s, 'rel_19_s15/1', 'not_57_s15/1', 'autorouting', 'on');
add_line(s, 'and_11_s15/1', 'not_17_s15/1', 'autorouting', 'on');
add_line(s, 'onceki_WAIT_s21_1_on/1', 'sw_28_s21/2', 'autorouting', 'on');
add_line(s, 'sw_27_s21/1', 'sw_28_s21/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_6'], 'Value', '0.0', 'Position', [490 150 540 168]);
add_line(s, 'k_6/1', 'sw_28_s21/3', 'autorouting', 'on');
add_line(s, 'and_11_s15/1', 'sw_15_s17/2', 'autorouting', 'on');
add_line(s, 'sum_14_s17/1', 'sw_15_s17/1', 'autorouting', 'on');
add_line(s, 'onceki_sayac/1', 'sw_15_s17/3', 'autorouting', 'on');
add_line(s, 'and_11_s15/1', 'sw_12_s16/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_7'], 'Value', '1.0', 'Position', [490 250 540 268]);
add_line(s, 'k_7/1', 'sw_12_s16/1', 'autorouting', 'on');
add_line(s, 'onceki_durum/1', 'sw_12_s16/3', 'autorouting', 'on');
add_line(s, 'not_17_s15/1', 'and_20_s15/1', 'autorouting', 'on');
add_line(s, 'rel_19_s15/1', 'and_20_s15/2', 'autorouting', 'on');
add_line(s, 'not_17_s15/1', 'and_58_s15/1', 'autorouting', 'on');
add_line(s, 'not_57_s15/1', 'and_58_s15/2', 'autorouting', 'on');
add_line(s, 'and_11_s15/1', 'sw_16_s18/2', 'autorouting', 'on');
add_line(s, 'sw_15_s17/1', 'sw_16_s18/1', 'autorouting', 'on');
add_line(s, 'onceki_cikis/1', 'sw_16_s18/3', 'autorouting', 'on');
add_line(s, 'and_20_s15/1', 'and_31_s21/1', 'autorouting', 'on');
add_line(s, 'not_30_s21/1', 'and_31_s21/2', 'autorouting', 'on');
add_line(s, 'and_20_s15/1', 'sw_29_s21/2', 'autorouting', 'on');
add_line(s, 'sw_28_s21/1', 'sw_29_s21/1', 'autorouting', 'on');
add_line(s, 'onceki_WAIT_s21_1_et/1', 'sw_29_s21/3', 'autorouting', 'on');
add_line(s, 'and_20_s15/1', 'sw_33_s21/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_8'], 'Value', '1.0', 'Position', [810 180 860 198]);
add_line(s, 'k_8/1', 'sw_33_s21/1', 'autorouting', 'on');
add_line(s, 'onceki_WAIT_s21_1_on/1', 'sw_33_s21/3', 'autorouting', 'on');
add_line(s, 'and_58_s15/1', 'sw_59_s24/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_9'], 'Value', '0.0', 'Position', [810 250 860 268]);
add_line(s, 'k_9/1', 'sw_59_s24/1', 'autorouting', 'on');
add_line(s, 'sw_15_s17/1', 'sw_59_s24/3', 'autorouting', 'on');
add_line(s, 'and_20_s15/1', 'sw_21_s20/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_10'], 'Value', '0.0', 'Position', [810 320 860 338]);
add_line(s, 'k_10/1', 'sw_21_s20/1', 'autorouting', 'on');
add_line(s, 'sw_12_s16/1', 'sw_21_s20/3', 'autorouting', 'on');
add_line(s, 'and_31_s21/1', 'sw_32_s21/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_11'], 'Value', '0.0', 'Position', [970 40 1020 58]);
add_line(s, 'k_11/1', 'sw_32_s21/1', 'autorouting', 'on');
add_line(s, 'onceki_WAIT_s21_1_done/1', 'sw_32_s21/3', 'autorouting', 'on');
add_line(s, 'sw_29_s21/1', 'sum_36_s21/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_12'], 'Value', '1e-09', 'Position', [970 130 1020 148]);
add_line(s, 'k_12/1', 'sum_36_s21/2', 'autorouting', 'on');
add_line(s, 'and_20_s15/1', 'sw_62/2', 'autorouting', 'on');
add_line(s, 'sw_33_s21/1', 'sw_62/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_13'], 'Value', '0.0', 'Position', [970 220 1020 238]);
add_line(s, 'k_13/1', 'sw_62/3', 'autorouting', 'on');
add_line(s, 'sum_36_s21/1', 'rel_37_s21/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_14'], 'Value', '30.0', 'Position', [1130 60 1180 78]);
add_line(s, 'k_14/1', 'rel_37_s21/2', 'autorouting', 'on');
add_line(s, 'sw_32_s21/1', 'rel_38_s21/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_15'], 'Value', '0.0', 'Position', [1130 130 1180 148]);
add_line(s, 'k_15/1', 'rel_38_s21/2', 'autorouting', 'on');
add_line(s, 'rel_38_s21/1', 'or_39_s21/1', 'autorouting', 'on');
add_line(s, 'rel_37_s21/1', 'or_39_s21/2', 'autorouting', 'on');
add_line(s, 'and_20_s15/1', 'and_40_s21/1', 'autorouting', 'on');
add_line(s, 'or_39_s21/1', 'and_40_s21/2', 'autorouting', 'on');
add_line(s, 'or_39_s21/1', 'not_42_s21/1', 'autorouting', 'on');
add_line(s, 'and_40_s21/1', 'sw_41_s21/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_16'], 'Value', '1.0', 'Position', [1610 40 1660 58]);
add_line(s, 'k_16/1', 'sw_41_s21/1', 'autorouting', 'on');
add_line(s, 'sw_32_s21/1', 'sw_41_s21/3', 'autorouting', 'on');
add_line(s, 'and_20_s15/1', 'and_43_s21/1', 'autorouting', 'on');
add_line(s, 'not_42_s21/1', 'and_43_s21/2', 'autorouting', 'on');
add_line(s, 'and_43_s21/1', 'not_45_s22/1', 'autorouting', 'on');
add_line(s, 'and_20_s15/1', 'and_46_s22/1', 'autorouting', 'on');
add_line(s, 'not_45_s22/1', 'and_46_s22/2', 'autorouting', 'on');
add_line(s, 'and_46_s22/1', 'sw_47_s22/2', 'autorouting', 'on');
add_line(s, 'in_sicaklik/1', 'sw_47_s22/1', 'autorouting', 'on');
add_line(s, 'onceki_deger/1', 'sw_47_s22/3', 'autorouting', 'on');
add_line(s, 'sw_47_s22/1', 'prod_48_s31/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_17'], 'Value', '2.0', 'Position', [2250 60 2300 78]);
add_line(s, 'k_17/1', 'prod_48_s31/2', 'autorouting', 'on');
add_line(s, 'prod_48_s31/1', 'sum_49_s31/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_18'], 'Value', '50.0', 'Position', [2410 60 2460 78]);
add_line(s, 'k_18/1', 'sum_49_s31/2', 'autorouting', 'on');
add_line(s, 'and_46_s22/1', 'sw_50_s31/2', 'autorouting', 'on');
add_line(s, 'sum_49_s31/1', 'sw_50_s31/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_19'], 'Value', 'NaN', 'Position', [2570 80 2620 98]);
add_line(s, 'k_19/1', 'sw_50_s31/3', 'autorouting', 'on');
add_line(s, 'and_20_s15/1', 'sw_51_s22/2', 'autorouting', 'on');
add_line(s, 'sw_50_s31/1', 'sw_51_s22/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_20'], 'Value', 'NaN', 'Position', [2730 80 2780 98]);
add_line(s, 'k_20/1', 'sw_51_s22/3', 'autorouting', 'on');
add_line(s, 'sw_51_s22/1', 'rel_52_s22/1', 'autorouting', 'on');
add_line(s, 'sw_51_s22/1', 'rel_52_s22/2', 'autorouting', 'on');
add_line(s, 'rel_52_s22/1', 'not_53_s22/1', 'autorouting', 'on');
add_line(s, 'and_20_s15/1', 'and_54_s22/1', 'autorouting', 'on');
add_line(s, 'not_53_s22/1', 'and_54_s22/2', 'autorouting', 'on');
add_line(s, 'and_54_s22/1', 'and_55_s22/1', 'autorouting', 'on');
add_line(s, 'not_45_s22/1', 'and_55_s22/2', 'autorouting', 'on');
add_line(s, 'and_55_s22/1', 'sw_56_s22/2', 'autorouting', 'on');
add_line(s, 'sw_51_s22/1', 'sw_56_s22/1', 'autorouting', 'on');
add_line(s, 'sw_16_s18/1', 'sw_56_s22/3', 'autorouting', 'on');
add_line(s, 'and_58_s15/1', 'sw_61_s25/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_21'], 'Value', '3.0', 'Position', [3690 40 3740 58]);
add_line(s, 'k_21/1', 'sw_61_s25/1', 'autorouting', 'on');
add_line(s, 'sw_56_s22/1', 'sw_61_s25/3', 'autorouting', 'on');
add_line(s, 'sw_21_s20/1', 'onceki_durum/1', 'autorouting', 'on');
add_line(s, 'sw_61_s25/1', 'onceki_cikis/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [s '/k_22'], 'Value', '0.0', 'Position', [10 40 60 58]);
add_line(s, 'k_22/1', 'onceki_ilk_cevrim/1', 'autorouting', 'on');
add_line(s, 'sw_59_s24/1', 'onceki_sayac/1', 'autorouting', 'on');
add_line(s, 'sw_62/1', 'onceki_WAIT_s21_1_on/1', 'autorouting', 'on');
add_line(s, 'sw_29_s21/1', 'onceki_WAIT_s21_1_et/1', 'autorouting', 'on');
add_line(s, 'sw_41_s21/1', 'onceki_WAIT_s21_1_done/1', 'autorouting', 'on');
add_line(s, 'onceki_deger/1', 'onceki_deger/1', 'autorouting', 'on');
add_line(s, 'sw_21_s20/1', 'out_durum/1', 'autorouting', 'on');
add_line(s, 'sw_61_s25/1', 'out_cikis/1', 'autorouting', 'on');
add_line(mdl, 'komut/1', 'Turkce_Modul/1', 'autorouting', 'on');
add_line(mdl, 'sicaklik/1', 'Turkce_Modul/2', 'autorouting', 'on');
add_line(mdl, 'Turkce_Modul/1', 'durum/1', 'autorouting', 'on');
add_line(mdl, 'Turkce_Modul/2', 'cikis/1', 'autorouting', 'on');

try
    Simulink.BlockDiagram.arrangeSystem(s);
catch
end
if kaydet
    save_system(mdl, [mdl '.slx']);
    fprintf('Kaydedildi: %s.slx\n', mdl);
end
end
