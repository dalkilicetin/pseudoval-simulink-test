function Turkce_Modul_sfun(block)
%% Turkce_Modul_sfun - Level-2 MATLAB S-Function (INCE SARMALAYICI)
%%
%% Bu dosya MANTIK ICERMEZ. Tum algoritma Turkce_Modul_step.m icindedir;
%% boylece ayni kod hem Simulink'te hem MATLAB komut satirinda calisir
%% ve tek kaynaktan dogrulanir.
%%
%% GEREKLI DOSYALAR (ayni klasorde olmali):
%%   Turkce_Modul_step.m     algoritma - bir kontrol cevrimi
%%   Turkce_Modul_init.m     kalici durum yapisini baslatir
%%   Turkce_Modul_params.m   parametreler ve sembol sabitleri
%%
%% SIMULINK'TE KULLANIM:
%%   1. Kutuphane: Simulink > User-Defined Functions
%%   2. "Level-2 MATLAB S-Function" blogunu modele surukleyin
%%   3. Blogu cift tiklayin, "S-function name" alanina yazin: Turkce_Modul_sfun
%%   4. Cozucu: Fixed-step, Discrete, Fixed-step size = 0.01
%%
%% Derleme GEREKMEZ.
%% UYARI: Simulink Design Verifier bu blogun icine bakamaz.

setup(block);
end

%% ---------------------------------------------------------------- setup
function setup(block)
block.NumInputPorts  = 2;
block.NumOutputPorts = 2;
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;
block.InputPort(1).Dimensions        = 1;   %% komut
block.InputPort(1).DatatypeID        = 0;
block.InputPort(1).Complexity        = 'Real';
block.InputPort(1).DirectFeedthrough = true;
block.InputPort(2).Dimensions        = 1;   %% sicaklik
block.InputPort(2).DatatypeID        = 0;
block.InputPort(2).Complexity        = 'Real';
block.InputPort(2).DirectFeedthrough = true;
block.OutputPort(1).Dimensions       = 1;   %% durum
block.OutputPort(1).DatatypeID       = 0;
block.OutputPort(1).Complexity       = 'Real';
block.OutputPort(2).Dimensions       = 1;   %% cikis
block.OutputPort(2).DatatypeID       = 0;
block.OutputPort(2).Complexity       = 'Real';
block.SampleTimes = [0.01 0];
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
st = Turkce_Modul_init();
block.Dwork(1).Data = pack(st);
end

%% ------------------------------------------------------------ cevrim
function Outputs(block)
P  = Turkce_Modul_params();
st = unpack(block.Dwork(1).Data);

%% giris portlarini yapiya topla
u.komut = double(block.InputPort(1).Data);
u.sicaklik = double(block.InputPort(2).Data);

%% --- ALGORITMA: tek kaynak, Turkce_Modul_step.m ---
[y, st] = Turkce_Modul_step(u, st, P);

block.Dwork(1).Data = pack(st);
block.OutputPort(1).Data = double(y.durum);   %% durum
block.OutputPort(2).Data = double(y.cikis);   %% cikis
end

function Terminate(block) %#ok<INUSD>
end

%% ============================================================ pack/unpack
%% Kalici durum yapisi <-> duz vektor. Alan sirasi URETIM ZAMANINDA
%% sabitlenmistir; Turkce_Modul_init.m ile birebir eslesir.
function v = pack(st)
v = zeros(12,1);
v(1) = st.sayac;
v(2) = st.deger;
v(3) = st.ton_on(1);
v(4) = st.ton_et(1);
v(5) = st.ton_seen(1);
v(6) = st.ton_done(1);
v(7) = st.tick;
v(8) = st.stop;
v(9) = st.inited;
v(10) = st.check;
v(11) = st.y_prev.durum;
v(12) = st.y_prev.cikis;
end

function st = unpack(v)
st.sayac = v(1);
st.deger = v(2);
st.ton_on(1) = v(3);
st.ton_et(1) = v(4);
st.ton_seen(1) = v(5);
st.ton_done(1) = v(6);
st.tick = v(7);
st.stop = v(8);
st.inited = v(9);
st.check = v(10);
st.y_prev.durum = v(11);
st.y_prev.cikis = v(12);
end
