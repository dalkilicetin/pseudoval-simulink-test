/* ==========================================================================
 *  Tum_Komutlar  —  Level-2 C MEX S-Function
 *  pseudoval tarafından tum_komutlar.pseudo dosyasından ÜRETİLMİŞTİR — elle düzenlemeyin.
 *
 *  Derleme :  mex Tum_Komutlar_sfun_mex.c
 *  Örnekleme zamanı : 10 ms
 *
 *  UYARI: Simulink Design Verifier bu bloğun içine BAKAMAZ.
 *         Formal analiz gerekiyorsa hedef Stateflow olmalıdır.
 * ========================================================================== */
#define S_FUNCTION_NAME  Tum_Komutlar_sfun_mex
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
  #define SF_LOG(msg)  ssPrintf("[%s] %s\n", "Tum_Komutlar", msg)
#else
  #define SF_LOG(msg)  ((void)0)
#endif

/* ---- sabitler ---- */
#define K_P_MAX  (80.0)
#define K_N_ADIM  (4.0)
/* ---- semboller (hata kodları, enum üyeleri) ---- */
#define SYM_ASIRI_BASINC  (1.0)
#define SYM_BASLA  (1.0)
#define SYM_BEKLE  (0.0)
#define SYM_CALISIYOR  (2.0)
#define SYM_DUR  (2.0)
#define SYM_F0  (0.0)
#define SYM_F1  (1.0)
#define SYM_F2  (2.0)
#define SYM_HATA  (3.0)
#define SYM_HAZIR  (1.0)
#define SYM_KAPALI  (0.0)
#define SYM_OK  (0.0)
#define SYM_ZAMAN_ASIMI  (2.0)

#define NU  5
#define NY  9
#define NV  7

