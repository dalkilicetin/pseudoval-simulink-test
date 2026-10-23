function Motor_Kontrol_sfun(block)
%% Motor_Kontrol_sfun - Level-2 MATLAB S-Function (INCE SARMALAYICI)
%%
%% Bu dosya MANTIK ICERMEZ. Tum algoritma Motor_Kontrol_step.m icindedir;
%% boylece ayni kod hem Simulink'te hem MATLAB komut satirinda calisir
%% ve tek kaynaktan dogrulanir.
%%
%% GEREKLI DOSYALAR (ayni klasorde olmali):
%%   Motor_Kontrol_step.m     algoritma - bir kontrol cevrimi
%%   Motor_Kontrol_init.m     kalici durum yapisini baslatir
%%   Motor_Kontrol_params.m   parametreler ve sembol sabitleri
%%
%% SIMULINK'TE KULLANIM:
%%   1. Kutuphane: Simulink > User-Defined Functions
%%   2. "Level-2 MATLAB S-Function" blogunu modele surukleyin
%%   3. Blogu cift tiklayin, "S-function name" alanina yazin: Motor_Kontrol_sfun
%%   4. Cozucu: Fixed-step, Discrete, Fixed-step size = 0.005
%%
%% Derleme GEREKMEZ.
%% UYARI: Simulink Design Verifier bu blogun icine bakamaz.

setup(block);
end

%% ---------------------------------------------------------------- setup
function setup(block)
block.NumInputPorts  = 5;
block.NumOutputPorts = 3;
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;
block.InputPort(1).Dimensions        = 1;   %% StartCommand
block.InputPort(1).DatatypeID        = 0;
block.InputPort(1).Complexity        = 'Real';
block.InputPort(1).DirectFeedthrough = true;
block.InputPort(2).Dimensions        = 1;   %% PreparationComplete
block.InputPort(2).DatatypeID        = 0;
block.InputPort(2).Complexity        = 'Real';
block.InputPort(2).DirectFeedthrough = true;
block.InputPort(3).Dimensions        = 1;   %% FuelPressureOK
block.InputPort(3).DatatypeID        = 0;
block.InputPort(3).Complexity        = 'Real';
block.InputPort(3).DirectFeedthrough = true;
block.InputPort(4).Dimensions        = 1;   %% MotorRunning
block.InputPort(4).DatatypeID        = 0;
block.InputPort(4).Complexity        = 'Real';
block.InputPort(4).DirectFeedthrough = true;
block.InputPort(5).Dimensions        = 1;   %% AbortCommand
block.InputPort(5).DatatypeID        = 0;
block.InputPort(5).Complexity        = 'Real';
block.InputPort(5).DirectFeedthrough = true;
block.OutputPort(1).Dimensions       = 1;   %% MotorEnable
block.OutputPort(1).DatatypeID       = 0;
block.OutputPort(1).Complexity       = 'Real';
block.OutputPort(2).Dimensions       = 1;   %% FuelValve
block.OutputPort(2).DatatypeID       = 0;
block.OutputPort(2).Complexity       = 'Real';
block.OutputPort(3).Dimensions       = 1;   %% Ignition
block.OutputPort(3).DatatypeID       = 0;
block.OutputPort(3).Complexity       = 'Real';
block.SampleTimes = [0.005 0];
block.NumDialogPrms     = 0;
block.SimStateCompliance = 'DefaultSimState';
block.NumContStates     = 0;

block.RegBlockMethod('SetInputPortSamplingMode', @SetInpPortFrameData);
block.RegBlockMethod('PostPropagationSetup',  @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions',  @InitConditions);
block.RegBlockMethod('Outputs',               @Outputs);
block.RegBlockMethod('Terminate',             @Terminate);
end

%% ------------------------------------------- port ornekleme kipi
function SetInpPortFrameData(block, idx, fd)
%% Simulink'in port ornekleme kipi sorusuna cevap verir.
%% Bu metot kayitli degilse Simulink su hatayi verir:
%%   "The S-function does not set the input port sampling mode..."
block.InputPort(idx).SamplingMode = fd;
for i = 1:block.NumOutputPorts
    block.OutputPort(i).SamplingMode = fd;
end
end

%% ------------------------------------------------------- durum ayirma
function DoPostPropSetup(block)
block.NumDworks = 1;
block.Dwork(1).Name            = 'state';
block.Dwork(1).Dimensions      = 12;
block.Dwork(1).DatatypeID      = 0;      %% double
block.Dwork(1).Complexity      = 'Real';
block.Dwork(1).UsedAsDiscState = true;
end

function InitConditions(block)
st = Motor_Kontrol_init();
block.Dwork(1).Data = pack(st);
end

%% ------------------------------------------------------------ cevrim
function Outputs(block)
P  = Motor_Kontrol_params();
st = unpack(block.Dwork(1).Data);

%% giris portlarini yapiya topla
u.StartCommand = double(block.InputPort(1).Data);
u.PreparationComplete = double(block.InputPort(2).Data);
u.FuelPressureOK = double(block.InputPort(3).Data);
u.MotorRunning = double(block.InputPort(4).Data);
u.AbortCommand = double(block.InputPort(5).Data);

%% --- ALGORITMA: tek kaynak, Motor_Kontrol_step.m ---
[y, st] = Motor_Kontrol_step(u, st, P);

block.Dwork(1).Data = pack(st);
block.OutputPort(1).Data = double(y.MotorEnable);   %% MotorEnable
block.OutputPort(2).Data = double(y.FuelValve);   %% FuelValve
block.OutputPort(3).Data = double(y.Ignition);   %% Ignition
end

function Terminate(block) %#ok<INUSD>
end

%% ============================================================ pack/unpack
%% Kalici durum yapisi <-> duz vektor. Alan sirasi URETIM ZAMANINDA
%% sabitlenmistir; Motor_Kontrol_init.m ile birebir eslesir.
function v = pack(st)
v = zeros(12,1);
v(1) = st.MotorState;
v(2) = st.ton_on(1);
v(3) = st.ton_et(1);
v(4) = st.ton_seen(1);
v(5) = st.ton_done(1);
v(6) = st.tick;
v(7) = st.stop;
v(8) = st.inited;
v(9) = st.check;
v(10) = st.y_prev.MotorEnable;
v(11) = st.y_prev.FuelValve;
v(12) = st.y_prev.Ignition;
end

function st = unpack(v)
st.MotorState = v(1);
st.ton_on(1) = v(2);
st.ton_et(1) = v(3);
st.ton_seen(1) = v(4);
st.ton_done(1) = v(5);
st.tick = v(6);
st.stop = v(7);
st.inited = v(8);
st.check = v(9);
st.y_prev.MotorEnable = v(10);
st.y_prev.FuelValve = v(11);
st.y_prev.Ignition = v(12);
end
