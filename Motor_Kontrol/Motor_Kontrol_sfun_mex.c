/* ==========================================================================
 *  Motor_Kontrol  —  Level-2 C MEX S-Function
 *  pseudoval tarafından YENI_YAZIM_ornek_motor.pseudo dosyasından ÜRETİLMİŞTİR — elle düzenlemeyin.
 *
 *  Derleme :  mex Motor_Kontrol_sfun_mex.c
 *  Örnekleme zamanı : 5 ms
 *
 *  UYARI: Simulink Design Verifier bu bloğun içine BAKAMAZ.
 *         Formal analiz gerekiyorsa hedef Stateflow olmalıdır.
 * ========================================================================== */
#define S_FUNCTION_NAME  Motor_Kontrol_sfun_mex
#define S_FUNCTION_LEVEL 2
#include "simstruc.h"
#include <math.h>
#include <string.h>

#define SF_DT_MS   (5)
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
  #define SF_LOG(msg)  ssPrintf("[%s] %s\n", "Motor_Kontrol", msg)
#else
  #define SF_LOG(msg)  ((void)0)
#endif

/* ---- sabitler ---- */
/* yok */
/* ---- semboller (hata kodları, enum üyeleri) ---- */
#define SYM_CLOSED  (0.0)
#define SYM_FUEL_ON  (2.0)
#define SYM_IGNITION  (3.0)
#define SYM_OFF  (0.0)
#define SYM_ON  (1.0)
#define SYM_OPEN  (1.0)
#define SYM_PREPARE  (1.0)
#define SYM_RUNNING  (4.0)

#define NU  5
#define NY  3
#define NV  1

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

/* ================= ileri bildirimler ================= */

static real_T proc_Motor_Kontrol(SfState *S, const real_T *u, int pv_tb);
static real_T proc__init(SfState *S, const real_T *u, int pv_tb);

/* ================= üretilen prosedürler ================= */
static real_T proc_Motor_Kontrol(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    if ((u[4] == 1.0)) {   /* satır 23 */
      S->v[0] = SYM_OFF;
      return PV_NOVAL;
    }
    /* SWITCH MotorState — satır 28 */
    if (EQ(S->v[0], SYM_OFF)) {
      S->y[0] = 0.0;
      S->y[1] = SYM_CLOSED;
      S->y[2] = SYM_OFF;
      if ((u[0] == 1.0)) {   /* satır 35 */
        S->v[0] = SYM_PREPARE;
      }
    } else if (EQ(S->v[0], SYM_PREPARE)) {
      S->y[0] = 1.0;
      S->y[1] = SYM_CLOSED;
      S->y[2] = SYM_OFF;
      if ((u[1] == 1.0)) {   /* satır 45 */
        S->v[0] = SYM_FUEL_ON;
      }
    } else if (EQ(S->v[0], SYM_FUEL_ON)) {
      S->y[1] = SYM_OPEN;
      S->y[2] = SYM_OFF;
      if ((u[2] == 1.0)) {   /* satır 54 */
        S->v[0] = SYM_IGNITION;
      }
    } else if (EQ(S->v[0], SYM_IGNITION)) {
      S->y[2] = SYM_ON;
      if ((u[3] == 1.0)) {   /* satır 62 */
        S->v[0] = SYM_RUNNING;
      }
    } else if (EQ(S->v[0], SYM_RUNNING)) {
      S->y[0] = 1.0;
      S->y[1] = SYM_OPEN;
      S->y[2] = SYM_OFF;
    }
    return PV_NOVAL;   /* RETURN <değer> yok */
}

static real_T proc__init(SfState *S, const real_T *u, int pv_tb)
{
    (void)S; (void)u; (void)pv_tb;
    S->v[0] = SYM_OFF;
    S->y[0] = 0.0;
    S->y[1] = SYM_CLOSED;
    S->y[2] = SYM_OFF;
    return PV_NOVAL;   /* RETURN <değer> yok */
}


/* ================= S-Function arayüzü ================= */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) return;

    if (!ssSetNumInputPorts(S, NU)) return;
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDirectFeedThrough(S, 0, 1);   /* StartCommand */
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDirectFeedThrough(S, 1, 1);   /* PreparationComplete */
    ssSetInputPortWidth(S, 2, 1);
    ssSetInputPortDirectFeedThrough(S, 2, 1);   /* FuelPressureOK */
    ssSetInputPortWidth(S, 3, 1);
    ssSetInputPortDirectFeedThrough(S, 3, 1);   /* MotorRunning */
    ssSetInputPortWidth(S, 4, 1);
    ssSetInputPortDirectFeedThrough(S, 4, 1);   /* AbortCommand */
    if (!ssSetNumOutputPorts(S, NY)) return;
    ssSetOutputPortWidth(S, 0, 1);   /* MotorEnable */
    ssSetOutputPortWidth(S, 1, 1);   /* FuelValve */
    ssSetOutputPortWidth(S, 2, 1);   /* Ignition */

    ssSetNumSampleTimes(S, 1);
    ssSetNumDWork(S, 1);
    ssSetDWorkWidth(S, 0, (int_T)(sizeof(SfState) / sizeof(real_T)) + 1);
    ssSetDWorkDataType(S, 0, SS_DOUBLE);
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                    SS_OPTION_DISCRETE_VALUED_OUTPUT);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, 0.005);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
    SfState *st = (SfState *)ssGetDWork(S, 0);
    memset(st, 0, sizeof(SfState));
    st->y[0] = 0.0;   /* MotorEnable = 0 */
    st->y[1] = 0.0;   /* FuelValve = 0 */
    st->y[2] = 0.0;   /* Ignition = 0 */
    st->v[0] = 0.0;   /* LOCAL MotorState = OFF */
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    SfState *sf = (SfState *)ssGetDWork(S, 0);
    real_T u[NU > 0 ? NU : 1];
    UNUSED_ARG(tid);

    u[0] = *ssGetInputPortRealSignalPtrs(S, 0)[0];   /* StartCommand */
    u[1] = *ssGetInputPortRealSignalPtrs(S, 1)[0];   /* PreparationComplete */
    u[2] = *ssGetInputPortRealSignalPtrs(S, 2)[0];   /* FuelPressureOK */
    u[3] = *ssGetInputPortRealSignalPtrs(S, 3)[0];   /* MotorRunning */
    u[4] = *ssGetInputPortRealSignalPtrs(S, 4)[0];   /* AbortCommand */

    sf->stop = 0.0;
    sf->tick += 1.0;

    /* --- başlangıç: ilk çevrimde, gövdeden önce, BİR KEZ --- */
    if (sf->inited == 0.0) {
        sf->inited = 1.0;
        (void)proc__init(sf, u, 0);
    }

    (void)proc_Motor_Kontrol(sf, u, 0);


    *ssGetOutputPortRealSignal(S, 0) = sf->y[0];   /* MotorEnable */
    *ssGetOutputPortRealSignal(S, 1) = sf->y[1];   /* FuelValve */
    *ssGetOutputPortRealSignal(S, 2) = sf->y[2];   /* Ignition */
}

static void mdlTerminate(SimStruct *S) { UNUSED_ARG(S); }

#ifdef MATLAB_MEX_FILE
#include "simulink.c"
#else
#include "cg_sfun.h"
#endif
