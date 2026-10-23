function [y, st] = Tum_Komutlar_step(u, st, P)
%% Tum_Komutlar - bir kontrol cevrimi (10 ms)
%%
%%   u  : giris yapisi   u.basinc, u.komut, u.izin, u.kelime, u.n
%%   st : kalici durum   (Tum_Komutlar_init ile olusturulur)
%%   P  : parametreler   (Tum_Komutlar_params ile olusturulur)
%%   y  : cikis yapisi   y.valf, y.pompa, y.mod, y.sayac, y.toplam, y.bitler, y.hata, y.f, y.sonuc
%%
%% Semantik pseudoval interpreter'iyla BIREBIR (back-to-back
%% testiyle dogrulanir): WAIT = TON zamanlayicisi, bekleyen WAIT
%% yalniz icinde bulundugu blogun kalanini atlar.

y = st.y_prev;          %% cikislar kalicidir
st.stop = 0;
st.tick = st.tick + 1;
st.pv_rec = zeros(1, 4);   %% ozyineleme sayaclari (cevrim icinde)
st.pv_depth = 0;
if st.inited == 0       %% INITIALIZATION: ilk cevrimde bir kez
    st.inited = 1;
    [y, st] = proc__init(u, y, st, P, 3);
end
[y, st] = proc_Tum_Komutlar(u, y, st, P, 0);
%% bu cevrimde ulasilmayan WAIT zamanlayicilari sifirlanir
for k = 1:numel(st.ton_on)
    if st.ton_on(k) ~= 0 && st.ton_seen(k) ~= st.tick
        st.ton_on(k) = 0;
    end
end
st.y_prev = y;
end

