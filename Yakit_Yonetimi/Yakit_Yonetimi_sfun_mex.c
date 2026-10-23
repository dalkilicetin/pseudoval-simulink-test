/* ==========================================================================
 *  Yakit_Yonetimi  —  Level-2 C MEX S-Function
 *  pseudoval tarafından cok_kompleks.pseudo dosyasından ÜRETİLMİŞTİR — elle düzenlemeyin.
 *
 *  Derleme :  mex Yakit_Yonetimi_sfun_mex.c
 *  Örnekleme zamanı : 20 ms
 *
 *  UYARI: Simulink Design Verifier bu bloğun içine BAKAMAZ.
 *         Formal analiz gerekiyorsa hedef Stateflow olmalıdır.
 * ========================================================================== */
#define S_FUNCTION_NAME  Yakit_Yonetimi_sfun_mex
#define S_FUNCTION_LEVEL 2
#include "simstruc.h"
#include <math.h>
#include <string.h>

#define SF_DT_MS   (20)
#define SF_EPS     (1e-9)
#define EQ(a,b)    (fabs((a)-(b)) < 1e-9)
#define SF_MAX_WHILE 10000   /* interpreter ile aynı: sonsuz WHILE kesilir */
/* RETURN <değer>e ulaşılmadan biten prosedür «değer yok» döner (NaN):
 * X := F(a) ataması o çevrim yapılmaz, koşul YANLIŞ sayılır */
#ifndef NAN
  #define NAN (0.0 / 0.0)
#endif
#define PV_NOVAL   (NAN)
#define PV_NV(x)   ((x) != (x))

/* Ayrıntılı olay kaydı için derlemede -DSF_VERBOSE ekleyin */
#ifdef SF_VERBOSE
  #define SF_LOG(msg)  ssPrintf("[%s] %s\n", "Yakit_Yonetimi", msg)
#else
  #define SF_LOG(msg)  ((void)0)
#endif

/* ---- sabitler ---- */
#define K_P_UST  (45.0)
#define K_P_ALT  (10.0)
#define K_P_FARK  (5.0)
#define K_T_MAX  (90.0)
#define K_MAKS_DENEME  (3.0)
#define K_ALFA  (0.25)
/* ---- semboller (hata kodları, enum üyeleri) ---- */
#define SYM_ACIL  (3.0)
#define SYM_ARIZA  (5.0)
#define SYM_ASIRI_SICAKLIK  (2.0)
#define SYM_BOSALIYOR  (4.0)
#define SYM_BOSALT  (2.0)
#define SYM_BOSTA  (0.0)
#define SYM_DENGELEME  (3.0)
#define SYM_DOLUM  (1.0)
#define SYM_DOLUYOR  (2.0)
#define SYM_GUVENLI  (6.0)
#define SYM_HATA_YOK  (0.0)
#define SYM_ON_KONTROL  (1.0)
#define SYM_SENSOR_ARIZA  (1.0)
#define SYM_SIFIRLA  (4.0)
#define SYM_TUTARSIZLIK  (4.0)
#define SYM_YOK  (0.0)
#define SYM_ZAMAN_ASIMI  (8.0)

#define NU  7
#define NY  11
#define NV  10

#define NW  4

typedef struct {
    real_T y[NY > 0 ? NY : 1];    /* çıkışlar (kalıcı) */
    real_T v[NV > 0 ? NV : 1];    /* kalıcı yerel değişkenler */
    real_T ton_on[NW > 0 ? NW : 1];    /* WAIT zamanlayıcısı etkin mi */
    real_T ton_et[NW > 0 ? NW : 1];    /* geçen süre [ms] */
    real_T ton_seen[NW > 0 ? NW : 1];  /* en son ulaşıldığı çevrim */
    real_T ton_done[NW > 0 ? NW : 1];  /* doldu mu */
    real_T tick;                  /* çevrim sayacı */
    real_T chk;                   /* son CHECK sonucu */
    real_T inited;                /* başlangıç bloğu koşuldu mu */
    real_T stop;                  /* EXIT LOOP: bu çevrim bitti */
} SfState;

