function Yakit_Yonetimi_sfun(block)
%% Yakit_Yonetimi_sfun - Level-2 MATLAB S-Function (INCE SARMALAYICI)
%%
%% Bu dosya MANTIK ICERMEZ. Tum algoritma Yakit_Yonetimi_step.m icindedir;
%% boylece ayni kod hem Simulink'te hem MATLAB komut satirinda calisir
%% ve tek kaynaktan dogrulanir.
%%
%% GEREKLI DOSYALAR (ayni klasorde olmali):
%%   Yakit_Yonetimi_step.m     algoritma - bir kontrol cevrimi
%%   Yakit_Yonetimi_init.m     kalici durum yapisini baslatir
%%   Yakit_Yonetimi_params.m   parametreler ve sembol sabitleri
%%
%% SIMULINK'TE KULLANIM:
%%   1. Kutuphane: Simulink > User-Defined Functions
%%   2. "Level-2 MATLAB S-Function" blogunu modele surukleyin
%%   3. Blogu cift tiklayin, "S-function name" alanina yazin: Yakit_Yonetimi_sfun
%%   4. Cozucu: Fixed-step, Discrete, Fixed-step size = 0.02
%%
%% Derleme GEREKMEZ.
%% UYARI: Simulink Design Verifier bu blogun icine bakamaz.

setup(block);
end

%% ---------------------------------------------------------------- setup
function setup(block)
block.NumInputPorts  = 7;
block.NumOutputPorts = 11;
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;
block.InputPort(1).Dimensions        = 1;   %% p_tank1
block.InputPort(1).DatatypeID        = 0;
block.InputPort(1).Complexity        = 'Real';
block.InputPort(1).DirectFeedthrough = true;
block.InputPort(2).Dimensions        = 1;   %% p_tank2
block.InputPort(2).DatatypeID        = 0;
block.InputPort(2).Complexity        = 'Real';
block.InputPort(2).DirectFeedthrough = true;
block.InputPort(3).Dimensions        = 1;   %% p_tank3
block.InputPort(3).DatatypeID        = 0;
block.InputPort(3).Complexity        = 'Real';
block.InputPort(3).DirectFeedthrough = true;
block.InputPort(4).Dimensions        = 1;   %% sicaklik
block.InputPort(4).DatatypeID        = 0;
block.InputPort(4).Complexity        = 'Real';
block.InputPort(4).DirectFeedthrough = true;
block.InputPort(5).Dimensions        = 1;   %% komut
block.InputPort(5).DatatypeID        = 0;
block.InputPort(5).Complexity        = 'Real';
block.InputPort(5).DirectFeedthrough = true;
block.InputPort(6).Dimensions        = 1;   %% sensor_ok
block.InputPort(6).DatatypeID        = 0;
block.InputPort(6).Complexity        = 'Real';
block.InputPort(6).DirectFeedthrough = true;
block.InputPort(7).Dimensions        = 1;   %% maske
block.InputPort(7).DatatypeID        = 0;
block.InputPort(7).Complexity        = 'Real';
block.InputPort(7).DirectFeedthrough = true;
block.OutputPort(1).Dimensions       = 1;   %% durum
block.OutputPort(1).DatatypeID       = 0;
block.OutputPort(1).Complexity       = 'Real';
block.OutputPort(2).Dimensions       = 1;   %% alt_durum
block.OutputPort(2).DatatypeID       = 0;
block.OutputPort(2).Complexity       = 'Real';
block.OutputPort(3).Dimensions       = 1;   %% v_giris
block.OutputPort(3).DatatypeID       = 0;
block.OutputPort(3).Complexity       = 'Real';
block.OutputPort(4).Dimensions       = 1;   %% v_cikis
block.OutputPort(4).DatatypeID       = 0;
block.OutputPort(4).Complexity       = 'Real';
block.OutputPort(5).Dimensions       = 1;   %% v_tahliye
block.OutputPort(5).DatatypeID       = 0;
block.OutputPort(5).Complexity       = 'Real';
block.OutputPort(6).Dimensions       = 1;   %% p_secilen
block.OutputPort(6).DatatypeID       = 0;
block.OutputPort(6).Complexity       = 'Real';
block.OutputPort(7).Dimensions       = 1;   %% ariza_kodu
block.OutputPort(7).DatatypeID       = 0;
block.OutputPort(7).Complexity       = 'Real';
block.OutputPort(8).Dimensions       = 1;   %% deneme
block.OutputPort(8).DatatypeID       = 0;
block.OutputPort(8).Complexity       = 'Real';
block.OutputPort(9).Dimensions       = 1;   %% filtre
block.OutputPort(9).DatatypeID       = 0;
block.OutputPort(9).Complexity       = 'Real';
block.OutputPort(10).Dimensions       = 1;   %% histerezis
block.OutputPort(10).DatatypeID       = 0;
block.OutputPort(10).Complexity       = 'Real';
block.OutputPort(11).Dimensions       = 1;   %% kalp
block.OutputPort(11).DatatypeID       = 0;
block.OutputPort(11).Complexity       = 'Real';
block.SampleTimes = [0.02 0];
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
block.Dwork(1).Dimensions      = 41;
block.Dwork(1).DatatypeID      = 0;      %% double
block.Dwork(1).Complexity      = 'Real';
block.Dwork(1).UsedAsDiscState = true;
end

