%% Motor_Kontrol - MEX derleme betigi
%% Calistirma:  build_Motor_Kontrol
fprintf('Derleniyor: Motor_Kontrol_sfun_mex.c\n');
mex('Motor_Kontrol_sfun_mex.c');
fprintf('Tamam. Simulink''te "S-Function" bloguna Motor_Kontrol_sfun_mex yazin.\n');
fprintf('Ayrintili olay kaydi isterseniz: mex -DSF_VERBOSE Motor_Kontrol_sfun_mex.c\n');
