      SUBROUTINE PULL4(MAT,SPATIAL,FINV,DET,NDI)
C>        PULL-BACK TIMES DET OF 4TH ORDER TENSOR
       IMPLICIT NONE
       INCLUDE 'PARAM_UMAT.INC'
C
       INTEGER I1,J1,K1,L1,II1,JJ1,KK1,LL1,NDI
       DOUBLE PRECISION MAT(NDI,NDI,NDI,NDI),FINV(NDI,NDI)
       DOUBLE PRECISION SPATIAL(NDI,NDI,NDI,NDI)
       DOUBLE PRECISION AUX,DET
C
       DO I1=1,NDI
        DO J1=1,NDI
         DO K1=1,NDI
          DO L1=1,NDI
           AUX=ZERO
           DO II1=1,NDI
            DO JJ1=1,NDI
             DO KK1=1,NDI
              DO LL1=1,NDI
              AUX=AUX+DET*
     +        FINV(I1,II1)*FINV(J1,JJ1)*
     +        FINV(K1,KK1)*FINV(L1,LL1)*SPATIAL(II1,JJ1,KK1,LL1)
              END DO
             END DO
            END DO
           END DO
           MAT(I1,J1,K1,L1)=AUX
          END DO
         END DO
        END DO
       END DO
C
       RETURN
      END SUBROUTINE PULL4
