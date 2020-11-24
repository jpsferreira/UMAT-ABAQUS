C>********************************************************************
C> Record of revisions:                                              |
C>        Date        Programmer        Description of change        |
C>        ====        ==========        =====================        |
C>     15/11/2017    Joao Ferreira      cont mech general eqs        |
C>     01/11/2018    Joao Ferreira      comments added               |
C>--------------------------------------------------------------------
C>     Description:
C>     UMAT: IMPLEMENTATION OF THE CONSTITUTIVE EQUATIONS BASED UPON 
C>     A STRAIN-ENERGY FUNCTION (SEF).
C>     THIS CODE, AS IS, EXPECTS A SEF BASED ON THE INVARIANTS OF THE 
C>     CAUCHY-GREEN TENSORS. A VISCOELASTIC COMPONENT IS ALSO 
C>     INCLUDED IF NEEDED. 
C>     YOU CAN CHOOSE TO COMPUTE AT THE MATERIAL FRAME AND THEN 
C>     PUSHFORWARD OR  COPUTE AND THE SPATIAL FRAME DIRECTLY.
C>--------------------------------------------------------------------
C>     IF YOU WANT TO ADAPT THE CODE ACCORDING TO YOUR SEF:
C>    ISOMAT - DERIVATIVES OF THE SEF IN ORDER TO THE INVARIANTS
C>    ADD OTHER CONTRIBUTIONS: STRESS AND TANGENT MATRIX
C>-------------------------------------------------------------------- 
C      STATE VARIABLES: CHECK ROUTINES - INITIALIZE, WRITESDV, READSDV.
C>--------------------------------------------------------------------              
C>     UEXTERNALDB: READ FILAMENTS ORIENTATION AND PREFERED DIRECTION
C>--------------------------------------------------------------------
C>---------------------------------------------------------------------
      SUBROUTINE UMAT(STRESS,STATEV,DDSDDE,SSE,SPD,SCD,
     1 RPL,DDSDDT,DRPLDE,DRPLDT,
     2 STRAN,DSTRAN,TIME,DTIME,TEMP,DTEMP,PREDEF,DPRED,CMNAME,
     3 NDI,NSHR,NTENS,NSTATEV,PROPS,NPROPS,COORDS,DROT,PNEWDT,
     4 CELENT,DFGRD0,DFGRD1,NOEL,NPT,LAYER,KSPT,KSTEP,KINC)
C
C----------------------------------------------------------------------
C--------------------------- DECLARATIONS -----------------------------
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'PARAM_UMAT.INC'
C     ADD COMMON BLOCKS HERE IF NEEDED (and in uexternal)
C      COMMON /KBLOCK/KBLOCK

      COMMON /KFIB/FIBORI
C
      CHARACTER*8 CMNAME
C
      INTEGER NDI, NSHR, NTENS, NSTATEV, NPROPS, NOEL, NPT,
     1        LAYER, KSPT, KSTEP, KINC
C     
      DOUBLE PRECISION STRESS(NTENS),STATEV(NSTATEV),
     1 DDSDDE(NTENS,NTENS),DDSDDT(NTENS),DRPLDE(NTENS),
     2 STRAN(NTENS),DSTRAN(NTENS),TIME(2),PREDEF(1),DPRED(1),
     3 PROPS(NPROPS),COORDS(3),DROT(3,3),DFGRD0(3,3),DFGRD1(3,3),
     4 FIBORI(NELEM,4)
C
      DOUBLE PRECISION SSE, SPD, SCD, RPL, DRPLDT, DTIME, TEMP,
     1                 DTEMP,PNEWDT,CELENT
C
      INTEGER NTERM
C
C     FLAGS
C      INTEGER FLAG1
C     UTILITY TENSORS
      DOUBLE PRECISION UNIT2(NDI,NDI),UNIT4(NDI,NDI,NDI,NDI),
     1                 UNIT4S(NDI,NDI,NDI,NDI),
     2                 PROJE(NDI,NDI,NDI,NDI),PROJL(NDI,NDI,NDI,NDI)
C     KINEMATICS
      DOUBLE PRECISION DISTGR(NDI,NDI),C(NDI,NDI),B(NDI,NDI),
     1                 CBAR(NDI,NDI),BBAR(NDI,NDI),DISTGRINV(NDI,NDI),
     2                 UBAR(NDI,NDI),VBAR(NDI,NDI),ROT(NDI,NDI),
     3                 DFGRD1INV(NDI,NDI)
      DOUBLE PRECISION DET,CBARI1,CBARI2
