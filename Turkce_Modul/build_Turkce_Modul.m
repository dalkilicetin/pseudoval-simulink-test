%% Turkce_Modul - MEX derleme betigi
%% Calistirma:  build_Turkce_Modul
fprintf('Derleniyor: Turkce_Modul_sfun_mex.c\n');
mex('Turkce_Modul_sfun_mex.c');
fprintf('Tamam. Simulink''te "S-Function" bloguna Turkce_Modul_sfun_mex yazin.\n');
fprintf('Ayrintili olay kaydi isterseniz: mex -DSF_VERBOSE Turkce_Modul_sfun_mex.c\n');
