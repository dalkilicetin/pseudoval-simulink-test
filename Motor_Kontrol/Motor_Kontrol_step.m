function [y, st] = Motor_Kontrol_step(u, st, P)
%% Motor_Kontrol - bir kontrol cevrimi (5 ms)
%%
%%   u  : giris yapisi   u.StartCommand, u.PreparationComplete, u.FuelPressureOK, u.MotorRunning, u.AbortCommand
%%   st : kalici durum   (Motor_Kontrol_init ile olusturulur)
%%   P  : parametreler   (Motor_Kontrol_params ile olusturulur)
%%   y  : cikis yapisi   y.MotorEnable, y.FuelValve, y.Ignition
%%
%% Semantik pseudoval interpreter'iyla BIREBIR (back-to-back
%% testiyle dogrulanir): WAIT = TON zamanlayicisi, bekleyen WAIT
%% yalniz icinde bulundugu blogun kalanini atlar.

y = st.y_prev;          %% cikislar kalicidir
st.stop = 0;
st.tick = st.tick + 1;
st.pv_rec = zeros(1, 1);   %% ozyineleme sayaclari (cevrim icinde)
st.pv_depth = 0;
if st.inited == 0       %% INITIALIZATION: ilk cevrimde bir kez
    st.inited = 1;
    [y, st] = proc__init(u, y, st, P, 0);
end
[y, st] = proc_Motor_Kontrol(u, y, st, P, 0);
%% bu cevrimde ulasilmayan WAIT zamanlayicilari sifirlanir
for k = 1:numel(st.ton_on)
    if st.ton_on(k) ~= 0 && st.ton_seen(k) ~= st.tick
        st.ton_on(k) = 0;
    end
end
st.y_prev = y;
end

function [y, st, r] = proc_Motor_Kontrol(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    if (abs(u.AbortCommand - true) < 1e-9)    % satir 23
        st.MotorState = P.OFF;
        return;
    end
    % SWITCH MotorState - satir 28
    if abs(st.MotorState - P.OFF) < 1e-9
        y.MotorEnable = 0;
        y.FuelValve = P.CLOSED;
        y.Ignition = P.OFF;
        if (abs(u.StartCommand - true) < 1e-9)    % satir 35
            st.MotorState = P.PREPARE;
        end
    elseif abs(st.MotorState - P.PREPARE) < 1e-9
        y.MotorEnable = 1;
        y.FuelValve = P.CLOSED;
        y.Ignition = P.OFF;
        if (abs(u.PreparationComplete - true) < 1e-9)    % satir 45
            st.MotorState = P.FUEL_ON;
        end
    elseif abs(st.MotorState - P.FUEL_ON) < 1e-9
        y.FuelValve = P.OPEN;
        y.Ignition = P.OFF;
        if (abs(u.FuelPressureOK - true) < 1e-9)    % satir 54
            st.MotorState = P.IGNITION;
        end
    elseif abs(st.MotorState - P.IGNITION) < 1e-9
        y.Ignition = P.ON;
        if (abs(u.MotorRunning - true) < 1e-9)    % satir 62
            st.MotorState = P.RUNNING;
        end
    elseif abs(st.MotorState - P.RUNNING) < 1e-9
        y.MotorEnable = 1;
        y.FuelValve = P.OPEN;
        y.Ignition = P.OFF;
    end
end

function [y, st, r] = proc__init(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    st.MotorState = P.OFF;
    y.MotorEnable = 0;
    y.FuelValve = P.CLOSED;
    y.Ignition = P.OFF;
end

function [ok, st] = pv_ton(st, k, pt, cond, dt)
%% WAIT zamanlayicisi (TON) - interpreter (rinterp._ton) ile birebir:
%%   ilk ulasilista gecen sure 0; sonraki her cevrimde +dt
%%   sure dolunca (ya da WAIT UNTIL kosulu saglaninca) gecer, gecik kalir
%%   cond: -1 = kosul yok, 0/1 = WAIT UNTIL kosulu;  pt < 0: sure siniri yok
if st.ton_on(k) == 0
    st.ton_on(k) = 1; st.ton_et(k) = 0; st.ton_done(k) = 0;
elseif st.ton_seen(k) ~= st.tick && st.ton_done(k) == 0
    st.ton_et(k) = st.ton_et(k) + dt;
end
st.ton_seen(k) = st.tick;
ok = true;
if st.ton_done(k) ~= 0, return; end
if cond == 1, st.ton_done(k) = 1; return; end
if pt >= 0 && st.ton_et(k) + 1e-9 >= pt, st.ton_done(k) = 1; return; end
ok = false;
end