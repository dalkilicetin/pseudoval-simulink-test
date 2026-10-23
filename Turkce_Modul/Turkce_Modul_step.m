function [y, st] = Turkce_Modul_step(u, st, P)
%% Turkce_Modul - bir kontrol cevrimi (10 ms)
%%
%%   u  : giris yapisi   u.komut, u.sicaklik
%%   st : kalici durum   (Turkce_Modul_init ile olusturulur)
%%   P  : parametreler   (Turkce_Modul_params ile olusturulur)
%%   y  : cikis yapisi   y.durum, y.cikis
%%
%% Semantik pseudoval interpreter'iyla BIREBIR (back-to-back
%% testiyle dogrulanir): WAIT = TON zamanlayicisi, bekleyen WAIT
%% yalniz icinde bulundugu blogun kalanini atlar.

y = st.y_prev;          %% cikislar kalicidir
st.stop = 0;
st.tick = st.tick + 1;
st.pv_rec = zeros(1, 2);   %% ozyineleme sayaclari (cevrim icinde)
st.pv_depth = 0;
if st.inited == 0       %% INITIALIZATION: ilk cevrimde bir kez
    st.inited = 1;
    [y, st] = proc__init(u, y, st, P, 1);
end
[y, st] = proc_Turkce_Modul(u, y, st, P, 0);
%% bu cevrimde ulasilmayan WAIT zamanlayicilari sifirlanir
for k = 1:numel(st.ton_on)
    if st.ton_on(k) ~= 0 && st.ton_seen(k) ~= st.tick
        st.ton_on(k) = 0;
    end
end
st.y_prev = y;
end

function [y, st, r] = proc_Turkce_Modul(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    if ((abs(u.komut - P.CALIS) < 1e-9) && (u.sicaklik > P.ESIK))    % satir 15
        y.durum = P.ACIK;
        st.sayac = st.sayac + 1;
        y.cikis = st.sayac;
    elseif (abs(u.komut - P.SALIS) < 1e-9)    % satir 19
        while true   % atlama hedefi #98
            y.durum = P.KAPALI;
            % WAIT 30 ms - satir 21
            [pv_ok, st] = pv_ton(st, tb + 1, 30.0, -1, P.DT_MS);
            if ~pv_ok
                break;
            end
            [y, st, pv_f1] = call_Olcekle(u, y, st, P, tb + 1, u.sicaklik);   % OLCEKLE(sicaklik)
            if ~isnan(pv_f1), y.cikis = pv_f1; end
            break;
        end
    else
        st.sayac = 0;
        y.cikis = 3;
    end
end

function [y, st, r] = proc_Olcekle(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    r = ((st.deger * 2) + P.ESIK); return;   % RETURN degeri
end

function [y, st, r] = proc__init(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    % (bos)
end

function [y, st, r] = call_Turkce_Modul(u, y, st, P, tb)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    if st.pv_rec(1) < 12 && st.pv_depth < 200
        st.pv_rec(1) = st.pv_rec(1) + 1; st.pv_depth = st.pv_depth + 1;
        [y, st, r] = proc_Turkce_Modul(u, y, st, P, tb);
        st.pv_rec(1) = st.pv_rec(1) - 1; st.pv_depth = st.pv_depth - 1;
    end
end

function [y, st, r] = call_Olcekle(u, y, st, P, tb, a0)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    ps0 = st.deger;
    if st.pv_rec(2) < 12 && st.pv_depth < 200
        st.pv_rec(2) = st.pv_rec(2) + 1; st.pv_depth = st.pv_depth + 1;
        st.deger = a0;   % deger
        [y, st, r] = proc_Olcekle(u, y, st, P, tb);
        st.pv_rec(2) = st.pv_rec(2) - 1; st.pv_depth = st.pv_depth - 1;
    end
    st.deger = ps0;
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