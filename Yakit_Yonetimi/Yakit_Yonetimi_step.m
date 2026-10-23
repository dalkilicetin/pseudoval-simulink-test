function [y, st] = Yakit_Yonetimi_step(u, st, P)
%% Yakit_Yonetimi - bir kontrol cevrimi (20 ms)
%%
%%   u  : giris yapisi   u.p_tank1, u.p_tank2, u.p_tank3, u.sicaklik, u.komut, u.sensor_ok, u.maske
%%   st : kalici durum   (Yakit_Yonetimi_init ile olusturulur)
%%   P  : parametreler   (Yakit_Yonetimi_params ile olusturulur)
%%   y  : cikis yapisi   y.durum, y.alt_durum, y.v_giris, y.v_cikis, y.v_tahliye, y.p_secilen, y.ariza_kodu, y.deneme, y.filtre, y.histerezis, y.kalp
%%
%% Semantik pseudoval interpreter'iyla BIREBIR (back-to-back
%% testiyle dogrulanir): WAIT = TON zamanlayicisi, bekleyen WAIT
%% yalniz icinde bulundugu blogun kalanini atlar.

y = st.y_prev;          %% cikislar kalicidir
st.stop = 0;
st.tick = st.tick + 1;
st.pv_rec = zeros(1, 6);   %% ozyineleme sayaclari (cevrim icinde)
st.pv_depth = 0;
if st.inited == 0       %% INITIALIZATION: ilk cevrimde bir kez
    st.inited = 1;
    [y, st] = proc__init(u, y, st, P, 4);
end
[y, st] = proc_Yakit_Yonetimi(u, y, st, P, 0);
%% bu cevrimde ulasilmayan WAIT zamanlayicilari sifirlanir
for k = 1:numel(st.ton_on)
    if st.ton_on(k) ~= 0 && st.ton_seen(k) ~= st.tick
        st.ton_on(k) = 0;
    end
end
st.y_prev = y;
end

