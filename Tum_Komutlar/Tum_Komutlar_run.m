%% Tum_Komutlar_run - zaman dongusu ve grafik
%% pseudoval tarafindan tum_komutlar.pseudo dosyasindan uretilmistir.
%%
%% Girisleri asagidaki 'SENARYO' bolumunde duzenleyin.

clear; clc; close all;
P  = Tum_Komutlar_params();
st = Tum_Komutlar_init();
dt = 0.01;          %% [s]
T  = 1.0;                %% kosum suresi [s]
t  = (0:dt:T)';
N  = numel(t);

%% ======================= SENARYO =========================
IN.basinc = 0 * ones(N,1);   %% float [bar]
IN.komut = 0 * ones(N,1);   %% enum 
IN.izin = 0 * ones(N,1);   %% bool 
IN.kelime = 0 * ones(N,1);   %% uint16 
IN.n = 0 * ones(N,1);   %% uint8 

%% Ornek: rampa / basamak tanimlari
%% IN.basinc(t>=0.2) = 1;

%% =========================================================

%% --- cikis kayitlari ---
OUT.valf = zeros(N,1);
OUT.pompa = zeros(N,1);
OUT.mod = zeros(N,1);
OUT.sayac = zeros(N,1);
OUT.toplam = zeros(N,1);
OUT.bitler = zeros(N,1);
OUT.hata = zeros(N,1);
OUT.f = zeros(N,1);
OUT.sonuc = zeros(N,1);

for k = 1:N
    u.basinc = IN.basinc(k);
    u.komut = IN.komut(k);
    u.izin = IN.izin(k);
    u.kelime = IN.kelime(k);
    u.n = IN.n(k);
    [y, st] = Tum_Komutlar_step(u, st, P);
    OUT.valf(k) = y.valf;
    OUT.pompa(k) = y.pompa;
    OUT.mod(k) = y.mod;
    OUT.sayac(k) = y.sayac;
    OUT.toplam(k) = y.toplam;
    OUT.bitler(k) = y.bitler;
    OUT.hata(k) = y.hata;
    OUT.f(k) = y.f;
    OUT.sonuc(k) = y.sonuc;
end

%% --- grafik: girisler ---
figure('Name','Girisler');
ni = 5;
subplot(ni,1,1); plot(t, IN.basinc, 'LineWidth', 1.2); grid on; ylabel('basinc','Interpreter','none');
subplot(ni,1,2); plot(t, IN.komut, 'LineWidth', 1.2); grid on; ylabel('komut','Interpreter','none');
subplot(ni,1,3); plot(t, IN.izin, 'LineWidth', 1.2); grid on; ylabel('izin','Interpreter','none');
subplot(ni,1,4); plot(t, IN.kelime, 'LineWidth', 1.2); grid on; ylabel('kelime','Interpreter','none');
subplot(ni,1,5); plot(t, IN.n, 'LineWidth', 1.2); grid on; ylabel('n','Interpreter','none');
xlabel('t [s]');

%% --- grafik: cikislar ---
figure('Name','Cikislar');
no = 9;
subplot(no,1,1); stairs(t, OUT.valf, 'LineWidth', 1.2); grid on; ylabel('valf','Interpreter','none');
subplot(no,1,2); stairs(t, OUT.pompa, 'LineWidth', 1.2); grid on; ylabel('pompa','Interpreter','none');
subplot(no,1,3); stairs(t, OUT.mod, 'LineWidth', 1.2); grid on; ylabel('mod','Interpreter','none');
subplot(no,1,4); stairs(t, OUT.sayac, 'LineWidth', 1.2); grid on; ylabel('sayac','Interpreter','none');
subplot(no,1,5); stairs(t, OUT.toplam, 'LineWidth', 1.2); grid on; ylabel('toplam','Interpreter','none');
subplot(no,1,6); stairs(t, OUT.bitler, 'LineWidth', 1.2); grid on; ylabel('bitler','Interpreter','none');
subplot(no,1,7); stairs(t, OUT.hata, 'LineWidth', 1.2); grid on; ylabel('hata','Interpreter','none');
subplot(no,1,8); stairs(t, OUT.f, 'LineWidth', 1.2); grid on; ylabel('f','Interpreter','none');
subplot(no,1,9); stairs(t, OUT.sonuc, 'LineWidth', 1.2); grid on; ylabel('sonuc','Interpreter','none');
xlabel('t [s]');

fprintf('Kosum tamam: %d adim, %.2f s\n', N, T);