/* ==========================================================================
 *  Turkce_Modul  —  Level-2 C MEX S-Function
 *  pseudoval tarafından turkce_adlar.pseudo dosyasından ÜRETİLMİŞTİR — elle düzenlemeyin.
 *
 *  Derleme :  mex Turkce_Modul_sfun_mex.c
 *  Örnekleme zamanı : 10 ms
 *
 *  UYARI: Simulink Design Verifier bu bloğun içine BAKAMAZ.
 *         Formal analiz gerekiyorsa hedef Stateflow olmalıdır.
 * ========================================================================== */
#define S_FUNCTION_NAME  Turkce_Modul_sfun_mex
#define S_FUNCTION_LEVEL 2
#include "simstruc.h"
#include <math.h>
#include <string.h>

#define SF_DT_MS   (10)
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
  #define SF_LOG(msg)  ssPrintf("[%s] %s\n", "Turkce_Modul", msg)
#else
  #define SF_LOG(msg)  ((void)0)
#endif

/* ---- sabitler ---- */
#define K_ESIK  (50.0)
/* ---- semboller (hata kodları, enum üyeleri) ---- */
#define SYM_ACIK  (1.0)
#define SYM_BEKLE  (0.0)
#define SYM_KAPALI  (0.0)
#define SYM_CALIS  (1.0)
#define SYM_SALIS  (2.0)

#define NU  2
#define NY  2
#define NV  2

#define NW  1

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
static int pv_rec[2];   /* prosedür başına iç içe çağrı sayısı */
static int pv_depth;          /* toplam çağrı derinliği */

static real_T proc_Turkce_Modul(SfState *S, const real_T *u, int pv_tb);
static real_T proc_Olcekle(SfState *S, const real_T *u, int pv_tb);
static real_T proc__init(SfState *S, const real_T *u, int pv_tb);
static real_T call_Olcekle(SfState *S, const real_T *u, int pv_tb, real_T a0);

/* ================= üretilen prosedürler ================= */
static real_T proc_Turkce_Modul(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    if (((u[0] == SYM_CALIS) && (u[1] > K_ESIK))) {   /* satır 15 */
      S->y[0] = SYM_ACIK;
      S->v[0] += 1.0;
      S->y[1] = S->v[0];
    } else if ((u[0] == SYM_SALIS)) {   /* satır 19 */
      S->y[0] = SYM_KAPALI;
      /* WAIT 30 ms — satır 21 */
      if (!pv_ton(S, pv_tb + 0, 30.0, -1)) goto pv_blk_1;   /* WAIT bekliyor — bloğun kalanı atlanır */
      {
      real_T pv_f2 = call_Olcekle(S, u, pv_tb + 1, u[1]);   /* ÖLÇEKLE(sıcaklık) */
          if (!PV_NV(pv_f2)) S->y[1] = pv_f2;
      }
      pv_blk_1: ;
    } else {
      S->v[0] = 0.0;
      S->y[1] = 3.0;
    }
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc_Olcekle(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    {
        return (((S->v[1] * 2.0) + K_ESIK));   /* RETURN değeri */
    }
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc__init(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    /* başlangıç yok */
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T call_Olcekle(SfState *S, const real_T *u, int pv_tb, real_T a0)
{
    real_T r = PV_NOVAL;
    real_T ps0 = S->v[1];
    if (pv_rec[1] < 12 && pv_depth < 200) {
        pv_rec[1]++; pv_depth++;
        S->v[1] = a0;   /* değer */
        r = proc_Olcekle(S, u, pv_tb);
        pv_rec[1]--; pv_depth--;
    }
    S->v[1] = ps0;
    return r;
}

/* ================= S-Function arayüzü ================= */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    if (!ssSetNumInputPorts(S, NU)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);   /* komut */
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);   /* sıcaklık */
    if (!ssSetNumOutputPorts(S, NY)) return;
    ssSetOutputPortWidth(S, 0, 1);   /* durum */
    ssSetOutputPortWidth(S, 1, 1);   /* çıkış */

    ssSetNumSampleTimes(S, 1);
    ssSetNumDWork(S, 1);
    ssSetDWorkWidth(S, 0, (int_T)(sizeof(SfState) / sizeof(real_T)) + 1);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                    SS_OPTION_DISCRETE_VALUED_OUTPUT);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, 0.01);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
    SfState *st = (SfState *)ssGetDWork(S, 0);
    memset(st, 0, sizeof(SfState));
    st->y[0] = 0.0;   /* durum = KAPALI */
    st->y[1] = 0.0;   /* çıkış = 0 */
    st->v[0] = 0.0;   /* LOCAL sayaç = 0 */
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    SfState *sf = (SfState *)ssGetDWork(S, 0);
    real_T u[NU > 0 ? NU : 1];
    UNUSED_ARG(tid);

    u[0] = *ssGetInputPortRealSignalPtrs(S, 0)[0];   /* komut */
    u[1] = *ssGetInputPortRealSignalPtrs(S, 1)[0];   /* sıcaklık */

    sf->stop = 0.0;
    sf->tick += 1.0;

    /* --- başlangıç: ilk çevrimde, gövdeden önce, BİR KEZ --- */
    if (sf->inited == 0.0) {
        sf->inited = 1.0;
        (void)proc__init(sf, u, 1);
    }

    (void)proc_Turkce_Modul(sf, u, 0);

    /* --- bu çevrimde ulaşılmayan WAIT zamanlayıcıları sıfırlanır --- */
    {
        int k;
        for (k = 0; k < NW; k++)
            if (sf->ton_on[k] != 0.0 && sf->ton_seen[k] != sf->tick)
                sf->ton_on[k] = 0.0;
    }

    *ssGetOutputPortRealSignal(S, 0) = sf->y[0];   /* durum */
    *ssGetOutputPortRealSignal(S, 1) = sf->y[1];   /* çıkış */
}

static void mdlTerminate(SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
