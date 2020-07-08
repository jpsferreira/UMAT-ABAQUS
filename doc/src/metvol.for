      SUBROUTINE METVOL(CVOL,C,PV,PPV,DET,NDI)
C>    VOLUMETRIC MATERIAL ELASTICITY TENSOR
      IMPLICIT NONE
      INCLUDE 'PARAM_UMAT.INC'
C
      INTEGER NDI,I1,J1,K1,L1
      DOUBLE PRECISION C(NDI,NDI),CINV(NDI,NDI),
     1                 CVOL(NDI,NDI,NDI,NDI)
      DOUBLE PRECISION PV,PPV,DET
C
      CALL MATINV3D(C,CINV,NDI)
C
      DO I1 = 1, NDI
        DO J1 = 1, NDI
         DO K1 = 1, NDI
           DO L1 = 1, NDI
             CVOL(I1,J1,K1,L1)=
     1                 DET*PPV*CINV(I1,J1)*CINV(K1,L1)
     2           -DET*PV*(CINV(I1,K1)*CINV(J1,L1)
     3                      +CINV(I1,L1)*CINV(J1,K1))
           END DO
         END DO
        END DO
      END DO
C
      RETURN
      END SUBROUTINE METVOL