C     VOLUMETRIC CONTRIBUTION
      DOUBLE PRECISION PKVOL(NDI,NDI),SVOL(NDI,NDI),
     1                 CVOL(NDI,NDI,NDI,NDI),CMVOL(NDI,NDI,NDI,NDI)
      DOUBLE PRECISION KBULK,PV,PPV,SSEV
C     ISOCHORIC CONTRIBUTION
      DOUBLE PRECISION SISO(NDI,NDI),PKISO(NDI,NDI),PK2(NDI,NDI),
     1                 CISO(NDI,NDI,NDI,NDI),CMISO(NDI,NDI,NDI,NDI),
     2                 SFIC(NDI,NDI),CFIC(NDI,NDI,NDI,NDI),
     3                 PKFIC(NDI,NDI),CMFIC(NDI,NDI,NDI,NDI)
C     ISOCHORIC ISOTROPIC CONTRIBUTION
      DOUBLE PRECISION C10,C01,SSEISO,DISO(5),PKMATFIC(NDI,NDI),
     1                 SMATFIC(NDI,NDI),SISOMATFIC(NDI,NDI),
     2                 CMISOMATFIC(NDI,NDI,NDI,NDI),
     3                 CISOMATFIC(NDI,NDI,NDI,NDI)   
C     ISOCHORIC ANISOTROPIC CONTRIBUTION
      DOUBLE PRECISION K1,K2,KDISP,SSEANISO,
     1                 DANISO(4),
     2                 PKMATFICANISO(NDI,NDI),
     3                 SANISOMATFIC(NDI,NDI),
     4                 CMANISOMATFIC(NDI,NDI,NDI,NDI),
     6                 CANISOMATFIC(NDI,NDI,NDI,NDI),
     8                 LAMBDA,BARLAMBDA,
     9                 CBARI4
      DOUBLE PRECISION VORIF(3),VD(3),M0(3,3),MM(3,3),
     1        VORIF2(3),VD2(3),N0(3,3),NN(3,3)
C     LIST VARS OF OTHER CONTRIBUTIONS HERE
C
C     VISCOUS PROPERTIES (GENERALIZED MAXWEL DASHPOTS)
      DOUBLE PRECISION VSCPROPS(6)
      INTEGER VV
C     JAUMMAN RATE CONTRIBUTION (REQUIRED FOR ABAQUS UMAT)
      DOUBLE PRECISION CJR(NDI,NDI,NDI,NDI)
C     CAUCHY STRESS AND ELASTICITY TENSOR
      DOUBLE PRECISION SIGMA(NDI,NDI),DDSIGDDE(NDI,NDI,NDI,NDI),
     1                                 DDPKDDE(NDI,NDI,NDI,NDI)
C     TESTING/DEBUG VARS
      DOUBLE PRECISION STEST(NDI,NDI), CTEST(NDI,NDI,NDI,NDI)
C----------------------------------------------------------------------
C-------------------------- INITIALIZATIONS ---------------------------
C----------------------------------------------------------------------
C     IDENTITY AND PROJECTION TENSORS
      UNIT2=ZERO
      UNIT4=ZERO
      UNIT4S=ZERO
      PROJE=ZERO
      PROJL=ZERO
C     KINEMATICS
      DISTGR=ZERO
      C=ZERO
      B=ZERO
      CBAR=ZERO
      BBAR=ZERO
      UBAR=ZERO
      VBAR=ZERO
      ROT=ZERO
      DET=ZERO
      CBARI1=ZERO
      CBARI2=ZERO
C     VOLUMETRIC
      PKVOL=ZERO
      SVOL=ZERO
      CVOL=ZERO
      KBULK=ZERO
      PV=ZERO
      PPV=ZERO
      SSEV=ZERO
C     ISOCHORIC
      SISO=ZERO
      PKISO=ZERO
      PK2=ZERO
      CISO=ZERO
      CFIC=ZERO
      SFIC=ZERO
      PKFIC=ZERO
C     ISOTROPIC
      C10=ZERO
      C01=ZERO
      SSEISO=ZERO
      DISO=ZERO
      PKMATFIC=ZERO
      SMATFIC=ZERO
      SISOMATFIC=ZERO
      CMISOMATFIC=ZERO
      CISOMATFIC=ZERO
C     INITIALIZE OTHER CONT HERE
C
C     JAUMANN RATE
      CJR=ZERO
C     TOTAL CAUCHY STRESS AND ELASTICITY TENSORS
      SIGMA=ZERO
      DDSIGDDE=ZERO