function [y, st, r] = proc_Tum_Komutlar(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    pv_j = 0;   % atlama hedefi (EXIT / BREAK / WAIT)
    % READ basinc <- Sensor
    % READ komut <- Yer
    % READ izin <- Yer
    y.sayac = y.sayac + 1;
    if (u.basinc > P.P_MAX)    % satir 46
        y.hata = P.ASIRI_BASINC;
        y.mod = P.HATA;
        % LOG basinc yuksek: {basinc}
        % ABORT sekans
    elseif ((u.basinc > 50) && (abs(u.izin - true) < 1e-9))    % satir 51
        y.hata = P.OK;
    elseif ~(u.izin)    % satir 53
        y.hata = P.OK;
        y.sayac = y.sayac - 1;
    else
        y.hata = 0;
    end
    while true   % atlama hedefi #5
        % SWITCH mod - satir 59
        if abs(y.mod - P.KAPALI) < 1e-9
            y.valf = 0;
            y.pompa = 0;
            if (abs(u.komut - P.BASLA) < 1e-9)    % satir 63
                y.mod = P.HAZIR;
                % ENTER HAZIR
            end
        elseif abs(y.mod - P.HAZIR) < 1e-9
            y.pompa = 1;
            % WAIT 50 ms - satir 69
            [pv_ok, st] = pv_ton(st, tb + 1, 50.0, -1, P.DT_MS);
            if ~pv_ok
                break;
            end
            y.valf = 1;
            y.mod = P.CALISIYOR;
            % ACK komut
        elseif abs(y.mod - P.CALISIYOR) < 1e-9 || abs(y.mod - P.HATA) < 1e-9
            if (abs(u.komut - P.DUR) < 1e-9)    % satir 74
                y.mod = P.KAPALI;
                % REJECT komut
                pv_j = 5; break;
            end
            % WAIT UNTIL basinc < 20 TIMEOUT 100 ms - satir 79
            [pv_ok, st] = pv_ton(st, tb + 2, 100.0, double((u.basinc < 20)), P.DT_MS);
            if ~pv_ok
                break;
            end
            y.valf = 0;
        else
            y.mod = P.KAPALI;
        end
        break;
    end
    if pv_j == 5, pv_j = 0; end
    while true   % atlama hedefi #8
        % SWITCH faz - satir 84
        if abs(st.faz - P.F0) < 1e-9
            st.faz = P.F1;
        elseif abs(st.faz - P.F1) < 1e-9
            % WAIT 30 ms THEN faz := F2 - satir 88
            [pv_ok, st] = pv_ton(st, tb + 3, 30.0, -1, P.DT_MS);
            if ~pv_ok
                break;
            end
            st.faz = P.F2;
        elseif abs(st.faz - P.F2) < 1e-9
            st.faz = P.F0;
        else
            % NOP
        end
        break;
    end
    if pv_j == 8, pv_j = 0; end
    y.toplam = 0;
    st.i = 1;
    pv_n9 = 0;   % WHILE satir 95
    while (st.i <= P.N_ADIM)
        pv_n9 = pv_n9 + 1;
        if pv_n9 > 10000, break; end   % interpreter ile ayni sinir
        while true   % atlama hedefi #10
            if (abs(st.i - 3) < 1e-9)    % satir 96
                pv_j = 10; break;
            end
            y.toplam = (y.toplam + (st.i * 0.5));
            break;
        end
        if pv_j == 10, pv_j = 0; end
        if pv_j ~= 0, break; end
        st.i = (st.i + 1);
    end
    if pv_j == 9, pv_j = 0; end
    st.adim = 0;
    pv_n12 = 0;   % WHILE satir 102
    while (st.adim < u.n)
        pv_n12 = pv_n12 + 1;
        if pv_n12 > 10000, break; end   % interpreter ile ayni sinir
        st.adim = (st.adim + 1);
        if (st.adim > 4)    % satir 104
            pv_j = 12; break;
        end
    end
    if pv_j == 12, pv_j = 0; end
    y.bitler = pv_or(pv_and(u.kelime, 4080), pv_shl(mod(floor(u.kelime / 2^3), 2), 4));
    y.bitler = pv_xor(pv_rol(y.bitler, 3, 16, 0), pv_shr(u.kelime, 2));
    if (abs(pv_getbit(u.kelime, 0) - true) < 1e-9)    % satir 110
        y.bitler = pv_setbit(y.bitler, 15);
    else
        y.bitler = pv_clrbit(y.bitler, 1);
    end
    y.f = ((min(max((u.basinc * 2), 0), 150) + pv_sel(u.izin, round((u.basinc / 3)), fix((u.basinc / 3)))) + pv_mux(pv_mod(u.n, 3), 1, 10, 100));
    y.f = ((((((y.f + pv_div(u.n, 3)) + abs(min(min(u.basinc, 40), 60))) + max(1, 2)) + sqrt(u.basinc)) + pv_mod((-(7)), 3)) + ((2) ^ (3)));
    [y, st, pv_f1] = call_Kare(u, y, st, P, tb + 3, (u.basinc / 10));   % KARE((basinc / 10))
    if isnan(pv_f1), pv_f2 = NaN; else [y, st, pv_f2] = call_Topla(u, y, st, P, tb + 3, st.adim, 2); end
    if ~isnan(pv_f2), y.sonuc = (pv_f1 + pv_f2); end
    [y, st, pv_r] = call_Say(u, y, st, P, tb + 3, u.n);   % CALL Say
    if st.stop ~= 0, return; end
    st.check = double((y.sayac >= 0));   % CHECK sayac >= 0
    st.check = double((y.toplam >= 0));   % CHECK toplam >= 0
    % SEND hata -> Yer
    % WRITE valf -> Surucu
    % WRITE pompa -> Surucu
    if (y.sayac > 1000000)    % satir 124
        st.stop = 1; return;   % EXIT LOOP - cevrim biter
    end
end

function [y, st, r] = proc_Kare(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    r = (st.x * st.x); return;   % RETURN degeri
end

function [y, st, r] = proc_Topla(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    if (st.a > 3)    % satir 135
        r = (st.a + st.b); return;   % RETURN degeri
    end
    r = (st.a - st.b); return;   % RETURN degeri
end

function [y, st, r] = proc_Say(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    if (st.k > 0)    % satir 142
        [y, st, pv_r] = call_Say(u, y, st, P, tb + 0, (st.k - 1));   % CALL Say
        if st.stop ~= 0, return; end
    end
end

function [y, st, r] = proc__init(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    y.sayac = 0;
    y.toplam = 0;
    y.valf = 0;
    y.pompa = 0;
end

function [y, st, r] = call_Tum_Komutlar(u, y, st, P, tb)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    if st.pv_rec(4) < 12 && st.pv_depth < 200
        st.pv_rec(4) = st.pv_rec(4) + 1; st.pv_depth = st.pv_depth + 1;
        [y, st, r] = proc_Tum_Komutlar(u, y, st, P, tb);
        st.pv_rec(4) = st.pv_rec(4) - 1; st.pv_depth = st.pv_depth - 1;
    end
end

function [y, st, r] = call_Kare(u, y, st, P, tb, a0)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    ps0 = st.x;
    if st.pv_rec(1) < 12 && st.pv_depth < 200
        st.pv_rec(1) = st.pv_rec(1) + 1; st.pv_depth = st.pv_depth + 1;
        st.x = a0;   % x
        [y, st, r] = proc_Kare(u, y, st, P, tb);
        st.pv_rec(1) = st.pv_rec(1) - 1; st.pv_depth = st.pv_depth - 1;
    end
    st.x = ps0;
end

function [y, st, r] = call_Topla(u, y, st, P, tb, a0, a1)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    ps0 = st.a;
    ps1 = st.b;
    if st.pv_rec(3) < 12 && st.pv_depth < 200
        st.pv_rec(3) = st.pv_rec(3) + 1; st.pv_depth = st.pv_depth + 1;
        st.a = a0;   % a
        st.b = a1;   % b
        [y, st, r] = proc_Topla(u, y, st, P, tb);
        st.pv_rec(3) = st.pv_rec(3) - 1; st.pv_depth = st.pv_depth - 1;
    end
    st.a = ps0;
    st.b = ps1;
end

function [y, st, r] = call_Say(u, y, st, P, tb, a0)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    ps0 = st.k;
    if st.pv_rec(2) < 12 && st.pv_depth < 200
        st.pv_rec(2) = st.pv_rec(2) + 1; st.pv_depth = st.pv_depth + 1;
        st.k = a0;   % k
        [y, st, r] = proc_Say(u, y, st, P, tb);
        st.pv_rec(2) = st.pv_rec(2) - 1; st.pv_depth = st.pv_depth - 1;
    end
    st.k = ps0;
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

function r = pv_isint(x)
r = (x == floor(x)) && abs(x) < 9e15;
end

function r = pv_bop(a, b, op)
%% iki tamamlayan 64 bit tamsayida bit islemi (1 AND, 2 OR, 3 XOR)
A = typecast(int64(a), 'uint64'); B = typecast(int64(b), 'uint64');
if op == 1, R = bitand(A, B); elseif op == 2, R = bitor(A, B);
else, R = bitxor(A, B); end
r = double(typecast(R, 'int64'));
end

function r = pv_and(a, b)
if pv_isint(a) && pv_isint(b), r = pv_bop(a, b, 1);  %% IEC: BIT
else, r = double(a ~= 0 && b ~= 0); end
end

function r = pv_shl(a, b)
r = fix(a) * 2^max(fix(b), 0);
end

function r = pv_or(a, b)
if pv_isint(a) && pv_isint(b), r = pv_bop(a, b, 2);
else, r = double(a ~= 0 || b ~= 0); end
end

function r = pv_rol(x, k, w, right)
M = 2^w; X = mod(fix(x), M); k = mod(fix(k), w);
if k == 0, r = X; return; end
if right, k = w - k; end
r = mod(X * 2^k + floor(X / 2^(w - k)), M);
end

function r = pv_shr(a, b)
r = floor(fix(a) / 2^max(fix(b), 0));
end

function r = pv_xor(a, b)
if pv_isint(a) && pv_isint(b), r = pv_bop(a, b, 3);
else, r = double(xor(a ~= 0, b ~= 0)); end
end

function r = pv_getbit(x, k)
r = mod(floor(fix(x) / 2^fix(k)), 2);
end

function r = pv_setbit(x, k)
x = fix(x);
if pv_getbit(x, k) == 0, r = x + 2^fix(k); else, r = x; end
end

function r = pv_clrbit(x, k)
x = fix(x);
if pv_getbit(x, k) == 1, r = x - 2^fix(k); else, r = x; end
end

function r = pv_sel(g, a, b)
if g ~= 0, r = b; else, r = a; end
end

function r = pv_mod(a, b)
if b == 0, r = 0; else, r = rem(a, b); end
end

function r = pv_mux(k, varargin)
r = varargin{fix(k) + 1};
end

function r = pv_div(a, b)
if b == 0, r = 0; else, r = fix(a / b); end
end