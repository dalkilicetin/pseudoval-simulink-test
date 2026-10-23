function Tum_Komutlar_sfun(block)
%% Tum_Komutlar_sfun - Level-2 MATLAB S-Function (INCE SARMALAYICI)
%%
%% Bu dosya MANTIK ICERMEZ. Tum algoritma Tum_Komutlar_step.m icindedir;
%% boylece ayni kod hem Simulink'te hem MATLAB komut satirinda calisir
%% ve tek kaynaktan dogrulanir.
%%
%% GEREKLI DOSYALAR (ayni klasorde olmali):
%%   Tum_Komutlar_step.m     algoritma - bir kontrol cevrimi
%%   Tum_Komutlar_init.m     kalici durum yapisini baslatir
%%   Tum_Komutlar_params.m   parametreler ve sembol sabitleri
%%
%% SIMULINK'TE KULLANIM:
%%   1. Kutuphane: Simulink > User-Defined Functions
%%   2. "Level-2 MATLAB S-Function" blogunu modele surukleyin
%%   3. Blogu cift tiklayin, "S-function name" alanina yazin: Tum_Komutlar_sfun
%%   4. Cozucu: Fixed-step, Discrete, Fixed-step size = 0.01
%%
%% Derleme GEREKMEZ.
%% UYARI: Simulink Design Verifier bu blogun icine bakamaz.

setup(block);
end

%% ---------------------------------------------------------------- setup
function setup(block)
block.NumInputPorts  = 5;
block.NumOutputPorts = 9;
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;
block.InputPort(1).Dimensions        = 1;   %% basinc
block.InputPort(1).DatatypeID        = 0;
block.InputPort(1).Complexity        = 'Real';
block.InputPort(1).DirectFeedthrough = true;
block.InputPort(2).Dimensions        = 1;   %% komut
block.InputPort(2).DatatypeID        = 0;
block.InputPort(2).Complexity        = 'Real';
block.InputPort(2).DirectFeedthrough = true;
block.InputPort(3).Dimensions        = 1;   %% izin
block.InputPort(3).DatatypeID        = 0;
block.InputPort(3).Complexity        = 'Real';
block.InputPort(3).DirectFeedthrough = true;
block.InputPort(4).Dimensions        = 1;   %% kelime
block.InputPort(4).DatatypeID        = 0;
block.InputPort(4).Complexity        = 'Real';
block.InputPort(4).DirectFeedthrough = true;
block.InputPort(5).Dimensions        = 1;   %% n
block.InputPort(5).DatatypeID        = 0;
block.InputPort(5).Complexity        = 'Real';
block.InputPort(5).DirectFeedthrough = true;
block.OutputPort(1).Dimensions       = 1;   %% valf
block.OutputPort(1).DatatypeID       = 0;
block.OutputPort(1).Complexity       = 'Real';
block.OutputPort(2).Dimensions       = 1;   %% pompa
block.OutputPort(2).DatatypeID       = 0;
block.OutputPort(2).Complexity       = 'Real';
block.OutputPort(3).Dimensions       = 1;   %% mod
block.OutputPort(3).DatatypeID       = 0;
block.OutputPort(3).Complexity       = 'Real';
block.OutputPort(4).Dimensions       = 1;   %% sayac
block.OutputPort(4).DatatypeID       = 0;
block.OutputPort(4).Complexity       = 'Real';
block.OutputPort(5).Dimensions       = 1;   %% toplam
block.OutputPort(5).DatatypeID       = 0;
block.OutputPort(5).Complexity       = 'Real';
block.OutputPort(6).Dimensions       = 1;   %% bitler
block.OutputPort(6).DatatypeID       = 0;
block.OutputPort(6).Complexity       = 'Real';
block.OutputPort(7).Dimensions       = 1;   %% hata
block.OutputPort(7).DatatypeID       = 0;
block.OutputPort(7).Complexity       = 'Real';
block.OutputPort(8).Dimensions       = 1;   %% f
block.OutputPort(8).DatatypeID       = 0;
block.OutputPort(8).Complexity       = 'Real';
block.OutputPort(9).Dimensions       = 1;   %% sonuc
block.OutputPort(9).DatatypeID       = 0;
block.OutputPort(9).Complexity       = 'Real';
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
block.Dwork(1).Dimensions      = 32;
block.Dwork(1).DatatypeID      = 0;      %% double
block.Dwork(1).Complexity      = 'Real';
block.Dwork(1).UsedAsDiscState = true;
end