C
C----------------------------------------------------------------------
C------------------------ IDENTITY TENSORS ----------------------------
C----------------------------------------------------------------------
            CALL ONEM(UNIT2,UNIT4,UNIT4S,NDI)
C----------------------------------------------------------------------
C------------------- MATERIAL CONSTANTS AND DATA ----------------------
C----------------------------------------------------------------------
C     VOLUMETRIC
      KBULK    = PROPS(1)
C     ISOCHORIC ISOTROPIC NEO HOOKE
      C10      = PROPS(2)
      C01      = PROPS(3)    
C     ISOCHORIC ANISOTROPIC GHO
      K1      = PROPS(4)
      K2      = PROPS(5)
      KDISP   = PROPS(6)
C     VISCOUS EFFECTS: MAXWELL ELEMENTS (MAX:3)
C      VV       = INT(PROPS(7))
C      VSCPROPS = PROPS(8:13)
C     NUMERICAL COMPUTATIONS
      NTERM    = 60
C
C     STATE VARIABLES
C
      IF ((TIME(1).EQ.ZERO).AND.(KSTEP.EQ.1)) THEN
      CALL INITIALIZE(STATEV)
      ENDIF
C        READ STATEV
      CALL SDVREAD(STATEV)
C      
C----------------------------------------------------------------------
C---------------------------- KINEMATICS ------------------------------
C----------------------------------------------------------------------
C     DISTORTION GRADIENT
      CALL FSLIP(DFGRD1,DISTGR,DET,NDI)
C     INVERSE OF DISTORTION GRADIENT
      CALL MATINV3D(DFGRD1,DFGRD1INV,NDI)
C     INVERSE OF DISTORTION GRADIENT
      CALL MATINV3D(DISTGR,DISTGRINV,NDI)
C     CAUCHY-GREEN DEFORMATION TENSORS
      CALL DEFORMATION(DFGRD1,C,B,NDI)
      CALL DEFORMATION(DISTGR,CBAR,BBAR,NDI)      
C     FIBER UNIT VECTOR AND STRUCTURAL TENSOR
      CALL FIBDIR(FIBORI,M0,MM,NELEM,NOEL,NDI,VORIF,VD,DISTGR,DFGRD1)
C     INVARIANTS OF DEVIATORIC DEFORMATION TENSORS
      CALL INVARIANTS(CBAR,CBARI1,CBARI2,NDI)
C      
      CALL PINVARIANTS(CBAR,CBARI4,NDI,M0,LAMBDA,BARLAMBDA,DET)
C      
C     STRETCH TENSORS
      CALL STRETCH(CBAR,BBAR,UBAR,VBAR,NDI)
C     ROTATION TENSORS
      CALL ROTATION(DISTGR,ROT,UBAR,NDI)
C     DEVIATORIC PROJECTION TENSORS
      CALL PROJEUL(UNIT2,UNIT4S,PROJE,NDI)
C
      CALL PROJLAG(C,UNIT4,PROJL,NDI)
C----------------------------------------------------------------------
C--------------------- CONSTITUTIVE RELATIONS  ------------------------
C----------------------------------------------------------------------
C
C---- VOLUMETRIC ------------------------------------------------------
C     STRAIN-ENERGY AND DERIVATIVES (CHANGE HERE ACCORDING TO YOUR MODEL)
      CALL VOL(SSEV,PV,PPV,KBULK,DET)
      CALL ISOMAT(SSEISO,DISO,C10,C01,CBARI1,CBARI2)
      CALL ANISOMAT(SSEANISO,DANISO,DISO,K1,K2,KDISP,CBARI4,CBARI1)
C
C---- ISOCHORIC ISOTROPIC ---------------------------------------------
C     PK2 'FICTICIOUS' STRESS TENSOR
      CALL PK2ISOMATFIC(PKMATFIC,DISO,CBAR,CBARI1,UNIT2,NDI)
C     CAUCHY 'FICTICIOUS' STRESS TENSOR
      CALL SIGISOMATFIC(SISOMATFIC,PKMATFIC,DISTGR,DET,NDI)
C     'FICTICIOUS' MATERIAL ELASTICITY TENSOR
      CALL CMATISOMATFIC(CMISOMATFIC,CBAR,CBARI1,CBARI2,
     1                          DISO,UNIT2,UNIT4,DET,NDI)
C     'FICTICIOUS' SPATIAL ELASTICITY TENSOR
      CALL CSISOMATFIC(CISOMATFIC,CMISOMATFIC,DISTGR,DET,NDI)
