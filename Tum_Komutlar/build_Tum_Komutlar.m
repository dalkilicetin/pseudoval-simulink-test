%% Tum_Komutlar - MEX derleme betigi
%% Calistirma:  build_Tum_Komutlar
fprintf('Derleniyor: Tum_Komutlar_sfun_mex.c\n');
mex('Tum_Komutlar_sfun_mex.c');
fprintf('Tamam. Simulink''te "S-Function" bloguna Tum_Komutlar_sfun_mex yazin.\n');
fprintf('Ayrintili olay kaydi isterseniz: mex -DSF_VERBOSE Tum_Komutlar_sfun_mex.c\n');
