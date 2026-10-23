function st = Motor_Kontrol_init()
%% Motor_Kontrol - kalici durum yapisini baslatir

st.y_prev.MotorEnable = 0.0;   %% 0
st.y_prev.FuelValve = 0.0;   %% 0
st.y_prev.Ignition = 0.0;   %% 0
st.MotorState = 0.0;
st.ton_on = zeros(1, 1);    %% WAIT zamanlayicilari
st.ton_et = zeros(1, 1);
st.ton_seen = zeros(1, 1);
st.ton_done = zeros(1, 1);
st.tick = 0;
st.stop = 0;
st.inited = 0;
st.check = 0;

end