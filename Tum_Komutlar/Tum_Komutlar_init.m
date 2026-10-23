function st = Tum_Komutlar_init()
%% Tum_Komutlar - kalici durum yapisini baslatir

st.y_prev.valf = 0.0;   %% FALSE
st.y_prev.pompa = 0.0;   %% 0
st.y_prev.mod = 0.0;   %% KAPALI
st.y_prev.sayac = 0.0;   %% 0
st.y_prev.toplam = 0.0;   %% 0
st.y_prev.bitler = 0.0;   %% 0
st.y_prev.hata = 0.0;   %% 0
st.y_prev.f = 0.0;   %% 0
st.y_prev.sonuc = 0.0;   %% 0
st.adim = 0.0;
st.faz = 0.0;
st.i = 0.0;
st.x = 0.0;
st.a = 0.0;
st.b = 0.0;
st.k = 0.0;
st.ton_on = zeros(1, 3);    %% WAIT zamanlayicilari
st.ton_et = zeros(1, 3);
st.ton_seen = zeros(1, 3);
st.ton_done = zeros(1, 3);
st.tick = 0;
st.stop = 0;
st.inited = 0;
st.check = 0;

end