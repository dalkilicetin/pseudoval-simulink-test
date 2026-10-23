function st = Yakit_Yonetimi_init()
%% Yakit_Yonetimi - kalici durum yapisini baslatir

st.y_prev.durum = 0.0;   %% BOSTA
st.y_prev.alt_durum = 0.0;   %% 0
st.y_prev.v_giris = 0.0;   %% 0
st.y_prev.v_cikis = 0.0;   %% 0
st.y_prev.v_tahliye = 0.0;   %% 0
st.y_prev.p_secilen = 0.0;   %% 0
st.y_prev.ariza_kodu = 0.0;   %% 0
st.y_prev.deneme = 0.0;   %% 0
st.y_prev.filtre = 0.0;   %% 0
st.y_prev.histerezis = 0.0;   %% 0
st.y_prev.kalp = 0.0;   %% 0
st.sayac_dengele = 0.0;
st.onceki_p = 0.0;
st.tur = 0.0;
st.j = 0.0;
st.k = 0.0;
st.a = 0.0;
st.b = 0.0;
st.c = 0.0;
st.x = 0.0;
st.y = 0.0;
st.ton_on = zeros(1, 4);    %% WAIT zamanlayicilari
st.ton_et = zeros(1, 4);
st.ton_seen = zeros(1, 4);
st.ton_done = zeros(1, 4);
st.tick = 0;
st.stop = 0;
st.inited = 0;
st.check = 0;

end