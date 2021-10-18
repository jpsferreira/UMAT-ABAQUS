      SUBROUTINE METISO(CMISO,CMFIC,PL,PKISO,PKFIC,C,UNIT2,DET,NDI)
C>    ISOCHORIC MATERIAL ELASTICITY TENSOR
      IMPLICIT NONE
      INCLUDE 'PARAM_UMAT.INC'
C
      INTEGER NDI,I1,J1,K1,L1
      DOUBLE PRECISION UNIT2(NDI,NDI),PL(NDI,NDI,NDI,NDI),
     1                 CMISO(NDI,NDI,NDI,NDI),PKISO(NDI,NDI),
     2                 CMFIC(NDI,NDI,NDI,NDI),PKFIC(NDI,NDI),
     3                 CISOAUX(NDI,NDI,NDI,NDI),
     4                 CISOAUX1(NDI,NDI,NDI,NDI),C(NDI,NDI),
     5                 PLT(NDI,NDI,NDI,NDI),CINV(NDI,NDI),
     6                 PLL(NDI,NDI,NDI,NDI)
      DOUBLE PRECISION TRFIC,XX,YY,ZZ,DET,AUX,AUX1
C
      CALL MATINV3D(C,CINV,NDI)
      CISOAUX1=ZERO
      CISOAUX=ZERO
      CALL CONTRACTION44(CISOAUX1,PL,CMFIC,NDI)
      DO I1=1,NDI
        DO J1=1,NDI
           DO K1=1,NDI
              DO L1=1,NDI
                PLT(I1,J1,K1,L1)=PL(K1,L1,I1,J1)
              END DO
            END DO
         END DO
      END DO
C
      CALL CONTRACTION44(CISOAUX,CISOAUX1,PLT,NDI)
C
      TRFIC=ZERO
      AUX=DET**(-TWO/THREE)
      AUX1=AUX**TWO
      CALL CONTRACTION22(TRFIC,AUX*PKFIC,C,NDI)

C
      DO I1=1,NDI
        DO J1=1,NDI
           DO K1=1,NDI
              DO L1=1,NDI
                XX=AUX1*CISOAUX(I1,J1,K1,L1)
                PLL(I1,J1,K1,L1)=(ONE/TWO)*(CINV(I1,K1)*CINV(J1,L1)+
     1                                      CINV(I1,L1)*CINV(J1,K1))-
     2                           (ONE/THREE)*CINV(I1,J1)*CINV(K1,L1)
                YY=TRFIC*PLL(I1,J1,K1,L1)
                ZZ=PKISO(I1,J1)*CINV(K1,L1)+CINV(I1,J1)*PKISO(K1,L1)
C
                CMISO(I1,J1,K1,L1)=XX+(TWO/THREE)*YY-(TWO/THREE)*ZZ
              END DO
           END DO
        END DO
      END DO
C
      RETURN
      END SUBROUTINE METISO
