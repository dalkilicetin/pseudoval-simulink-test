%% Turkce_Modul_run - zaman dongusu ve grafik
%% pseudoval tarafindan turkce_adlar.pseudo dosyasindan uretilmistir.
%%
%% Girisleri asagidaki 'SENARYO' bolumunde duzenleyin.

clear; clc; close all;
P  = Turkce_Modul_params();
st = Turkce_Modul_init();
dt = 0.01;          %% [s]
T  = 1.0;                %% kosum suresi [s]
t  = (0:dt:T)';
N  = numel(t);

%% ======================= SENARYO =========================
IN.komut = 0 * ones(N,1);   %% enum 
IN.sicaklik = 0 * ones(N,1);   %% float 

%% Ornek: rampa / basamak tanimlari
%% IN.komut(t>=0.2) = 1;

%% =========================================================

%% --- cikis kayitlari ---
OUT.durum = zeros(N,1);
OUT.cikis = zeros(N,1);

for k = 1:N
    u.komut = IN.komut(k);
    u.sicaklik = IN.sicaklik(k);
    [y, st] = Turkce_Modul_step(u, st, P);
    OUT.durum(k) = y.durum;
    OUT.cikis(k) = y.cikis;
end

%% --- grafik: girisler ---
figure('Name','Girisler');
ni = 2;
subplot(ni,1,1); plot(t, IN.komut, 'LineWidth', 1.2); grid on; ylabel('komut','Interpreter','none');
subplot(ni,1,2); plot(t, IN.sicaklik, 'LineWidth', 1.2); grid on; ylabel('sicaklik','Interpreter','none');
xlabel('t [s]');

%% --- grafik: cikislar ---
figure('Name','Cikislar');
no = 2;
subplot(no,1,1); stairs(t, OUT.durum, 'LineWidth', 1.2); grid on; ylabel('durum','Interpreter','none');
subplot(no,1,2); stairs(t, OUT.cikis, 'LineWidth', 1.2); grid on; ylabel('cikis','Interpreter','none');
xlabel('t [s]');

fprintf('Kosum tamam: %d adim, %.2f s\n', N, T);