#define NW  3

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
static real_T pv_getbit(real_T x, real_T k) {
    return (real_T)(((long long)x >> (long long)k) & 1);
}
static real_T pv_shl(real_T a, real_T b) {
    return (real_T)((long long)a << (long long)(b > 0.0 ? b : 0.0));
}
static real_T pv_or(real_T a, real_T b) {
    if (pv_isint(a) && pv_isint(b))
        return (real_T)((long long)a | (long long)b);
    return (a != 0.0 || b != 0.0) ? 1.0 : 0.0;
}
static real_T pv_rol(real_T x, real_T k, real_T w, int right) {
    long long W = (long long)w, K = (long long)k % (W ? W : 1);
    unsigned long long m = (W >= 64) ? ~0ULL : ((1ULL << W) - 1ULL);
    unsigned long long X = ((unsigned long long)(long long)x) & m;
    if (K < 0) K += W;
    if (K == 0) return (real_T)X;
    return (real_T)((right ? ((X >> K) | (X << (W - K)))
                           : ((X << K) | (X >> (W - K)))) & m);
}
static real_T pv_shr(real_T a, real_T b) {
    return (real_T)((long long)a >> (long long)(b > 0.0 ? b : 0.0));
}
static real_T pv_xor(real_T a, real_T b) {
    if (pv_isint(a) && pv_isint(b))
        return (real_T)((long long)a ^ (long long)b);
    return ((a != 0.0) != (b != 0.0)) ? 1.0 : 0.0;
}
static real_T pv_mod(real_T a, real_T b) {   /* C / IEC: işaret bölünenden */
    if (b == 0.0) return 0.0;
    return fmod(a, b);
}
static real_T pv_div(real_T a, real_T b) {   /* IEC DIV: sıfıra doğru */
    if (b == 0.0) return 0.0;
    return trunc(a / b);
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
static int pv_rec[4];   /* prosedür başına iç içe çağrı sayısı */
static int pv_depth;          /* toplam çağrı derinliği */

static real_T proc_Tum_Komutlar(SfState *S, const real_T *u, int pv_tb);
static real_T proc_Kare(SfState *S, const real_T *u, int pv_tb);
static real_T proc_Topla(SfState *S, const real_T *u, int pv_tb);
static real_T proc_Say(SfState *S, const real_T *u, int pv_tb);
static real_T proc__init(SfState *S, const real_T *u, int pv_tb);
static real_T call_Kare(SfState *S, const real_T *u, int pv_tb, real_T a0);
static real_T call_Topla(SfState *S, const real_T *u, int pv_tb, real_T a0, real_T a1);
static real_T call_Say(SfState *S, const real_T *u, int pv_tb, real_T a0);

/* ================= üretilen prosedürler ================= */
static real_T proc_Tum_Komutlar(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    /* READ basinc — giriş portundan gelir */
    /* READ komut — giriş portundan gelir */
    /* READ izin — giriş portundan gelir */
    S->y[3] += 1.0;
    if ((u[0] > K_P_MAX)) {   /* satır 46 */
      S->y[6] = SYM_ASIRI_BASINC;
      S->y[2] = SYM_HATA;
      SF_LOG("basinc yuksek: {basinc}");
      SF_LOG("ABORT sekans");
    } else if (((u[0] > 50.0) && (u[2] == 1.0))) {   /* satır 51 */
      S->y[6] = SYM_OK;
    } else if ((!(u[2]))) {   /* satır 53 */
      S->y[6] = SYM_OK;
      S->y[3] -= 1.0;
    } else {
      S->y[6] = 0.0;
    }
    /* SWITCH mod — satır 59 */
    if (EQ(S->y[2], SYM_KAPALI)) {
      S->y[0] = 0.0;
      S->y[1] = 0.0;
      if ((u[1] == SYM_BASLA)) {   /* satır 63 */
        S->y[2] = SYM_HAZIR;
        SF_LOG("ENTER HAZIR");
      }
    } else if (EQ(S->y[2], SYM_HAZIR)) {
      S->y[1] = 1.0;
      /* WAIT 50 ms — satır 69 */
      if (!pv_ton(S, pv_tb + 0, 50.0, -1)) goto pv_blk_2;   /* WAIT bekliyor — bloğun kalanı atlanır */
      S->y[0] = 1.0;
      S->y[2] = SYM_CALISIYOR;
      SF_LOG("ACK komut");
      pv_blk_2: ;
    } else if (EQ(S->y[2], SYM_CALISIYOR) || EQ(S->y[2], SYM_HATA)) {
      if ((u[1] == SYM_DUR)) {   /* satır 74 */
        S->y[2] = SYM_KAPALI;
        SF_LOG("REJECT komut");
        goto pv_sw_end_1;   /* EXIT SWITCH */
      }
      /* WAIT UNTIL basinc < 20 TIMEOUT 100 ms — satır 79 */
      if (!pv_ton(S, pv_tb + 1, 100.0, (((u[0] < 20.0)) ? 1 : 0))) goto pv_blk_3;   /* WAIT bekliyor — bloğun kalanı atlanır */
      S->y[0] = 0.0;
      pv_blk_3: ;
    } else {
      S->y[2] = SYM_KAPALI;
    }
    pv_sw_end_1: ;
    /* SWITCH faz — satır 84 */
    if (EQ(S->v[1], SYM_F0)) {
      S->v[1] = SYM_F1;
    } else if (EQ(S->v[1], SYM_F1)) {
      /* WAIT 30 ms THEN faz := F2 — satır 88 */
      if (!pv_ton(S, pv_tb + 2, 30.0, -1)) goto pv_blk_5;   /* WAIT bekliyor — bloğun kalanı atlanır */
      S->v[1] = SYM_F2;
      pv_blk_5: ;
    } else if (EQ(S->v[1], SYM_F2)) {
      S->v[1] = SYM_F0;
    } else {
      /* NOP */
    }
    S->y[4] = 0.0;
    S->v[2] = 1.0;
    {   /* WHILE — satır 95 */
        int pv_n6 = 0;
        while ((S->v[2] <= K_N_ADIM)) {
            if (++pv_n6 > SF_MAX_WHILE) break;
          if ((S->v[2] == 3.0)) {   /* satır 96 */
            goto pv_step6;   /* CONTINUE — FOR adımına */
          }
          S->y[4] = (S->y[4] + (S->v[2] * 0.5));
        pv_step6: ;
          S->v[2] = (S->v[2] + 1.0);
        }
    }
    S->v[0] = 0.0;
    {   /* WHILE — satır 102 */
        int pv_n7 = 0;
        while ((S->v[0] < u[4])) {
            if (++pv_n7 > SF_MAX_WHILE) break;
          S->v[0] = (S->v[0] + 1.0);
          if ((S->v[0] > 4.0)) {   /* satır 104 */
            break;   /* EXIT LOOP */
          }
        }
    }
    S->y[5] = pv_or(pv_and(u[3], 4080.0), pv_shl(pv_getbit(u[3], 3.0), 4.0));
    S->y[5] = pv_xor(pv_rol(S->y[5], 3.0, 16.0, 0), pv_shr(u[3], 2.0));
    if ((pv_getbit(u[3], 0.0) == 1.0)) {   /* satır 110 */
      S->y[5] = ((real_T)((long long)(S->y[5]) | (1LL << (long long)(15.0))));
    } else {
      S->y[5] = ((real_T)((long long)(S->y[5]) & ~(1LL << (long long)(1.0))));
    }
    S->y[7] = ((fmin(fmax((u[0] * 2.0), 0.0), 150.0) + (((u[2]) != 0.0) ? (trunc((u[0] / 3.0))) : (round((u[0] / 3.0))))) + (((long long)(pv_mod(u[4], 3.0)) == 0) ? (1.0) : (((long long)(pv_mod(u[4], 3.0)) == 1) ? (10.0) : 100.0)));
    S->y[7] = ((((((S->y[7] + pv_div(u[4], 3.0)) + fabs(fmin(fmin(u[0], 40.0), 60.0))) + fmax(1.0, 2.0)) + sqrt(u[0])) + pv_mod((-(7.0)), 3.0)) + pow(2.0, 3.0));
    {
    real_T pv_f8 = call_Kare(S, u, pv_tb + 3, (u[0] / 10.0));   /* KARE((basinc / 10)) */
    real_T pv_f9 = PV_NV(pv_f8) ? PV_NOVAL : call_Topla(S, u, pv_tb + 3, S->v[0], 2.0);
        if (!PV_NV(pv_f9)) S->y[8] = (pv_f8 + pv_f9);
    }
    (void)call_Say(S, u, pv_tb + 3, u[4]);   /* CALL Say */
    if (S->stop != 0.0) return PV_NOVAL;
    S->chk = ((S->y[3] >= 0.0)) ? 1.0 : 0.0;   /* CHECK */
    S->chk = ((S->y[4] >= 0.0)) ? 1.0 : 0.0;   /* CHECK */
    SF_LOG("SEND hata -> Yer");
    /* WRITE valf — çıkış portuna yazılır */
    /* WRITE pompa — çıkış portuna yazılır */
    if ((S->y[3] > 1000000.0)) {   /* satır 124 */
      S->stop = 1.0; return PV_NOVAL;   /* EXIT LOOP — çevrim biter */
    }
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc_Kare(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    {
        return ((S->v[3] * S->v[3]));   /* RETURN değeri */
    }
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc_Topla(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    if ((S->v[4] > 3.0)) {   /* satır 135 */
      {
          return ((S->v[4] + S->v[5]));   /* RETURN değeri */
      }
    }
    {
        return ((S->v[4] - S->v[5]));   /* RETURN değeri */
    }
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc_Say(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    if ((S->v[6] > 0.0)) {   /* satır 142 */
      (void)call_Say(S, u, pv_tb + 0, (S->v[6] - 1.0));   /* CALL Say */
      if (S->stop != 0.0) return PV_NOVAL;
    }
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc__init(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    S->y[3] = 0.0;
    S->y[4] = 0.0;
    S->y[0] = 0.0;
    S->y[1] = 0.0;
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T call_Kare(SfState *S, const real_T *u, int pv_tb, real_T a0)
{
    real_T r = PV_NOVAL;
    real_T ps0 = S->v[3];
    if (pv_rec[0] < 12 && pv_depth < 200) {
        pv_rec[0]++; pv_depth++;
        S->v[3] = a0;   /* x */
        r = proc_Kare(S, u, pv_tb);
        pv_rec[0]--; pv_depth--;
    }
    S->v[3] = ps0;
    return r;
}
static real_T call_Topla(SfState *S, const real_T *u, int pv_tb, real_T a0, real_T a1)
{
    real_T r = PV_NOVAL;
    real_T ps0 = S->v[4];
    real_T ps1 = S->v[5];
    if (pv_rec[2] < 12 && pv_depth < 200) {
        pv_rec[2]++; pv_depth++;
        S->v[4] = a0;   /* a */
        S->v[5] = a1;   /* b */
        r = proc_Topla(S, u, pv_tb);
        pv_rec[2]--; pv_depth--;
    }
    S->v[4] = ps0;
    S->v[5] = ps1;
    return r;
}
static real_T call_Say(SfState *S, const real_T *u, int pv_tb, real_T a0)
{
    real_T r = PV_NOVAL;
    real_T ps0 = S->v[6];
    if (pv_rec[1] < 12 && pv_depth < 200) {
        pv_rec[1]++; pv_depth++;
        S->v[6] = a0;   /* k */
        r = proc_Say(S, u, pv_tb);
        pv_rec[1]--; pv_depth--;
    }
    S->v[6] = ps0;
    return r;
}

/* ================= S-Function arayüzü ================= */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    if (!ssSetNumInputPorts(S, NU)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);   /* basinc */
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);   /* komut */
    ssSetInputPortWidth(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);   /* izin */
    ssSetInputPortWidth(S, 3, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 1);   /* kelime */
    ssSetInputPortWidth(S, 4, 1);
    ssSetInputPortDirectFeedThrough(S, 4, 1);   /* n */
    if (!ssSetNumOutputPorts(S, NY)) return;
    ssSetOutputPortWidth(S, 0, 1);   /* valf */
    ssSetOutputPortWidth(S, 1, 1);   /* pompa */
    ssSetOutputPortWidth(S, 2, 1);   /* mod */
    ssSetOutputPortWidth(S, 3, 1);   /* sayac */
    ssSetOutputPortWidth(S, 4, 1);   /* toplam */
    ssSetOutputPortWidth(S, 5, 1);   /* bitler */
    ssSetOutputPortWidth(S, 6, 1);   /* hata */
    ssSetOutputPortWidth(S, 7, 1);   /* f */
    ssSetOutputPortWidth(S, 8, 1);   /* sonuc */

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
    st->y[0] = 0.0;   /* valf = FALSE */
    st->y[1] = 0.0;   /* pompa = 0 */
    st->y[2] = 0.0;   /* mod = KAPALI */
    st->y[3] = 0.0;   /* sayac = 0 */
    st->y[4] = 0.0;   /* toplam = 0 */
    st->y[5] = 0.0;   /* bitler = 0 */
    st->y[6] = 0.0;   /* hata = 0 */
    st->y[7] = 0.0;   /* f = 0 */
    st->y[8] = 0.0;   /* sonuc = 0 */
    st->v[0] = 0.0;   /* LOCAL adim = 0 */
    st->v[1] = 0.0;   /* LOCAL faz = F0 */
    st->v[2] = 0.0;   /* LOCAL i = 0 */
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    SfState *sf = (SfState *)ssGetDWork(S, 0);
    real_T u[NU > 0 ? NU : 1];
    UNUSED_ARG(tid);

    u[0] = *ssGetInputPortRealSignalPtrs(S, 0)[0];   /* basinc */
    u[1] = *ssGetInputPortRealSignalPtrs(S, 1)[0];   /* komut */
    u[2] = *ssGetInputPortRealSignalPtrs(S, 2)[0];   /* izin */
    u[3] = *ssGetInputPortRealSignalPtrs(S, 3)[0];   /* kelime */
    u[4] = *ssGetInputPortRealSignalPtrs(S, 4)[0];   /* n */

    sf->stop = 0.0;
    sf->tick += 1.0;

    /* --- başlangıç: ilk çevrimde, gövdeden önce, BİR KEZ --- */
    if (sf->inited == 0.0) {
        sf->inited = 1.0;
        (void)proc__init(sf, u, 3);
    }

    (void)proc_Tum_Komutlar(sf, u, 0);

    /* --- bu çevrimde ulaşılmayan WAIT zamanlayıcıları sıfırlanır --- */
    {
        int k;
        for (k = 0; k < NW; k++)
            if (sf->ton_on[k] != 0.0 && sf->ton_seen[k] != sf->tick)
                sf->ton_on[k] = 0.0;
    }

    *ssGetOutputPortRealSignal(S, 0) = sf->y[0];   /* valf */
    *ssGetOutputPortRealSignal(S, 1) = sf->y[1];   /* pompa */
    *ssGetOutputPortRealSignal(S, 2) = sf->y[2];   /* mod */
    *ssGetOutputPortRealSignal(S, 3) = sf->y[3];   /* sayac */
    *ssGetOutputPortRealSignal(S, 4) = sf->y[4];   /* toplam */
    *ssGetOutputPortRealSignal(S, 5) = sf->y[5];   /* bitler */
    *ssGetOutputPortRealSignal(S, 6) = sf->y[6];   /* hata */
    *ssGetOutputPortRealSignal(S, 7) = sf->y[7];   /* f */
    *ssGetOutputPortRealSignal(S, 8) = sf->y[8];   /* sonuc */
}

static void mdlTerminate(SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
