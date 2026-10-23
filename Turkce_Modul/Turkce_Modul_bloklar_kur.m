function Turkce_Modul_bloklar_kur(kaydet)
%% Turkce_Modul_bloklar_kur - pseudocode algoritmasini STANDART Simulink bloklariyla kurar
%%
%% pseudoval tarafindan turkce_adlar.pseudo dosyasindan uretilmistir.
%% S-Function YOKTUR. Ana alt sistemde her pseudocode deyimi
%% yurutme sirasiyla bir alt sistemdir (S03_satir_42_IF_...). Deyimin
%% icinde her kol (THEN / ELSIF / ELSE / CASE / DEFAULT) bir alt
%% sistemdir; kollarin degerleri degisken basina tek Switch ya da
%% Multiport Switch ile birlesir. Kalici degiskenler 'onceki_<ad>'
%% Unit Delay bloklaridir.
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

% --- deyim ve kol alt sistemleri ---
add_block('simulink/Ports & Subsystems/Subsystem', [s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'Position', [760 40 1060 81]);
Simulink.SubSystem.deleteContents([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK']);
add_block('simulink/Ports & Subsystems/Subsystem', [s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK']);
Simulink.SubSystem.deleteContents([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK']);
add_block('simulink/Ports & Subsystems/Subsystem', [s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS']);
Simulink.SubSystem.deleteContents([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS']);
add_block('simulink/Ports & Subsystems/Subsystem', [s '/Cevrim_sonu_durum_guncelleme'], 'Position', [760 121 1060 161]);
Simulink.SubSystem.deleteContents([s '/Cevrim_sonu_durum_guncelleme']);

% --- bloklar ---
add_block('simulink/Discrete/Unit Delay', [s '/onceki_ilk_cevrim'], 'InitialCondition', '1.0', 'SampleTime', '0.01', 'Position', [260 180 300 210]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_WAIT_s21_1_done'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [260 230 300 260]);
add_block('simulink/Discrete/Unit Delay', [s '/onceki_WAIT_s21_1_on'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [260 280 300 310]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/not_22'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sw_23'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Discrete/Unit Delay', [s '/onceki_WAIT_s21_1_et'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [260 330 300 360]);
add_block('simulink/Math Operations/Add', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sum_19'], 'Inputs', '++');
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sw_20'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sw_21'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Math Operations/Add', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sum_26'], 'Inputs', '++');
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/rel_27'], 'Operator', '>=', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/rel_28'], 'Operator', '~=', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/or_29'], 'Operator', 'OR', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sw_30'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/rel_12'], 'Operator', '==', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_44'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/rel_9'], 'Operator', '>', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/rel_6'], 'Operator', '==', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/and_10'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sw_45'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Signal Routing/Multiport Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/mps_51'], 'DataPortOrder', 'One-based contiguous', 'Inputs', '3', 'DataPortForDefault', 'Last data port', 'DiagnosticForDefault', 'None');
add_block('simulink/Signal Routing/Multiport Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/mps_47'], 'DataPortOrder', 'One-based contiguous', 'Inputs', '3', 'DataPortForDefault', 'Last data port', 'DiagnosticForDefault', 'None');
add_block('simulink/Signal Routing/Multiport Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/mps_49'], 'DataPortOrder', 'One-based contiguous', 'Inputs', '3', 'DataPortForDefault', 'Last data port', 'DiagnosticForDefault', 'None');
add_block('simulink/Signal Routing/Multiport Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/mps_50'], 'DataPortOrder', 'One-based contiguous', 'Inputs', '3', 'DataPortForDefault', 'Last data port', 'DiagnosticForDefault', 'None');
add_block('simulink/Signal Routing/Switch', [[s '/Cevrim_sonu_durum_guncelleme'] '/sw_53'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Discrete/Unit Delay', [s '/onceki_sayac'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [260 380 300 410]);
add_block('simulink/Math Operations/Add', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/cikis_14'], 'Inputs', '++');
add_block('simulink/Signal Routing/Multiport Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sayac_46'], 'DataPortOrder', 'One-based contiguous', 'Inputs', '3', 'DataPortForDefault', 'Last data port', 'DiagnosticForDefault', 'None');
add_block('simulink/Discrete/Unit Delay', [s '/onceki_cikis'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [260 430 300 460]);
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sw_33'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Math Operations/Product', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/prod_34'], 'Inputs', '**');
add_block('simulink/Math Operations/Add', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sum_35'], 'Inputs', '++');
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sw_37'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sw_38'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Logic and Bit Operations/Relational Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/rel_39'], 'Operator', '~=', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/not_40'], 'Operator', 'NOT', 'Inputs', '1', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Logic and Bit Operations/Logical Operator', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/and_41'], 'Operator', 'AND', 'Inputs', '2', 'OutDataTypeStr', 'Inherit: Logical (see Configuration Parameters: Optimization)');
add_block('simulink/Signal Routing/Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/cikis_42'], 'Criteria', 'u2 ~= 0');
add_block('simulink/Signal Routing/Multiport Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/cikis_48'], 'DataPortOrder', 'One-based contiguous', 'Inputs', '3', 'DataPortForDefault', 'Last data port', 'DiagnosticForDefault', 'None');
add_block('simulink/Discrete/Unit Delay', [s '/onceki_durum'], 'InitialCondition', '0.0', 'SampleTime', '0.01', 'Position', [260 480 300 510]);
add_block('simulink/Signal Routing/Multiport Switch', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/durum_52'], 'DataPortOrder', 'One-based contiguous', 'Inputs', '3', 'DataPortForDefault', 'Last data port', 'DiagnosticForDefault', 'None');

% --- baglantilar ---
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/onceki_WAIT_s21_1_on_15'], 'Port', '1');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_WAIT_s21_1_on_15'], 'Port', '1');
add_block('simulink/Signal Routing/Goto', [s '/G_onceki_WAIT_s21_1_on_15'], 'GotoTag', 'onceki_WAIT_s21_1_on_15');
add_line(s, 'onceki_WAIT_s21_1_on/1', 'G_onceki_WAIT_s21_1_on_15/1');
add_block('simulink/Signal Routing/From', [s '/F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_15'], 'GotoTag', 'onceki_WAIT_s21_1_on_15');
add_line(s, 'F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_15/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/1');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_on_15/1', 'ELSIF_satir_19_komut_eq_SALIS/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'onceki_WAIT_s21_1_on_15/1', 'not_22/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'not_22/1', 'sw_23/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_1'], 'Value', '0.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_1/1', 'sw_23/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/onceki_WAIT_s21_1_done_17'], 'Port', '2');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_WAIT_s21_1_done_17'], 'Port', '2');
add_block('simulink/Signal Routing/Goto', [s '/G_onceki_WAIT_s21_1_done_17'], 'GotoTag', 'onceki_WAIT_s21_1_done_17');
add_line(s, 'onceki_WAIT_s21_1_done/1', 'G_onceki_WAIT_s21_1_done_17/1');
add_block('simulink/Signal Routing/From', [s '/F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_17'], 'GotoTag', 'onceki_WAIT_s21_1_done_17');
add_line(s, 'F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_17/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/2');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_done_17/1', 'ELSIF_satir_19_komut_eq_SALIS/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'onceki_WAIT_s21_1_done_17/1', 'sw_23/3', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/onceki_WAIT_s21_1_et_16'], 'Port', '3');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_WAIT_s21_1_et_16'], 'Port', '3');
add_block('simulink/Signal Routing/Goto', [s '/G_onceki_WAIT_s21_1_et_16'], 'GotoTag', 'onceki_WAIT_s21_1_et_16');
add_line(s, 'onceki_WAIT_s21_1_et/1', 'G_onceki_WAIT_s21_1_et_16/1');
add_block('simulink/Signal Routing/From', [s '/F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_16'], 'GotoTag', 'onceki_WAIT_s21_1_et_16');
add_line(s, 'F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_16/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/3');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_et_16/1', 'ELSIF_satir_19_komut_eq_SALIS/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'onceki_WAIT_s21_1_et_16/1', 'sum_19/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_2'], 'Value', '10.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_2/1', 'sum_19/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'onceki_WAIT_s21_1_done_17/1', 'sw_20/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'onceki_WAIT_s21_1_et_16/1', 'sw_20/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sum_19/1', 'sw_20/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'onceki_WAIT_s21_1_on_15/1', 'sw_21/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_20/1', 'sw_21/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_3'], 'Value', '0.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_3/1', 'sw_21/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_21/1', 'sum_26/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_4'], 'Value', '1e-09');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_4/1', 'sum_26/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sum_26/1', 'rel_27/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_5'], 'Value', '30.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_5/1', 'rel_27/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_23/1', 'rel_28/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_6'], 'Value', '0.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_6/1', 'rel_28/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'rel_28/1', 'or_29/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'rel_27/1', 'or_29/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'or_29/1', 'sw_30/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_7'], 'Value', '1.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_7/1', 'sw_30/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_23/1', 'sw_30/3', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/komut_5'], 'Port', '4');
add_block('simulink/Signal Routing/Goto', [s '/G_komut_5'], 'GotoTag', 'komut_5');
add_line(s, 'komut/1', 'G_komut_5/1');
add_block('simulink/Signal Routing/From', [s '/F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_5'], 'GotoTag', 'komut_5');
add_line(s, 'F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_5/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/4');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'komut_5/1', 'rel_12/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_8'], 'Value', '2.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_8/1', 'rel_12/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'rel_12/1', 'sw_44/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_9'], 'Value', '2.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_9/1', 'sw_44/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_10'], 'Value', '3.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_10/1', 'sw_44/3', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sicaklik_7'], 'Port', '5');
add_block('simulink/Signal Routing/Goto', [s '/G_sicaklik_7'], 'GotoTag', 'sicaklik_7');
add_line(s, 'sicaklik/1', 'G_sicaklik_7/1');
add_block('simulink/Signal Routing/From', [s '/F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_7'], 'GotoTag', 'sicaklik_7');
add_line(s, 'F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_7/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/5');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sicaklik_7/1', 'rel_9/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_11'], 'Value', '50.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_11/1', 'rel_9/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'komut_5/1', 'rel_6/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_12'], 'Value', '1.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_12/1', 'rel_6/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'rel_6/1', 'and_10/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'rel_9/1', 'and_10/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'and_10/1', 'sw_45/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_13'], 'Value', '1.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_13/1', 'sw_45/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_44/1', 'sw_45/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_45/1', 'mps_51/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_done_17/1', 'mps_51/2', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/ara_30_o30'], 'Port', '1');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_30/1', 'ara_30_o30/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'ELSIF_satir_19_komut_eq_SALIS/1', 'mps_51/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_done_17/1', 'mps_51/4', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_45/1', 'mps_47/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_et_16/1', 'mps_47/2', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/ara_21_o21'], 'Port', '2');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_21/1', 'ara_21_o21/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'ELSIF_satir_19_komut_eq_SALIS/2', 'mps_47/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_et_16/1', 'mps_47/4', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_45/1', 'mps_49/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_on_15/1', 'mps_49/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_14'], 'Value', '1.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_14/1', 'mps_49/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_WAIT_s21_1_on_15/1', 'mps_49/4', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_45/1', 'mps_50/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_15'], 'Value', '0.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_15/1', 'mps_50/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_16'], 'Value', '1.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_16/1', 'mps_50/3', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_17'], 'Value', '0.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_17/1', 'mps_50/4', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/Cevrim_sonu_durum_guncelleme'] '/ara_50_50'], 'Port', '1');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/ara_50_o50'], 'Port', '1');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'mps_50/1', 'ara_50_o50/1', 'autorouting', 'on');
add_block('simulink/Signal Routing/Goto', [s '/G_ara_50_50'], 'GotoTag', 'ara_50_50');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/1', 'G_ara_50_50/1');
add_block('simulink/Signal Routing/From', [s '/F_Cevrim_sonu_durum_guncelleme_50'], 'GotoTag', 'ara_50_50');
add_line(s, 'F_Cevrim_sonu_durum_guncelleme_50/1', 'Cevrim_sonu_durum_guncelleme/1');
add_line([s '/Cevrim_sonu_durum_guncelleme'], 'ara_50_50/1', 'sw_53/2', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/Cevrim_sonu_durum_guncelleme'] '/ara_49_49'], 'Port', '2');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/ara_49_o49'], 'Port', '2');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'mps_49/1', 'ara_49_o49/1', 'autorouting', 'on');
add_block('simulink/Signal Routing/Goto', [s '/G_ara_49_49'], 'GotoTag', 'ara_49_49');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/2', 'G_ara_49_49/1');
add_block('simulink/Signal Routing/From', [s '/F_Cevrim_sonu_durum_guncelleme_49'], 'GotoTag', 'ara_49_49');
add_line(s, 'F_Cevrim_sonu_durum_guncelleme_49/1', 'Cevrim_sonu_durum_guncelleme/2');
add_line([s '/Cevrim_sonu_durum_guncelleme'], 'ara_49_49/1', 'sw_53/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/Cevrim_sonu_durum_guncelleme'] '/k_18'], 'Value', '0.0');
add_line([s '/Cevrim_sonu_durum_guncelleme'], 'k_18/1', 'sw_53/3', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_sayac_13'], 'Port', '1');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_sayac_13'], 'Port', '6');
add_block('simulink/Signal Routing/Goto', [s '/G_onceki_sayac_13'], 'GotoTag', 'onceki_sayac_13');
add_line(s, 'onceki_sayac/1', 'G_onceki_sayac_13/1');
add_block('simulink/Signal Routing/From', [s '/F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_13'], 'GotoTag', 'onceki_sayac_13');
add_line(s, 'F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_13/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/6');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_sayac_13/1', 'THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_sayac_13/1', 'cikis_14/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_19'], 'Value', '1.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_19/1', 'cikis_14/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_45/1', 'sayac_46/1', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/cikis_o14'], 'Port', '1');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'cikis_14/1', 'cikis_o14/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK/1', 'sayac_46/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_sayac_13/1', 'sayac_46/3', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_20'], 'Value', '0.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_20/1', 'sayac_46/4', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'or_29/1', 'sw_33/2', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/sicaklik_7'], 'Port', '4');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sicaklik_7/1', 'ELSIF_satir_19_komut_eq_SALIS/4', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sicaklik_7/1', 'sw_33/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_21'], 'Value', '0.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_21/1', 'sw_33/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_33/1', 'prod_34/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_22'], 'Value', '2.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_22/1', 'prod_34/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'prod_34/1', 'sum_35/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_23'], 'Value', '50.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_23/1', 'sum_35/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'or_29/1', 'sw_37/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sum_35/1', 'sw_37/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_24'], 'Value', 'NaN');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_24/1', 'sw_37/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'or_29/1', 'sw_38/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_37/1', 'sw_38/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/k_25'], 'Value', 'NaN');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'k_25/1', 'sw_38/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_38/1', 'rel_39/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_38/1', 'rel_39/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'rel_39/1', 'not_40/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'not_40/1', 'and_41/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'or_29/1', 'and_41/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'and_41/1', 'cikis_42/2', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'sw_38/1', 'cikis_42/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/onceki_cikis_1'], 'Port', '5');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_cikis_1'], 'Port', '7');
add_block('simulink/Signal Routing/Goto', [s '/G_onceki_cikis_1'], 'GotoTag', 'onceki_cikis_1');
add_line(s, 'onceki_cikis/1', 'G_onceki_cikis_1/1');
add_block('simulink/Signal Routing/From', [s '/F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_1'], 'GotoTag', 'onceki_cikis_1');
add_line(s, 'F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_1/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/7');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_cikis_1/1', 'ELSIF_satir_19_komut_eq_SALIS/5', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'onceki_cikis_1/1', 'cikis_42/3', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_45/1', 'cikis_48/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK/1', 'cikis_48/2', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'] '/cikis_o42'], 'Port', '3');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS'], 'cikis_42/1', 'cikis_o42/1', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'ELSIF_satir_19_komut_eq_SALIS/3', 'cikis_48/3', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_26'], 'Value', '3.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_26/1', 'cikis_48/4', 'autorouting', 'on');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sw_45/1', 'durum_52/1', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_27'], 'Value', '1.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_27/1', 'durum_52/2', 'autorouting', 'on');
add_block('simulink/Sources/Constant', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/k_28'], 'Value', '0.0');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'k_28/1', 'durum_52/3', 'autorouting', 'on');
add_block('simulink/Sources/In1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/onceki_durum_0'], 'Port', '8');
add_block('simulink/Signal Routing/Goto', [s '/G_onceki_durum_0'], 'GotoTag', 'onceki_durum_0');
add_line(s, 'onceki_durum/1', 'G_onceki_durum_0/1');
add_block('simulink/Signal Routing/From', [s '/F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_0'], 'GotoTag', 'onceki_durum_0');
add_line(s, 'F_S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK_0/1', 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/8');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'onceki_durum_0/1', 'durum_52/4', 'autorouting', 'on');
add_block('simulink/Sources/In1', [s '/komut'], 'Port', '1', 'Position', [40 40 70 54]);
add_block('simulink/Sources/In1', [s '/sicaklik'], 'Port', '2', 'Position', [40 90 70 104]);
add_block('simulink/Sources/Constant', [s '/k_d2'], 'Value', '0.0');
add_line(s, 'k_d2/1', 'onceki_ilk_cevrim/1');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/ara_51_o51'], 'Port', '3');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'mps_51/1', 'ara_51_o51/1', 'autorouting', 'on');
add_block('simulink/Signal Routing/Goto', [s '/G_ara_51_51'], 'GotoTag', 'ara_51_51');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/3', 'G_ara_51_51/1');
add_block('simulink/Signal Routing/From', [s '/F_d17'], 'GotoTag', 'ara_51_51');
add_line(s, 'F_d17/1', 'onceki_WAIT_s21_1_done/1');
add_block('simulink/Sinks/Out1', [[s '/Cevrim_sonu_durum_guncelleme'] '/ara_53_o53'], 'Port', '1');
add_line([s '/Cevrim_sonu_durum_guncelleme'], 'sw_53/1', 'ara_53_o53/1', 'autorouting', 'on');
add_block('simulink/Signal Routing/Goto', [s '/G_ara_53_53'], 'GotoTag', 'ara_53_53');
add_line(s, 'Cevrim_sonu_durum_guncelleme/1', 'G_ara_53_53/1');
add_block('simulink/Signal Routing/From', [s '/F_d15'], 'GotoTag', 'ara_53_53');
add_line(s, 'F_d15/1', 'onceki_WAIT_s21_1_on/1');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/ara_47_o47'], 'Port', '4');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'mps_47/1', 'ara_47_o47/1', 'autorouting', 'on');
add_block('simulink/Signal Routing/Goto', [s '/G_ara_47_47'], 'GotoTag', 'ara_47_47');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/4', 'G_ara_47_47/1');
add_block('simulink/Signal Routing/From', [s '/F_d16'], 'GotoTag', 'ara_47_47');
add_line(s, 'F_d16/1', 'onceki_WAIT_s21_1_et/1');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/sayac_o46'], 'Port', '5');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'sayac_46/1', 'sayac_o46/1', 'autorouting', 'on');
add_block('simulink/Signal Routing/Goto', [s '/G_sayac_46'], 'GotoTag', 'sayac_46');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/5', 'G_sayac_46/1');
add_block('simulink/Signal Routing/From', [s '/F_d13'], 'GotoTag', 'sayac_46');
add_line(s, 'F_d13/1', 'onceki_sayac/1');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/cikis_o48'], 'Port', '6');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'cikis_48/1', 'cikis_o48/1', 'autorouting', 'on');
add_block('simulink/Signal Routing/Goto', [s '/G_cikis_48'], 'GotoTag', 'cikis_48');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/6', 'G_cikis_48/1');
add_block('simulink/Signal Routing/From', [s '/F_d1'], 'GotoTag', 'cikis_48');
add_line(s, 'F_d1/1', 'onceki_cikis/1');
add_block('simulink/Sinks/Out1', [[s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'] '/durum_o52'], 'Port', '7');
add_line([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK'], 'durum_52/1', 'durum_o52/1', 'autorouting', 'on');
add_block('simulink/Signal Routing/Goto', [s '/G_durum_52'], 'GotoTag', 'durum_52');
add_line(s, 'S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/7', 'G_durum_52/1');
add_block('simulink/Signal Routing/From', [s '/F_d0'], 'GotoTag', 'durum_52');
add_line(s, 'F_d0/1', 'onceki_durum/1');
add_block('simulink/Sinks/Out1', [s '/out_durum'], 'Port', '1', 'Position', [1400 40 1430 54]);
add_block('simulink/Signal Routing/From', [s '/Fout_1'], 'GotoTag', 'durum_52');
add_line(s, 'Fout_1/1', 'out_durum/1');
add_block('simulink/Sinks/Out1', [s '/out_cikis'], 'Port', '2', 'Position', [1400 90 1430 104]);
add_block('simulink/Signal Routing/From', [s '/Fout_2'], 'GotoTag', 'cikis_48');
add_line(s, 'Fout_2/1', 'out_cikis/1');

% --- kok: girisler / cikislar ---
add_block('simulink/Sources/In1', [mdl '/komut'], 'Port', '1', 'Interpolate', 'off', 'Position', [60 70 90 84]);
add_line(mdl, 'komut/1', 'Turkce_Modul/1', 'autorouting', 'on');
add_block('simulink/Sources/In1', [mdl '/sicaklik'], 'Port', '2', 'Interpolate', 'off', 'Position', [60 110 90 124]);
add_line(mdl, 'sicaklik/1', 'Turkce_Modul/2', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [mdl '/durum'], 'Port', '1', 'Position', [640 70 670 84]);
add_line(mdl, 'Turkce_Modul/1', 'durum/1', 'autorouting', 'on');
add_block('simulink/Sinks/Out1', [mdl '/cikis'], 'Port', '2', 'Position', [640 110 670 124]);
add_line(mdl, 'Turkce_Modul/2', 'cikis/1', 'autorouting', 'on');

% --- yerlesim: deyim / kol alt sistemleri otomatik, ana seviye
%     elle (girisler ve durum solda, deyimler sirayla, cikislar sagda)
try
    Simulink.BlockDiagram.arrangeSystem([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/THEN_satir_15_komut_eq_CALIS_AND_sicaklik_gt_ESIK']);
    Simulink.BlockDiagram.arrangeSystem([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK/ELSIF_satir_19_komut_eq_SALIS']);
    Simulink.BlockDiagram.arrangeSystem([s '/S01_satir_15_IF_komut_eq_CALIS_AND_sicaklik_gt_ESIK']);
    Simulink.BlockDiagram.arrangeSystem([s '/Cevrim_sonu_durum_guncelleme']);
catch
end
yerlestir(s);
if kaydet
    save_system(mdl, [mdl '.slx']);
    fprintf('Kaydedildi: %s.slx\n', mdl);
end
end

function yerlestir(s)
%% Goto / From bloklarini bagli olduklari blogun yanina koyar
b = find_system(s, 'SearchDepth', 1, 'BlockType', 'Goto');
for i = 1:numel(b)
    pc = get_param(b{i}, 'PortConnectivity');
    src = pc(1).SrcBlock;
    if isempty(src) || src < 0, continue; end
    p = get_param(src, 'Position');
    pp = get_param(src, 'PortConnectivity');
    y = pc(1).Position(2);
    set_param(b{i}, 'Position', [p(3) + 30, y - 10, p(3) + 200, y + 10]);
end
f = find_system(s, 'SearchDepth', 1, 'BlockType', 'From');
for i = 1:numel(f)
    pc = get_param(f{i}, 'PortConnectivity');
    dst = pc(end).DstBlock;
    if isempty(dst), continue; end
    p = get_param(dst(1), 'Position');
    y = pc(end).Position(2);
    set_param(f{i}, 'Position', [p(1) - 200, y - 10, p(1) - 30, y + 10]);
end
end