/* ================= yardımcılar (interpreter ile aynı semantik) ================= */
static int pv_isint(real_T x) { return x == floor(x) && fabs(x) < 9.0e15; }
static real_T pv_and(real_T a, real_T b) {
    if (pv_isint(a) && pv_isint(b))   /* IEC: tamsayıda BİT işlemi */
        return (real_T)((long long)a & (long long)b);
    return (a != 0.0 && b != 0.0) ? 1.0 : 0.0;
}
static real_T pv_or(real_T a, real_T b) {
    if (pv_isint(a) && pv_isint(b))
        return (real_T)((long long)a | (long long)b);
    return (a != 0.0 || b != 0.0) ? 1.0 : 0.0;
}
static real_T pv_getbit(real_T x, real_T k) {
    return (real_T)(((long long)x >> (long long)k) & 1);
}

/* ================= WAIT zamanlayıcısı (TON) =================
 * Interpreter (rinterp._ton) ile birebir:
 *   ilk ulaşılışta geçen süre 0; sonraki her çevrimde +SF_DT_MS
 *   süre dolunca (ya da WAIT UNTIL koşulu sağlanınca) geçer ve geçik kalır
 *   cond: -1 = koşul yok, 0/1 = WAIT UNTIL koşulunun değeri
 *   pt  : süre [ms]; < 0 → süre sınırı yok */
static int pv_ton(SfState *S, int k, real_T pt, int cond)
{
    if (S->ton_on[k] == 0.0) {
        S->ton_on[k] = 1.0; S->ton_et[k] = 0.0; S->ton_done[k] = 0.0;
    } else if (S->ton_seen[k] != S->tick && S->ton_done[k] == 0.0) {
        S->ton_et[k] += SF_DT_MS;
    }
    S->ton_seen[k] = S->tick;
    if (S->ton_done[k] != 0.0) return 1;
    if (cond == 1) { S->ton_done[k] = 1.0; return 1; }
    if (pt >= 0.0 && S->ton_et[k] + 1e-9 >= pt) {
        S->ton_done[k] = 1.0; return 1;
    }
    return 0;
}

/* ================= ileri bildirimler ================= */
static int pv_rec[6];   /* prosedür başına iç içe çağrı sayısı */
static int pv_depth;          /* toplam çağrı derinliği */

static real_T proc_Yakit_Yonetimi(SfState *S, const real_T *u, int pv_tb);
static real_T proc_Medyan(SfState *S, const real_T *u, int pv_tb);
static real_T proc_Tutarli(SfState *S, const real_T *u, int pv_tb);
static real_T proc_Ariza_Denetle(SfState *S, const real_T *u, int pv_tb);
static real_T proc_Hepsini_Kapat(SfState *S, const real_T *u, int pv_tb);
static real_T proc_Bekle_Sabit(SfState *S, const real_T *u, int pv_tb);
static real_T proc__init(SfState *S, const real_T *u, int pv_tb);
static real_T call_Medyan(SfState *S, const real_T *u, int pv_tb, real_T a0, real_T a1, real_T a2);
static real_T call_Tutarli(SfState *S, const real_T *u, int pv_tb, real_T a0, real_T a1);
static real_T call_Ariza_Denetle(SfState *S, const real_T *u, int pv_tb);
static real_T call_Hepsini_Kapat(SfState *S, const real_T *u, int pv_tb);
static real_T call_Bekle_Sabit(SfState *S, const real_T *u, int pv_tb);

