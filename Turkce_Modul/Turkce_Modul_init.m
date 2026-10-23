function st = Turkce_Modul_init()
%% Turkce_Modul - kalici durum yapisini baslatir

st.y_prev.durum = 0.0;   %% KAPALI
st.y_prev.cikis = 0.0;   %% 0
st.sayac = 0.0;
st.deger = 0.0;
st.ton_on = zeros(1, 1);    %% WAIT zamanlayicilari
st.ton_et = zeros(1, 1);
st.ton_seen = zeros(1, 1);
st.ton_done = zeros(1, 1);
st.tick = 0;
st.stop = 0;
st.inited = 0;
st.check = 0;

end