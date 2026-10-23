%% Yakit_Yonetimi - MEX derleme betigi
%% Calistirma:  build_Yakit_Yonetimi
fprintf('Derleniyor: Yakit_Yonetimi_sfun_mex.c\n');
mex('Yakit_Yonetimi_sfun_mex.c');
fprintf('Tamam. Simulink''te "S-Function" bloguna Yakit_Yonetimi_sfun_mex yazin.\n');
fprintf('Ayrintili olay kaydi isterseniz: mex -DSF_VERBOSE Yakit_Yonetimi_sfun_mex.c\n');