C
C---- FIBERS (ONE FAMILY)   -------------------------------------------
C
      CALL PK2ANISOMATFIC(PKMATFICANISO,DANISO,CBAR,CBARI4,M0,NDI)
      CALL PUSH2(SANISOMATFIC,PKMATFICANISO,DISTGR,DET,NDI)
C      
      CALL CMATANISOMATFIC(CMANISOMATFIC,M0,DANISO,UNIT2,DET,NDI)
      CALL PUSH4(CANISOMATFIC,CMANISOMATFIC,DISTGR,DET,NDI)
C----------------------------------------------------------------------
C     SUM OF ALL ELASTIC CONTRIBUTIONS
C----------------------------------------------------------------------
C     STRAIN-ENERGY
      SSE=SSEV+SSEISO+SSEANISO
C     PK2 'FICTICIOUS' STRESS
      PKFIC=PKMATFIC+PKMATFICANISO
C     CAUCHY 'FICTICIOUS' STRESS
      SFIC=SISOMATFIC+SANISOMATFIC
C     MATERIAL 'FICTICIOUS' ELASTICITY TENSOR
      CMFIC=CMISOMATFIC+CMANISOMATFIC
C     SPATIAL 'FICTICIOUS' ELASTICITY TENSOR
      CFIC=CISOMATFIC+CANISOMATFIC
C
C----------------------------------------------------------------------
C-------------------------- STRESS MEASURES ---------------------------
C----------------------------------------------------------------------
C
C---- VOLUMETRIC ------------------------------------------------------
C      PK2 STRESS
      CALL PK2VOL(PKVOL,PV,C,NDI)
C      CAUCHY STRESS
      CALL SIGVOL(SVOL,PV,UNIT2,NDI)
C
C---- ISOCHORIC -------------------------------------------------------
C      PK2 STRESS
      CALL PK2ISO(PKISO,PKFIC,PROJL,DET,NDI)
C      CAUCHY STRESS
      CALL SIGISO(SISO,SFIC,PROJE,NDI)
C
C---- VOLUMETRIC + ISOCHORIC ------------------------------------------
C      PK2 STRESS
      PK2   = PKVOL + PKISO
C      CAUCHY STRESS
      SIGMA = SVOL  + SISO
C
C----------------------------------------------------------------------
C-------------------- MATERIAL ELASTICITY TENSOR ----------------------
C----------------------------------------------------------------------
C
C---- VOLUMETRIC ------------------------------------------------------
C
      CALL METVOL(CMVOL,C,PV,PPV,DET,NDI)
C
C---- ISOCHORIC -------------------------------------------------------
C
      CALL METISO(CMISO,CMFIC,PROJL,PKISO,PKFIC,C,UNIT2,DET,NDI)
C
C----------------------------------------------------------------------
C
      DDPKDDE=  CMVOL + CMISO
C
C----------------------------------------------------------------------
C--------------------- SPATIAL ELASTICITY TENSOR ----------------------
C----------------------------------------------------------------------
C
C---- VOLUMETRIC ------------------------------------------------------
C
      CALL SETVOL(CVOL,PV,PPV,UNIT2,UNIT4S,NDI)
C
C---- ISOCHORIC -------------------------------------------------------
C
      CALL SETISO(CISO,CFIC,PROJE,SISO,SFIC,UNIT2,NDI)
C
C-----JAUMMAN RATE ----------------------------------------------------
C
      CALL SETJR(CJR,SIGMA,UNIT2,NDI)
C
C----------------------------------------------------------------------
C
C     ELASTICITY TENSOR
      DDSIGDDE=CVOL+CISO+CJR
C
C----------------------------------------------------------------------
C------------------------- INDEX ALLOCATION ---------------------------
C----------------------------------------------------------------------
C     VOIGT NOTATION  - FULLY SIMMETRY IMPOSED
      CALL INDEXX(STRESS,DDSDDE,SIGMA,DDSIGDDE,NTENS,NDI)
C
C----------------------------------------------------------------------
C--------------------------- STATE VARIABLES --------------------------
C----------------------------------------------------------------------
C     DO K1 = 1, NTENS
C      STATEV(1:27) = VISCOUS TENSORS
       CALL SDVWRITE(DET,LAMBDA,STATEV)
C     END DO
C----------------------------------------------------------------------
      RETURN
      END
C----------------------------------------------------------------------
C--------------------------- END OF UMAT ------------------------------
C----------------------------------------------------------------------
C