function [y, st, r] = proc_Yakit_Yonetimi(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    pv_j = 0;   % atlama hedefi (EXIT / BREAK / WAIT)
    y.kalp = ~(y.kalp);
    [y, st, pv_f1] = call_Medyan(u, y, st, P, tb + 2, u.p_tank1, u.p_tank2, u.p_tank3);   % MEDYAN(p_tank1, p_tank2, p_tank3)
    if ~isnan(pv_f1), y.p_secilen = pv_f1; end
    y.filtre = (y.filtre + (P.ALFA * (y.p_secilen - y.filtre)));
    if (y.filtre > P.P_UST)    % satir 56
        y.histerezis = true;
    elseif (y.filtre < (P.P_UST - P.P_FARK))    % satir 58
        y.histerezis = false;
    end
    [y, st, pv_r] = call_Ariza_Denetle(u, y, st, P, tb + 2);   % CALL Ariza_Denetle
    if st.stop ~= 0, return; end
    if (abs(u.komut - P.ACIL) < 1e-9)    % satir 62
        y.durum = P.GUVENLI;
    end
    while true   % atlama hedefi #42
        % SWITCH durum - satir 65
        if abs(y.durum - P.BOSTA) < 1e-9
            [y, st, pv_r] = call_Hepsini_Kapat(u, y, st, P, tb + 2);   % CALL Hepsini_Kapat
            if st.stop ~= 0, return; end
            y.alt_durum = 0;
            if ((abs(u.komut - P.DOLUM) < 1e-9) && (abs(y.ariza_kodu - P.HATA_YOK) < 1e-9))    % satir 69
                y.durum = P.ON_KONTROL;
            elseif (abs(u.komut - P.BOSALT) < 1e-9)    % satir 71
                y.durum = P.BOSALIYOR;
            end
        elseif abs(y.durum - P.ON_KONTROL) < 1e-9
            while true   % atlama hedefi #45
                % SWITCH alt_durum - satir 75
                if abs(y.alt_durum - 0) < 1e-9
                    [y, st, pv_r] = call_Bekle_Sabit(u, y, st, P, tb + 2);   % CALL Bekle_Sabit
                    if st.stop ~= 0, return; end
                    y.alt_durum = 1;
                elseif abs(y.alt_durum - 1) < 1e-9
                    [y, st, pv_f2] = call_Tutarli(u, y, st, P, tb + 3, u.p_tank1, u.p_tank2);   % TUTARLI(p_tank1, p_tank2)
                    if isnan(pv_f2), pv_f3 = NaN; else [y, st, pv_f3] = call_Tutarli(u, y, st, P, tb + 3, u.p_tank2, u.p_tank3); end
                    if (~isnan(pv_f3) && (pv_and(pv_f2, pv_f3)))    % satir 80
                        y.alt_durum = 2;
                    else
                        y.deneme = y.deneme + 1;
                        if (y.deneme >= P.MAKS_DENEME)    % satir 84
                            y.ariza_kodu = pv_or(y.ariza_kodu, P.TUTARSIZLIK);
                            y.durum = P.ARIZA;
                            pv_j = 45; break;
                        end
                        y.alt_durum = 0;
                    end
                elseif abs(y.alt_durum - 2) < 1e-9
                    y.deneme = 0;
                    y.durum = P.DOLUYOR;
                else
                    y.alt_durum = 0;
                end
                break;
            end
            if pv_j == 45, pv_j = 0; end
            if pv_j ~= 0, break; end
        elseif abs(y.durum - P.DOLUYOR) < 1e-9
            y.v_giris = 1;
            y.v_cikis = 0;
            % WAIT UNTIL filtre >= P_UST TIMEOUT 2 s - satir 100
            [pv_ok, st] = pv_ton(st, tb + 1, (1000 * 2.0), double((y.filtre >= P.P_UST)), P.DT_MS);
            if ~pv_ok
                break;
            end
            if (y.filtre >= P.P_UST)    % satir 101
                y.v_giris = 0;
                y.durum = P.DENGELEME;
                st.sayac_dengele = 0;
            else
                y.ariza_kodu = pv_or(y.ariza_kodu, P.ZAMAN_ASIMI);
                y.durum = P.ARIZA;
            end
        elseif abs(y.durum - P.DENGELEME) < 1e-9
            st.sayac_dengele = st.sayac_dengele + 1;
            [y, st, pv_r] = call_Bekle_Sabit(u, y, st, P, tb + 3);   % CALL Bekle_Sabit
            if st.stop ~= 0, return; end
            if (abs((y.filtre - st.onceki_p)) < 0.5)    % satir 112
                y.durum = P.BOSTA;
            elseif (st.sayac_dengele > 50)    % satir 114
                y.durum = P.ARIZA;
            end
        elseif abs(y.durum - P.BOSALIYOR) < 1e-9
            y.v_cikis = 1;
            y.v_giris = 0;
            if (y.filtre < P.P_ALT)    % satir 120
                y.v_cikis = 0;
                y.durum = P.BOSTA;
            end
        elseif abs(y.durum - P.ARIZA) < 1e-9
            [y, st, pv_r] = call_Hepsini_Kapat(u, y, st, P, tb + 4);   % CALL Hepsini_Kapat
            if st.stop ~= 0, return; end
            y.v_tahliye = 1;
            if (abs(u.komut - P.SIFIRLA) < 1e-9)    % satir 127
                while true   % atlama hedefi #54
                    % WAIT 100 ms - satir 128
                    [pv_ok, st] = pv_ton(st, tb + 2, 100.0, -1, P.DT_MS);
                    if ~pv_ok
                        break;
                    end
                    y.ariza_kodu = P.HATA_YOK;
                    y.deneme = 0;
                    y.durum = P.BOSTA;
                    break;
                end
                if pv_j == 54, pv_j = 0; end
                if pv_j ~= 0, break; end
            end
        elseif abs(y.durum - P.GUVENLI) < 1e-9
            [y, st, pv_r] = call_Hepsini_Kapat(u, y, st, P, tb + 4);   % CALL Hepsini_Kapat
            if st.stop ~= 0, return; end
            y.v_tahliye = 1;
            if (abs(u.komut - P.SIFIRLA) < 1e-9)    % satir 136
                y.durum = P.BOSTA;
            end
        else
            y.durum = P.ARIZA;
        end
        break;
    end
    if pv_j == 42, pv_j = 0; end
    st.tur = 0;
    st.j = 0;
    pv_n56 = 0;   % WHILE satir 144
    while (st.j <= 3)
        pv_n56 = pv_n56 + 1;
        if pv_n56 > 10000, break; end   % interpreter ile ayni sinir
        st.k = 0;
        pv_n58 = 0;   % WHILE satir 145
        while (st.k <= 3)
            pv_n58 = pv_n58 + 1;
            if pv_n58 > 10000, break; end   % interpreter ile ayni sinir
            if (abs(pv_getbit(u.maske, ((st.j * 4) + st.k)) - true) < 1e-9)    % satir 146
                st.tur = (st.tur + 1);
            end
            if (st.tur > 10)    % satir 149
                pv_j = 58; break;
            end
            st.k = (st.k + 1);
        end
        if pv_j == 58, pv_j = 0; end
        if pv_j ~= 0, break; end
        st.j = (st.j + 1);
    end
    if pv_j == 56, pv_j = 0; end
    if (st.tur > 12)    % satir 154
        y.ariza_kodu = pv_or(y.ariza_kodu, P.SENSOR_ARIZA);
    end
    st.onceki_p = y.filtre;
end

function [y, st, r] = proc_Medyan(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    if (((st.a >= st.b) && (st.a <= st.c)) || ((st.a <= st.b) && (st.a >= st.c)))    % satir 162
        r = st.a; return;   % RETURN degeri
    elseif (((st.b >= st.a) && (st.b <= st.c)) || ((st.b <= st.a) && (st.b >= st.c)))    % satir 164
        r = st.b; return;   % RETURN degeri
    end
    r = st.c; return;   % RETURN degeri
end

function [y, st, r] = proc_Tutarli(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    r = (abs((st.x - st.y)) < P.P_FARK); return;   % RETURN degeri
end

function [y, st, r] = proc_Ariza_Denetle(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    if (abs(u.sensor_ok - false) < 1e-9)    % satir 175
        y.ariza_kodu = pv_or(y.ariza_kodu, P.SENSOR_ARIZA);
    end
    if (u.sicaklik > P.T_MAX)    % satir 178
        y.ariza_kodu = pv_or(y.ariza_kodu, P.ASIRI_SICAKLIK);
        if (abs(y.durum - P.GUVENLI) >= 1e-9)    % satir 180
            y.durum = P.ARIZA;
        end
    end
end

function [y, st, r] = proc_Hepsini_Kapat(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    y.v_giris = 0;
    y.v_cikis = 0;
    y.v_tahliye = 0;
end

function [y, st, r] = proc_Bekle_Sabit(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    % WAIT 60 ms - satir 193
    [pv_ok, st] = pv_ton(st, tb + 1, 60.0, -1, P.DT_MS);
    if ~pv_ok
        return;
    end
    y.alt_durum = (y.alt_durum + 0);
end

function [y, st, r] = proc__init(u, y, st, P, tb)
    r = NaN;   % RETURN <deger> yoksa: deger yok
    y.durum = P.BOSTA;
    y.filtre = 0;
    y.deneme = 0;
    y.v_giris = 0;
    y.v_cikis = 0;
    y.v_tahliye = 0;
end

function [y, st, r] = call_Yakit_Yonetimi(u, y, st, P, tb)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    if st.pv_rec(6) < 12 && st.pv_depth < 200
        st.pv_rec(6) = st.pv_rec(6) + 1; st.pv_depth = st.pv_depth + 1;
        [y, st, r] = proc_Yakit_Yonetimi(u, y, st, P, tb);
        st.pv_rec(6) = st.pv_rec(6) - 1; st.pv_depth = st.pv_depth - 1;
    end
end

function [y, st, r] = call_Medyan(u, y, st, P, tb, a0, a1, a2)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    ps0 = st.a;
    ps1 = st.b;
    ps2 = st.c;
    if st.pv_rec(4) < 12 && st.pv_depth < 200
        st.pv_rec(4) = st.pv_rec(4) + 1; st.pv_depth = st.pv_depth + 1;
        st.a = a0;   % a
        st.b = a1;   % b
        st.c = a2;   % c
        [y, st, r] = proc_Medyan(u, y, st, P, tb);
        st.pv_rec(4) = st.pv_rec(4) - 1; st.pv_depth = st.pv_depth - 1;
    end
    st.a = ps0;
    st.b = ps1;
    st.c = ps2;
end

function [y, st, r] = call_Tutarli(u, y, st, P, tb, a0, a1)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    ps0 = st.x;
    ps1 = st.y;
    if st.pv_rec(5) < 12 && st.pv_depth < 200
        st.pv_rec(5) = st.pv_rec(5) + 1; st.pv_depth = st.pv_depth + 1;
        st.x = a0;   % x
        st.y = a1;   % y
        [y, st, r] = proc_Tutarli(u, y, st, P, tb);
        st.pv_rec(5) = st.pv_rec(5) - 1; st.pv_depth = st.pv_depth - 1;
    end
    st.x = ps0;
    st.y = ps1;
end

function [y, st, r] = call_Ariza_Denetle(u, y, st, P, tb)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    if st.pv_rec(1) < 12 && st.pv_depth < 200
        st.pv_rec(1) = st.pv_rec(1) + 1; st.pv_depth = st.pv_depth + 1;
        [y, st, r] = proc_Ariza_Denetle(u, y, st, P, tb);
        st.pv_rec(1) = st.pv_rec(1) - 1; st.pv_depth = st.pv_depth - 1;
    end
end

function [y, st, r] = call_Hepsini_Kapat(u, y, st, P, tb)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    if st.pv_rec(3) < 12 && st.pv_depth < 200
        st.pv_rec(3) = st.pv_rec(3) + 1; st.pv_depth = st.pv_depth + 1;
        [y, st, r] = proc_Hepsini_Kapat(u, y, st, P, tb);
        st.pv_rec(3) = st.pv_rec(3) - 1; st.pv_depth = st.pv_depth - 1;
    end
end

function [y, st, r] = call_Bekle_Sabit(u, y, st, P, tb)
    % parametreler degerle gecer (C gibi): eski deger geri yuklenir
    r = NaN;
    if st.pv_rec(2) < 12 && st.pv_depth < 200
        st.pv_rec(2) = st.pv_rec(2) + 1; st.pv_depth = st.pv_depth + 1;
        [y, st, r] = proc_Bekle_Sabit(u, y, st, P, tb);
        st.pv_rec(2) = st.pv_rec(2) - 1; st.pv_depth = st.pv_depth - 1;
    end
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

function r = pv_or(a, b)
if pv_isint(a) && pv_isint(b), r = pv_bop(a, b, 2);
else, r = double(a ~= 0 || b ~= 0); end
end

function r = pv_getbit(x, k)
r = mod(floor(fix(x) / 2^fix(k)), 2);
end