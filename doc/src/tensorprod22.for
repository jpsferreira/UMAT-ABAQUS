       SUBROUTINE TENSORPROD2(A,B,C,NDI)
C
       Implicit None
C
       INTEGER I,J,K,L,NDI
C
       DOUBLE PRECISION A(NDI,NDI),B(NDI,NDI),C(NDI,NDI,NDI,NDI)
C
      DO I=1,NDI
       DO J=1,NDI
         DO K=1,NDI
          DO L=1,NDI
          C(I,J,K,L)=A(I,J)*B(K,L)
          END DO
         END DO
       END DO
      END DO
C
      RETURN
C
      end SUBROUTINE TENSORPROD2