function InitConditions(block)
st = Tum_Komutlar_init();
block.Dwork(1).Data = pack(st);
end

%% ------------------------------------------------------------ cevrim
function Outputs(block)
P  = Tum_Komutlar_params();
st = unpack(block.Dwork(1).Data);

%% giris portlarini yapiya topla
u.basinc = double(block.InputPort(1).Data);
u.komut = double(block.InputPort(2).Data);
u.izin = double(block.InputPort(3).Data);
u.kelime = double(block.InputPort(4).Data);
u.n = double(block.InputPort(5).Data);

%% --- ALGORITMA: tek kaynak, Tum_Komutlar_step.m ---
[y, st] = Tum_Komutlar_step(u, st, P);

block.Dwork(1).Data = pack(st);
block.OutputPort(1).Data = double(y.valf);   %% valf
block.OutputPort(2).Data = double(y.pompa);   %% pompa
block.OutputPort(3).Data = double(y.mod);   %% mod
block.OutputPort(4).Data = double(y.sayac);   %% sayac
block.OutputPort(5).Data = double(y.toplam);   %% toplam
block.OutputPort(6).Data = double(y.bitler);   %% bitler
block.OutputPort(7).Data = double(y.hata);   %% hata
block.OutputPort(8).Data = double(y.f);   %% f
block.OutputPort(9).Data = double(y.sonuc);   %% sonuc
end

function Terminate(block) %#ok<INUSD>
end

%% ============================================================ pack/unpack
%% Kalici durum yapisi <-> duz vektor. Alan sirasi URETIM ZAMANINDA
%% sabitlenmistir; Tum_Komutlar_init.m ile birebir eslesir.
function v = pack(st)
v = zeros(32,1);
v(1) = st.adim;
v(2) = st.faz;
v(3) = st.i;
v(4) = st.x;
v(5) = st.a;
v(6) = st.b;
v(7) = st.k;
v(8) = st.ton_on(1);
v(9) = st.ton_on(2);
v(10) = st.ton_on(3);
v(11) = st.ton_et(1);
v(12) = st.ton_et(2);
v(13) = st.ton_et(3);
v(14) = st.ton_seen(1);
v(15) = st.ton_seen(2);
v(16) = st.ton_seen(3);
v(17) = st.ton_done(1);
v(18) = st.ton_done(2);
v(19) = st.ton_done(3);
v(20) = st.tick;
v(21) = st.stop;
v(22) = st.inited;
v(23) = st.check;
v(24) = st.y_prev.valf;
v(25) = st.y_prev.pompa;
v(26) = st.y_prev.mod;
v(27) = st.y_prev.sayac;
v(28) = st.y_prev.toplam;
v(29) = st.y_prev.bitler;
v(30) = st.y_prev.hata;
v(31) = st.y_prev.f;
v(32) = st.y_prev.sonuc;
end

function st = unpack(v)
st.adim = v(1);
st.faz = v(2);
st.i = v(3);
st.x = v(4);
st.a = v(5);
st.b = v(6);
st.k = v(7);
st.ton_on(1) = v(8);
st.ton_on(2) = v(9);
st.ton_on(3) = v(10);
st.ton_et(1) = v(11);
st.ton_et(2) = v(12);
st.ton_et(3) = v(13);
st.ton_seen(1) = v(14);
st.ton_seen(2) = v(15);
st.ton_seen(3) = v(16);
st.ton_done(1) = v(17);
st.ton_done(2) = v(18);
st.ton_done(3) = v(19);
st.tick = v(20);
st.stop = v(21);
st.inited = v(22);
st.check = v(23);
st.y_prev.valf = v(24);
st.y_prev.pompa = v(25);
st.y_prev.mod = v(26);
st.y_prev.sayac = v(27);
st.y_prev.toplam = v(28);
st.y_prev.bitler = v(29);
st.y_prev.hata = v(30);
st.y_prev.f = v(31);
st.y_prev.sonuc = v(32);
end