function InitConditions(block)
st = Yakit_Yonetimi_init();
block.Dwork(1).Data = pack(st);
end

%% ------------------------------------------------------------ cevrim
function Outputs(block)
P  = Yakit_Yonetimi_params();
st = unpack(block.Dwork(1).Data);

%% giris portlarini yapiya topla
u.p_tank1 = double(block.InputPort(1).Data);
u.p_tank2 = double(block.InputPort(2).Data);
u.p_tank3 = double(block.InputPort(3).Data);
u.sicaklik = double(block.InputPort(4).Data);
u.komut = double(block.InputPort(5).Data);
u.sensor_ok = double(block.InputPort(6).Data);
u.maske = double(block.InputPort(7).Data);

%% --- ALGORITMA: tek kaynak, Yakit_Yonetimi_step.m ---
[y, st] = Yakit_Yonetimi_step(u, st, P);

block.Dwork(1).Data = pack(st);
block.OutputPort(1).Data = double(y.durum);   %% durum
block.OutputPort(2).Data = double(y.alt_durum);   %% alt_durum
block.OutputPort(3).Data = double(y.v_giris);   %% v_giris
block.OutputPort(4).Data = double(y.v_cikis);   %% v_cikis
block.OutputPort(5).Data = double(y.v_tahliye);   %% v_tahliye
block.OutputPort(6).Data = double(y.p_secilen);   %% p_secilen
block.OutputPort(7).Data = double(y.ariza_kodu);   %% ariza_kodu
block.OutputPort(8).Data = double(y.deneme);   %% deneme
block.OutputPort(9).Data = double(y.filtre);   %% filtre
block.OutputPort(10).Data = double(y.histerezis);   %% histerezis
block.OutputPort(11).Data = double(y.kalp);   %% kalp
end

function Terminate(block) %#ok<INUSD>
end

%% ============================================================ pack/unpack
%% Kalici durum yapisi <-> duz vektor. Alan sirasi URETIM ZAMANINDA
%% sabitlenmistir; Yakit_Yonetimi_init.m ile birebir eslesir.
function v = pack(st)
v = zeros(41,1);
v(1) = st.sayac_dengele;
v(2) = st.onceki_p;
v(3) = st.tur;
v(4) = st.j;
v(5) = st.k;
v(6) = st.a;
v(7) = st.b;
v(8) = st.c;
v(9) = st.x;
v(10) = st.y;
v(11) = st.ton_on(1);
v(12) = st.ton_on(2);
v(13) = st.ton_on(3);
v(14) = st.ton_on(4);
v(15) = st.ton_et(1);
v(16) = st.ton_et(2);
v(17) = st.ton_et(3);
v(18) = st.ton_et(4);
v(19) = st.ton_seen(1);
v(20) = st.ton_seen(2);
v(21) = st.ton_seen(3);
v(22) = st.ton_seen(4);
v(23) = st.ton_done(1);
v(24) = st.ton_done(2);
v(25) = st.ton_done(3);
v(26) = st.ton_done(4);
v(27) = st.tick;
v(28) = st.stop;
v(29) = st.inited;
v(30) = st.check;
v(31) = st.y_prev.durum;
v(32) = st.y_prev.alt_durum;
v(33) = st.y_prev.v_giris;
v(34) = st.y_prev.v_cikis;
v(35) = st.y_prev.v_tahliye;
v(36) = st.y_prev.p_secilen;
v(37) = st.y_prev.ariza_kodu;
v(38) = st.y_prev.deneme;
v(39) = st.y_prev.filtre;
v(40) = st.y_prev.histerezis;
v(41) = st.y_prev.kalp;
end

function st = unpack(v)
st.sayac_dengele = v(1);
st.onceki_p = v(2);
st.tur = v(3);
st.j = v(4);
st.k = v(5);
st.a = v(6);
st.b = v(7);
st.c = v(8);
st.x = v(9);
st.y = v(10);
st.ton_on(1) = v(11);
st.ton_on(2) = v(12);
st.ton_on(3) = v(13);
st.ton_on(4) = v(14);
st.ton_et(1) = v(15);
st.ton_et(2) = v(16);
st.ton_et(3) = v(17);
st.ton_et(4) = v(18);
st.ton_seen(1) = v(19);
st.ton_seen(2) = v(20);
st.ton_seen(3) = v(21);
st.ton_seen(4) = v(22);
st.ton_done(1) = v(23);
st.ton_done(2) = v(24);
st.ton_done(3) = v(25);
st.ton_done(4) = v(26);
st.tick = v(27);
st.stop = v(28);
st.inited = v(29);
st.check = v(30);
st.y_prev.durum = v(31);
st.y_prev.alt_durum = v(32);
st.y_prev.v_giris = v(33);
st.y_prev.v_cikis = v(34);
st.y_prev.v_tahliye = v(35);
st.y_prev.p_secilen = v(36);
st.y_prev.ariza_kodu = v(37);
st.y_prev.deneme = v(38);
st.y_prev.filtre = v(39);
st.y_prev.histerezis = v(40);
st.y_prev.kalp = v(41);
end