/* ================= üretilen prosedürler ================= */
static real_T proc_Yakit_Yonetimi(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    S->y[10] = (!(S->y[10]));
    {
    real_T pv_f1 = call_Medyan(S, u, pv_tb + 2, u[0], u[1], u[2]);   /* MEDYAN(p_tank1, p_tank2, p_tank3) */
        if (!PV_NV(pv_f1)) S->y[5] = pv_f1;
    }
    S->y[8] = (S->y[8] + (K_ALFA * (S->y[5] - S->y[8])));
    if ((S->y[8] > K_P_UST)) {   /* satır 56 */
      S->y[9] = 1.0;
    } else if ((S->y[8] < (K_P_UST - K_P_FARK))) {   /* satır 58 */
      S->y[9] = 0.0;
    }
    (void)call_Ariza_Denetle(S, u, pv_tb + 2);   /* CALL Ariza_Denetle */
    if (S->stop != 0.0) return PV_NOVAL;
    if ((u[4] == SYM_ACIL)) {   /* satır 62 */
      S->y[0] = SYM_GUVENLI;
    }
    /* SWITCH durum — satır 65 */
    if (EQ(S->y[0], SYM_BOSTA)) {
      (void)call_Hepsini_Kapat(S, u, pv_tb + 2);   /* CALL Hepsini_Kapat */
      if (S->stop != 0.0) return PV_NOVAL;
      S->y[1] = 0.0;
      if (((u[4] == SYM_DOLUM) && (S->y[6] == SYM_HATA_YOK))) {   /* satır 69 */
        S->y[0] = SYM_ON_KONTROL;
      } else if ((u[4] == SYM_BOSALT)) {   /* satır 71 */
        S->y[0] = SYM_BOSALIYOR;
      }
    } else if (EQ(S->y[0], SYM_ON_KONTROL)) {
      /* SWITCH alt_durum — satır 75 */
      if (EQ(S->y[1], 0.0)) {
        (void)call_Bekle_Sabit(S, u, pv_tb + 2);   /* CALL Bekle_Sabit */
        if (S->stop != 0.0) return PV_NOVAL;
        S->y[1] = 1.0;
      } else if (EQ(S->y[1], 1.0)) {
        {
        real_T pv_f4 = call_Tutarli(S, u, pv_tb + 3, u[0], u[1]);   /* TUTARLI(p_tank1, p_tank2) */
        real_T pv_f5 = PV_NV(pv_f4) ? PV_NOVAL : call_Tutarli(S, u, pv_tb + 3, u[1], u[2]);
        if ((!PV_NV(pv_f5) && (pv_and(pv_f4, pv_f5)))) {   /* satır 80 */
          S->y[1] = 2.0;
        } else {
          S->y[7] += 1.0;
          if ((S->y[7] >= K_MAKS_DENEME)) {   /* satır 84 */
            S->y[6] = pv_or(S->y[6], SYM_TUTARSIZLIK);
            S->y[0] = SYM_ARIZA;
            goto pv_sw_end_3;   /* EXIT SWITCH */
          }
          S->y[1] = 0.0;
        }
        }
      } else if (EQ(S->y[1], 2.0)) {
        S->y[7] = 0.0;
        S->y[0] = SYM_DOLUYOR;
      } else {
        S->y[1] = 0.0;
      }
      pv_sw_end_3: ;
    } else if (EQ(S->y[0], SYM_DOLUYOR)) {
      S->y[2] = 1.0;
      S->y[3] = 0.0;
      /* WAIT UNTIL filtre >= P_UST TIMEOUT 2 s — satır 100 */
      if (!pv_ton(S, pv_tb + 0, (1000.0 * 2.0), (((S->y[8] >= K_P_UST)) ? 1 : 0))) goto pv_blk_6;   /* WAIT bekliyor — bloğun kalanı atlanır */
      if ((S->y[8] >= K_P_UST)) {   /* satır 101 */
        S->y[2] = 0.0;
        S->y[0] = SYM_DENGELEME;
        S->v[0] = 0.0;
      } else {
        S->y[6] = pv_or(S->y[6], SYM_ZAMAN_ASIMI);
        S->y[0] = SYM_ARIZA;
      }
      pv_blk_6: ;
    } else if (EQ(S->y[0], SYM_DENGELEME)) {
      S->v[0] += 1.0;
      (void)call_Bekle_Sabit(S, u, pv_tb + 3);   /* CALL Bekle_Sabit */
      if (S->stop != 0.0) return PV_NOVAL;
      if ((fabs((S->y[8] - S->v[1])) < 0.5)) {   /* satır 112 */
        S->y[0] = SYM_BOSTA;
      } else if ((S->v[0] > 50.0)) {   /* satır 114 */
        S->y[0] = SYM_ARIZA;
      }
    } else if (EQ(S->y[0], SYM_BOSALIYOR)) {
      S->y[3] = 1.0;
      S->y[2] = 0.0;
      if ((S->y[8] < K_P_ALT)) {   /* satır 120 */
        S->y[3] = 0.0;
        S->y[0] = SYM_BOSTA;
      }
    } else if (EQ(S->y[0], SYM_ARIZA)) {
      (void)call_Hepsini_Kapat(S, u, pv_tb + 4);   /* CALL Hepsini_Kapat */
      if (S->stop != 0.0) return PV_NOVAL;
      S->y[4] = 1.0;
      if ((u[4] == SYM_SIFIRLA)) {   /* satır 127 */
        /* WAIT 100 ms — satır 128 */
        if (!pv_ton(S, pv_tb + 1, 100.0, -1)) goto pv_blk_7;   /* WAIT bekliyor — bloğun kalanı atlanır */
        S->y[6] = SYM_HATA_YOK;
        S->y[7] = 0.0;
        S->y[0] = SYM_BOSTA;
        pv_blk_7: ;
      }
    } else if (EQ(S->y[0], SYM_GUVENLI)) {
      (void)call_Hepsini_Kapat(S, u, pv_tb + 4);   /* CALL Hepsini_Kapat */
      if (S->stop != 0.0) return PV_NOVAL;
      S->y[4] = 1.0;
      if ((u[4] == SYM_SIFIRLA)) {   /* satır 136 */
        S->y[0] = SYM_BOSTA;
      }
    } else {
      S->y[0] = SYM_ARIZA;
    }
    S->v[2] = 0.0;
    S->v[3] = 0.0;
    {   /* WHILE — satır 144 */
        int pv_n8 = 0;
        while ((S->v[3] <= 3.0)) {
            if (++pv_n8 > SF_MAX_WHILE) break;
          S->v[4] = 0.0;
          {   /* WHILE — satır 145 */
              int pv_n9 = 0;
              while ((S->v[4] <= 3.0)) {
                  if (++pv_n9 > SF_MAX_WHILE) break;
                if ((pv_getbit(u[6], ((S->v[3] * 4.0) + S->v[4])) == 1.0)) {   /* satır 146 */
                  S->v[2] = (S->v[2] + 1.0);
                }
                if ((S->v[2] > 10.0)) {   /* satır 149 */
                  break;   /* EXIT LOOP */
                }
                S->v[4] = (S->v[4] + 1.0);
              }
          }
          S->v[3] = (S->v[3] + 1.0);
        }
    }
    if ((S->v[2] > 12.0)) {   /* satır 154 */
      S->y[6] = pv_or(S->y[6], SYM_SENSOR_ARIZA);
    }
    S->v[1] = S->y[8];
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc_Medyan(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    if ((((S->v[5] >= S->v[6]) && (S->v[5] <= S->v[7])) || ((S->v[5] <= S->v[6]) && (S->v[5] >= S->v[7])))) {   /* satır 162 */
      {
          return (S->v[5]);   /* RETURN değeri */
      }
    } else if ((((S->v[6] >= S->v[5]) && (S->v[6] <= S->v[7])) || ((S->v[6] <= S->v[5]) && (S->v[6] >= S->v[7])))) {   /* satır 164 */
      {
          return (S->v[6]);   /* RETURN değeri */
      }
    }
    {
        return (S->v[7]);   /* RETURN değeri */
    }
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc_Tutarli(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    {
        return ((fabs((S->v[8] - S->v[9])) < K_P_FARK));   /* RETURN değeri */
    }
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc_Ariza_Denetle(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    if ((u[5] == 0.0)) {   /* satır 175 */
      S->y[6] = pv_or(S->y[6], SYM_SENSOR_ARIZA);
    }
    if ((u[3] > K_T_MAX)) {   /* satır 178 */
      S->y[6] = pv_or(S->y[6], SYM_ASIRI_SICAKLIK);
      if ((S->y[0] != SYM_GUVENLI)) {   /* satır 180 */
        S->y[0] = SYM_ARIZA;
      }
    }
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc_Hepsini_Kapat(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    S->y[2] = 0.0;
    S->y[3] = 0.0;
    S->y[4] = 0.0;
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc_Bekle_Sabit(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    /* WAIT 60 ms — satır 193 */
    if (!pv_ton(S, pv_tb + 0, 60.0, -1)) goto pv_blk_10;   /* WAIT bekliyor — bloğun kalanı atlanır */
    S->y[1] = (S->y[1] + 0.0);
    pv_blk_10: ;
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc__init(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    S->y[0] = SYM_BOSTA;
    S->y[8] = 0.0;
    S->y[7] = 0.0;
    S->y[2] = 0.0;
    S->y[3] = 0.0;
    S->y[4] = 0.0;
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T call_Medyan(SfState *S, const real_T *u, int pv_tb, real_T a0, real_T a1, real_T a2)
{
    real_T r = PV_NOVAL;
    real_T ps0 = S->v[5];
    real_T ps1 = S->v[6];
    real_T ps2 = S->v[7];
    if (pv_rec[3] < 12 && pv_depth < 200) {
        pv_rec[3]++; pv_depth++;
        S->v[5] = a0;   /* a */
        S->v[6] = a1;   /* b */
        S->v[7] = a2;   /* c */
        r = proc_Medyan(S, u, pv_tb);
        pv_rec[3]--; pv_depth--;
    }
    S->v[5] = ps0;
    S->v[6] = ps1;
    S->v[7] = ps2;
    return r;
}
static real_T call_Tutarli(SfState *S, const real_T *u, int pv_tb, real_T a0, real_T a1)
{
    real_T r = PV_NOVAL;
    real_T ps0 = S->v[8];
    real_T ps1 = S->v[9];
    if (pv_rec[4] < 12 && pv_depth < 200) {
        pv_rec[4]++; pv_depth++;
        S->v[8] = a0;   /* x */
        S->v[9] = a1;   /* y */
        r = proc_Tutarli(S, u, pv_tb);
        pv_rec[4]--; pv_depth--;
    }
    S->v[8] = ps0;
    S->v[9] = ps1;
    return r;
}
static real_T call_Ariza_Denetle(SfState *S, const real_T *u, int pv_tb)
{
    real_T r = PV_NOVAL;
    if (pv_rec[0] < 12 && pv_depth < 200) {
        pv_rec[0]++; pv_depth++;
        r = proc_Ariza_Denetle(S, u, pv_tb);
        pv_rec[0]--; pv_depth--;
    }
    return r;
}
static real_T call_Hepsini_Kapat(SfState *S, const real_T *u, int pv_tb)
{
    real_T r = PV_NOVAL;
    if (pv_rec[2] < 12 && pv_depth < 200) {
        pv_rec[2]++; pv_depth++;
        r = proc_Hepsini_Kapat(S, u, pv_tb);
        pv_rec[2]--; pv_depth--;
    }
    return r;
}
static real_T call_Bekle_Sabit(SfState *S, const real_T *u, int pv_tb)
{
    real_T r = PV_NOVAL;
    if (pv_rec[1] < 12 && pv_depth < 200) {
        pv_rec[1]++; pv_depth++;
        r = proc_Bekle_Sabit(S, u, pv_tb);
        pv_rec[1]--; pv_depth--;
    }
    return r;
}

/* ================= S-Function arayüzü ================= */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    if (!ssSetNumInputPorts(S, NU)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);   /* p_tank1 */
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);   /* p_tank2 */
    ssSetInputPortWidth(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);   /* p_tank3 */
    ssSetInputPortWidth(S, 3, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 1);   /* sicaklik */
    ssSetInputPortWidth(S, 4, 1);
    ssSetInputPortDirectFeedThrough(S, 4, 1);   /* komut */
    ssSetInputPortWidth(S, 5, 1);
    ssSetInputPortDirectFeedThrough(S, 5, 1);   /* sensor_ok */
    ssSetInputPortWidth(S, 6, 1);
    ssSetInputPortDirectFeedThrough(S, 6, 1);   /* maske */
    if (!ssSetNumOutputPorts(S, NY)) return;
    ssSetOutputPortWidth(S, 0, 1);   /* durum */
    ssSetOutputPortWidth(S, 1, 1);   /* alt_durum */
    ssSetOutputPortWidth(S, 2, 1);   /* v_giris */
    ssSetOutputPortWidth(S, 3, 1);   /* v_cikis */
    ssSetOutputPortWidth(S, 4, 1);   /* v_tahliye */
    ssSetOutputPortWidth(S, 5, 1);   /* p_secilen */
    ssSetOutputPortWidth(S, 6, 1);   /* ariza_kodu */
    ssSetOutputPortWidth(S, 7, 1);   /* deneme */
    ssSetOutputPortWidth(S, 8, 1);   /* filtre */
    ssSetOutputPortWidth(S, 9, 1);   /* histerezis */
    ssSetOutputPortWidth(S, 10, 1);   /* kalp */

    ssSetNumSampleTimes(S, 1);
    ssSetNumDWork(S, 1);
    ssSetDWorkWidth(S, 0, (int_T)(sizeof(SfState) / sizeof(real_T)) + 1);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                    SS_OPTION_DISCRETE_VALUED_OUTPUT);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, 0.02);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
    SfState *st = (SfState *)ssGetDWork(S, 0);
    memset(st, 0, sizeof(SfState));
    st->y[0] = 0.0;   /* durum = BOSTA */
    st->y[1] = 0.0;   /* alt_durum = 0 */
    st->y[2] = 0.0;   /* v_giris = 0 */
    st->y[3] = 0.0;   /* v_cikis = 0 */
    st->y[4] = 0.0;   /* v_tahliye = 0 */
    st->y[5] = 0.0;   /* p_secilen = 0 */
    st->y[6] = 0.0;   /* ariza_kodu = 0 */
    st->y[7] = 0.0;   /* deneme = 0 */
    st->y[8] = 0.0;   /* filtre = 0 */
    st->y[9] = 0.0;   /* histerezis = 0 */
    st->y[10] = 0.0;   /* kalp = 0 */
    st->v[0] = 0.0;   /* LOCAL sayac_dengele = 0 */
    st->v[1] = 0.0;   /* LOCAL onceki_p = 0 */
    st->v[2] = 0.0;   /* LOCAL tur = 0 */
    st->v[3] = 0.0;   /* LOCAL j = 0 */
    st->v[4] = 0.0;   /* LOCAL k = 0 */
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    SfState *sf = (SfState *)ssGetDWork(S, 0);
    real_T u[NU > 0 ? NU : 1];
    UNUSED_ARG(tid);

    u[0] = *ssGetInputPortRealSignalPtrs(S, 0)[0];   /* p_tank1 */
    u[1] = *ssGetInputPortRealSignalPtrs(S, 1)[0];   /* p_tank2 */
    u[2] = *ssGetInputPortRealSignalPtrs(S, 2)[0];   /* p_tank3 */
    u[3] = *ssGetInputPortRealSignalPtrs(S, 3)[0];   /* sicaklik */
    u[4] = *ssGetInputPortRealSignalPtrs(S, 4)[0];   /* komut */
    u[5] = *ssGetInputPortRealSignalPtrs(S, 5)[0];   /* sensor_ok */
    u[6] = *ssGetInputPortRealSignalPtrs(S, 6)[0];   /* maske */

    sf->stop = 0.0;
    sf->tick += 1.0;

    /* --- başlangıç: ilk çevrimde, gövdeden önce, BİR KEZ --- */
    if (sf->inited == 0.0) {
        sf->inited = 1.0;
        (void)proc__init(sf, u, 4);
    }

    (void)proc_Yakit_Yonetimi(sf, u, 0);

    /* --- bu çevrimde ulaşılmayan WAIT zamanlayıcıları sıfırlanır --- */
    {
        int k;
        for (k = 0; k < NW; k++)
            if (sf->ton_on[k] != 0.0 && sf->ton_seen[k] != sf->tick)
                sf->ton_on[k] = 0.0;
    }

    *ssGetOutputPortRealSignal(S, 0) = sf->y[0];   /* durum */
    *ssGetOutputPortRealSignal(S, 1) = sf->y[1];   /* alt_durum */
    *ssGetOutputPortRealSignal(S, 2) = sf->y[2];   /* v_giris */
    *ssGetOutputPortRealSignal(S, 3) = sf->y[3];   /* v_cikis */
    *ssGetOutputPortRealSignal(S, 4) = sf->y[4];   /* v_tahliye */
    *ssGetOutputPortRealSignal(S, 5) = sf->y[5];   /* p_secilen */
    *ssGetOutputPortRealSignal(S, 6) = sf->y[6];   /* ariza_kodu */
    *ssGetOutputPortRealSignal(S, 7) = sf->y[7];   /* deneme */
    *ssGetOutputPortRealSignal(S, 8) = sf->y[8];   /* filtre */
    *ssGetOutputPortRealSignal(S, 9) = sf->y[9];   /* histerezis */
    *ssGetOutputPortRealSignal(S, 10) = sf->y[10];   /* kalp */
}

static void mdlTerminate(SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
